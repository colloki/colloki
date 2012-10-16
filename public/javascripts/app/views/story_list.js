$(function() {
  window.StoryListView = Backbone.View.extend({
    emptyMessage: "We didn't find anything. Please change filters or refresh.",

    eventsHTML: '<h3>Events</h3><iframe class="events-calendar"' +
    'src="http://elmcity.cloudapp.net/services/NewRiverValleyVA/html?&eventsonly=yes&tags=yes&count=200"></iframe>' +
    '<div class="events-footer">This is the embedded calendar from the ' +
    '<a href="http://elmcity.cloudapp.net/">elmcity project</a>.</div>',

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
        "selectNavPill",
        "onScroll",
        "resetQuery",
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

      this.$sourceFilter = $(".filter-source", this.$el);
      this.$topicFilter = $(".filter-topic", this.$el);
      this.$dateFilter = $(".filter-date", this.$el);
      this.$queryFilter = $(".filter-search", this.$el);
      this.$sort = $(".filter-sort", this.$el);

      this.loadOnScroll = true;

      if (this.options.topic) {
        this.topic = this.options.topic.id;
      } else {
        this.topic = -2;
      }

      // if (this.kind != 2) {
        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry({
            itemSelector: ".story-item"
          });
        }, this));
      // }

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
          this.$stories.html($("<h4>", {
            "class": "topic-empty-message",
            html: this.emptyMessage
          }));
        }

        this.isLoading = false;
        this.render();
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
        "&sort=" + this.sort;
      $.getJSON(request, callback);
    },

    selectButton: function($el) {
      $el.addClass("active").siblings().removeClass("active");
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

    filterBySource: function(event) {
      this.query = $(event.target).data("value");
      this.likedBy = -1;
      this.reset();
    },

    filterByDateRange: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectButton($el);
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
      this.likedBy = -1;
      this.reset();
    },

    filterByKind: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);

      this.kind = $el.data("value");

      if (this.kind != "2") {
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
      if (event.keyCode === 27) {
        event.preventDefault();
        var $el = $(event.target);
        if ($el.val() === "") {
          return;
        }
        this.resetQuery();
        this.reset();
      } else if (event.keyCode === 13) {
        event.preventDefault();
        this.loadOnScroll = true;

        var $el = $(event.target);
        this.query = $el.val();

        this.likedBy = -1;
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
      this.selectNavPill($el);

      this.$stories.html(this.eventsHTML);

      this.$topicFilter.hide();
      this.$sourceFilter.hide();
      this.$dateFilter.hide();
      this.$queryFilter.hide();
      this.$sort.hide();
    }
  });
});
