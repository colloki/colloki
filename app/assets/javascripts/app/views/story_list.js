$(function() {
  window.StoryListView = Backbone.View.extend({
    emptyMessage: "We didn't find anything. Please go back.",

    eventsHTML: '<iframe class="events-calendar" width="880" height="800" src="http://elmcity.cloudapp.net/NewRiverValleyVA/html?eventsonly=yes&tags=no&count=200&width=450&taglist=no&tags=no&sidebar=no&datepicker=no&timeofday=no&hubtitle=no&datestyle=&itemstyle=&titlestyle=&linkstyle=&dtstartstyle=&sourcestyle=&theme=roanoke"></iframe>',

    events: {
      "click .source": "filterBySource",
      "click .date-range": "filterByDateRange",
      "click .topic": "filterByTopic",
      "click .kind": "filterByKind",
      "keyup .search-query": "filterByQuery",
      "click .liked": "filterByLikedBy",
      "click .sort": "sortBy",
      "click .events": "showEvents"
    },

    initialize: function() {
      _.bindAll(this,
        "render",
        "append",
        "showEvents",
        "selectButton",
        "selectNavTab",
        "selectNavPill",
        "onScroll",
        "resetQuery",
        "resetHeader",
        "resetTopic",
        "sortBy",
        "filterBySource",
        "filterByDateRange",
        "filterByTopic",
        "filterByKind",
        "filterByQuery",
        "filterByLikedBy");

      this.delegateEvents();
      this.collection = new Stories();
      this.$stories = $(".topic-stories", this.$el);
      this.dateRange = 4;
      this.query = "";
      this.page = 1;
      this.kind = 2;
      this.sort = 1;
      this.paginationBufferPx = 50;
      this.isLoading = false;
      this.likedBy = -1;
      this.postedBy = -1;
      this.source = -1;

      this.$sourceFilter = $(".filter-source", this.$el);
      this.$topicFilter = $(".filter-topic", this.$el);
      this.$dateFilter = $(".filter-date", this.$el);
      this.$queryFilter = $(".filter-search", this.$el);
      this.$sort = $(".filter-sort", this.$el);
      this.$header = $(".topic-header", this.$el);

      this.loadOnScroll = true;

      if (this.options.topic) {
        this.topic = this.options.topic.id;
      } else {
        this.topic = -2;
      }

      if (this.options.postedBy) {
        this.postedBy = this.options.postedBy;
      }

      if (this.options.likedBy) {
        this.likedBy = this.options.likedBy;
      }

      if (this.options.emptyMessage) {
        this.emptyMessage = this.options.emptyMessage;
      }

      this.$stories.imagesLoaded($.proxy(function() {
        this.$stories.masonry({
          itemSelector: ".story-item"
        });
      }, this));

      $(window).scroll(this.onScroll);
      this.reset();
    },

    render: function() {
      if (this.kind != 2) {
        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry('reload');
        }, this));
      }

      $(".has-tooltip").tooltip();
    },

    append: function(story) {
      var view = new StoryView({
        model: story
      });

      this.$stories.append(view.render().el);
    },

    nextPage: function() {
      this.page++;

      this.load($.proxy(function(data) {
        var len = data.length;
        for (var i = 0; i < len; i++) {
          data[i].current_user = this.options.current_user;
          var c = new Story(data[i]);

          if (!this.collection.get(c.id)) {
            this.collection.add(c);
            this.append(c);
          }
        }

        this.render();
        this.isLoading = false;
      }, this));
    },

    resetHeader: function() {
      var text;

      if (this.likedBy != -1) {
        text = "Liked by you";
      } else if (this.kind == 2) {
        if (this.dateRange == 4) {
          text = "This Week's News";
        } else if (this.dateRange == 2) {
          text = "Today's News";
        } else {
          text = "All News";
        }

        if (this.topic != -2) {
          text += " - " + $(".topic[data-id="+this.topic+"]").text();
        } else if (this.source != -1) {
          text += " - <em>" + this.source + "</em>";
        } else if (this.query != "") {
          text += " - Search results for '" + this.query + "'";
        } else {
          text += " - [ Everything ]";
        }
      } else if (this.kind == "3,4") {
        text = "Conversations on Twitter and Facebook";
      } else if (this.kind == 1) {
        text = "Shared by VTS Users";
      }

      this.$header.html(text);
    },

    reset: function() {
      this.page = 1;

      this.load($.proxy(function(data) {
        // TODO: Get rid of this ugliness.
        this.collection.reset();
        this.$stories.html("");

        var len = data.length;
        if (len != 0) {
          for (var i = 0; i < len; i++) {
            data[i].current_user = this.options.current_user;
            var c = new Story(data[i]);
            this.collection.add(c);
            this.append(c);
          }

          this.render();
        } else {
          this.$stories.html($("<p>", {
            "class": "lead empty-message",
            html: this.emptyMessage
          }));
        }

        this.isLoading = false;
        this.render();
        this.resetHeader();
      }, this));
    },

    load: function(callback) {
      this.isLoading = true;
      var request = "/search.json?query=" + this.query +
        "&range=" + this.dateRange +
        "&page=" + this.page +
        "&topic=" + this.topic +
        "&kind=" + this.kind +
        "&liked_by=" + this.likedBy +
        "&posted_by=" + this.postedBy +
        "&sort=" + this.sort +
        "&source=" + this.source;
      $.getJSON(request, callback);
    },

    selectButton: function($el) {
      $el.addClass("active").siblings().removeClass("active");
    },

    selectNavTab: function($el) {
      var $li = $el.parents("li");

      $li.addClass("active")
        .siblings().removeClass("active");
    },

    selectNavPill: function($el) {
      var $li = $el.parent("li");
      $li.addClass("active")
        .find("i").addClass("icon-white")
        .end()
        .siblings().removeClass("active")
        .find("i").removeClass("icon-white");
    },

    onScroll: function() {
      if (!this.loadOnScroll) {return;}
      if (this.isLoading) {return;}
      var $window = $(window);
      var pixelsFromWindowBottomToBottom = 0 + $(document).height() - $window.scrollTop() - $(window).height();
      if (pixelsFromWindowBottomToBottom - this.paginationBufferPx < 0) {
        this.nextPage();
      }
    },

    /** Filters **/

    sortBy: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);
      this.sort = $el.data("value");
      this.reset();
    },

    filterByDateRange: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);
      this.dateRange = $el.data("value");
      this.likedBy = -1;
      this.reset();
    },

    filterByTopic: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);

      this.topic = $el.data("id");
      this.resetSource();
      this.resetQuery();
      this.likedBy = -1;
      this.reset();
    },

    resetTopic: function() {
      this.topic = -2;
      this.selectNavPill($(".topic[data-id=-2]"));
    },

    filterBySource: function(event) {
      event.preventDefault();
      this.source = $(event.target).data("value");
      var $el = $(event.target);
      this.selectNavPill($el);
      this.resetTopic();
      this.resetQuery();
      this.likedBy = -1;
      this.reset();
    },

    resetSource: function() {
      this.source = -1;
      this.selectNavPill($(".source[data-value=-1]"));
    },

    filterByKind: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavTab($el);

      this.kind = $el.data("value");

      if (this.kind != "2") {
        this.resetTopic();
        this.resetSource();
        this.resetQuery();
        this.$topicFilter.hide();
        this.$sourceFilter.hide();
      } else {
        this.$topicFilter.show();
        this.$sourceFilter.show();
      }

      this.$dateFilter.show();
      this.$queryFilter.show();
      this.$sort.show();

      this.likedBy = -1;
      this.resetQuery();
      this.reset();
    },

    resetQuery: function() {
      this.query = "";
      $(".search-query", this.$el).val("");
    },

    filterByQuery: function(event) {
      var $el = $(event.target);

      if (event.keyCode === 27 || $el.val() === "") {
        event.preventDefault();
        this.resetQuery();
        this.reset();
      } else if (event.keyCode === 13) {
        event.preventDefault();
        this.loadOnScroll = true;
        this.query = $el.val();
        this.likedBy = -1;
        this.resetTopic();
        this.resetSource();
        this.reset();
      }
    },

    filterByLikedBy: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);

      this.likedBy = $el.data("value");
      this.reset();

      this.$topicFilter.hide();
      this.$sourceFilter.hide();
      this.$dateFilter.hide();
      this.$queryFilter.hide();
      this.$sort.hide();
    },

    showEvents: function(event) {
      event.preventDefault();
      this.loadOnScroll = false;

      var $el = $(event.target);
      this.selectNavTab($el);

      this.$header.html('Events from <em><a href="http://elmcity.cloudapp.net/">elmcity</a></em>');
      this.$stories.html(this.eventsHTML);

      this.$topicFilter.hide();
      this.$sourceFilter.hide();
      this.$dateFilter.hide();
      this.$queryFilter.hide();
      this.$sort.hide();
    }
  });
});
