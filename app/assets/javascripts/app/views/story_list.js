$(function() {
  window.StoryListView = Backbone.View.extend({
    emptyMessageWithHistory: "We didn't find anything. Please <a href='javascript:window.history.back()'>go back</a>.",
    emptyMessageWithoutHistory: "We didn't find anything. Go <a href='#' class='.home'>home</a>.",

    eventsHTML: '<iframe class="events-calendar" width="880" height="800" src="http://elmcity.cloudapp.net/NewRiverValleyVA/html?eventsonly=yes&tags=no&count=200&width=450&taglist=no&tags=no&sidebar=no&datepicker=no&timeofday=no&hubtitle=no&datestyle=&itemstyle=&titlestyle=&linkstyle=&dtstartstyle=&sourcestyle=&theme=roanoke"></iframe>',

    types: {
      "user": 1,
      "rss": 2,
      "chatter": "3,4",
      "likes": 5,
      "events": 6
    },

    events: {
      "click .source": "filterBySource",
      "click .date-range": "filterByDateRange",
      "click .topic": "filterByTopic",
      "click .type": "filterByType",
      "keyup .search-query": "filterByQuery",
      "click .sort": "sortBy"
    },

    initialize: function() {
      _.bindAll(this,
        "render",
        "append",

        "selectButton",
        "selectNavTab",
        "selectNavPill",

        "onScroll",

        "resetHeader",

        "sortBy",

        "filterBySource",
        "showSource",

        "filterByDateRange",
        "showDateRange",

        "filterByTopic",
        "showTopic",
        "resetTopic",

        "filterByType",
        "showType",

        "filterByQuery",
        "showQuery",
        "resetQuery",

        "showLikes",
        "resetLikedBy",

        "showEvents");

      this.delegateEvents();
      this.collection = new Stories();
      this.$stories = $(".topic-stories", this.$el);

      this.$sourceFilter = $(".filter-source", this.$el);
      this.$topicFilter = $(".filter-topic", this.$el);
      this.$dateFilter = $(".filter-date", this.$el);
      this.$queryFilter = $(".filter-search", this.$el);
      this.$sort = $(".filter-sort", this.$el);
      this.$header = $(".topic-header", this.$el);

      this.paginationBufferPx = 50;
      this.isLoading = false;
      this.router = this.options.router;
      this.loadOnScroll = true;
      this.resetToDefault();

      if (this.options.topic) {
        this.topic = this.options.topic;
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

      if (this.options.source) {
        this.source = this.options.source;
      }

      if (this.options.query) {
        this.query = this.options.query;
      }

      if (this.options.sort === "date") {
        this.sort = 2;
      }

      if (this.options.type) {
        this.type = this.options.type;
      }

      if (this.options.dateRange) {
        this.dateRange = this.options.dateRange;
      }

      this.$stories.imagesLoaded($.proxy(function() {
        this.$stories.masonry({
          itemSelector: ".story-item"
        });
      }, this));

      $(window).scroll(this.onScroll);

      $('.home', this.$el).click($.proxy(function(e) {
        this.router.navigate("/", true);
      }, this));

      if (this.type == this.types["events"]) {
        this.showType(this.type);
        this.render();
      } else {
        this.reset();
      }
    },

    render: function(shouldRewriteURL) {
      if (this.type != this.types["rss"]) {
        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry('reload');
        }, this));
      }

      // show/hide the appropriate filters
      if (this.type != this.types["rss"]) {
        this.$topicFilter.hide();
        this.$sourceFilter.hide();
        this.$dateFilter.hide();
        this.$sort.hide();

        this.resetQuery();
        this.resetTopic();
        this.resetSource();

        if (this.type == this.types["events"]) {
          this.$queryFilter.hide();
        } else {
          this.$queryFilter.show();
        }

        if (this.type == this.types["chatter"] || this.type == this.types["user"]) {
          this.$dateFilter.show();
        } else {
          this.$dateFilter.hide();
        }
      } else {
        this.$sort.show();
        this.$queryFilter.show();
        this.$dateFilter.show();
        this.$topicFilter.show();
        this.$sourceFilter.show();
      }

      // select the right filtering options
      this.selectNavPill($(".source[data-value='" + this.source + "']"));
      this.selectNavPill($(".topic[data-id=" + this.topic + "]"));
      this.selectNavPill($(".sort[data-value=" + this.sort + "]"));
      this.selectNavPill($(".type[data-value='" + this.type + "']"));
      this.selectNavPill($(".date-range[data-value='" + this.dateRange + "']"));
      $(".search-query", this.$el).val(this.query);

      this.resetHeader();

      if (shouldRewriteURL) {
        this.router.rewriteURL(this);
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
      } else if (this.type == this.types["rss"]) {
        if (this.dateRange == 4) {
          text = "This Week's News";
        } else if (this.dateRange == 2) {
          text = "Today's News";
        } else {
          text = "All News";
        }

        if (this.topic != -2) {
          text += " - " + $(".topic[data-id="+ this.topic + "]").text();
        } else if (this.source != -1) {
          text += " - <em>" + this.source + "</em>";
        } else if (this.query != "") {
          text += " - Search results for '" + this.query + "'";
        } else {
          text += " - [ Everything ]";
        }
      } else if (this.type == this.types["chatter"]) {
        text = "Conversations on Twitter and Facebook";
      } else if (this.type == this.types["user"]) {
        text = "Shared by VTS Users";
      }

      this.$header.html(text);
    },

    reset: function(shouldRewriteURL) {
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
        } else {
          var $message = $("<p>", {
            "class": "lead empty-message"
          });

          if (this.emptyMessage) {
            $message.html(this.emptyMessage);
          } else if (window.history.length > 2) {
            $message.html(this.emptyMessageWithHistory);
          } else {
            $message.html(this.emptyMessageWithoutHistory);
          }

          this.$stories.html($message);
        }

        this.isLoading = false;
        this.render(shouldRewriteURL);
      }, this));
    },

    load: function(callback) {
      this.isLoading = true;
      var request = "/search.json?query=" + this.query +
        "&range=" + this.dateRange +
        "&page=" + this.page +
        "&topic=" + this.topic +
        "&type=" + this.type +
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

    /** Filters and Sorts **/

    sortBy: function(event) {
      event.preventDefault();
      this.loadOnScroll = true;

      var $el = $(event.target);
      this.selectNavPill($el);
      this.sort = $el.data("value");
      this.reset(true);
    },

    filterByDateRange: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.showDateRange($el.data("value"), true);
    },

    showDateRange: function(dateRange, shouldRewriteURL) {
      this.dateRange = dateRange;
      this.loadOnScroll = true;
      this.resetLikedBy();
      this.reset(shouldRewriteURL);
    },

    filterByTopic: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.resetSource();
      this.resetQuery();
      this.resetLikedBy();
      this.showTopic($el.data("id"), true);
      // Hide the topic's popover so that the user can see the stories under it
      $(".popover").remove();
    },

    showTopic: function(topic, shouldRewriteURL) {
      this.topic = topic;
      this.loadOnScroll = true;
      this.reset(shouldRewriteURL);
    },

    resetTopic: function() {
      this.topic = -2;
    },

    filterBySource: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.resetTopic();
      this.resetQuery();
      this.resetLikedBy();
      this.showSource($(event.target).data("value"), true);
    },

    showSource: function(source, shouldRewriteURL) {
      this.source = source;
      this.reset(shouldRewriteURL);
    },

    resetSource: function() {
      this.source = -1;
    },

    filterByType: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      if (!$el.hasClass("type")) {
        $el = $el.parents(".type");
      }

      this.showType($el.data("value"), true);
    },

    showType: function(type, shouldRewriteURL) {
      this.type = type;
      this.loadOnScroll = true;

      if(this.type == this.types["events"]) {
        this.showEvents(shouldRewriteURL);
      } else if (this.type == this.types["likes"]) {
        this.showLikes(shouldRewriteURL);
      } else {
        this.resetLikedBy();
        this.reset(shouldRewriteURL);
      }
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
        this.reset(true);
      } else if (event.keyCode === 13) {
        event.preventDefault();
        this.resetLikedBy();
        this.resetTopic();
        this.resetSource();
        this.showQuery($el.val(), true);
      }
    },

    showQuery: function(query, shouldRewriteURL) {
      this.query = query;
      this.loadOnScroll = true;
      this.reset(shouldRewriteURL);
    },

    showLikes: function(shouldRewriteURL) {
      this.loadOnScroll = true;
      this.likedBy = this.options.current_user.id;
      this.reset(shouldRewriteURL);
    },

    resetLikedBy: function() {
      this.likedBy = -1;
    },

    showEvents: function(shouldRewriteURL) {
      this.loadOnScroll = false;
      this.$header.html('Events from <em><a href="http://elmcity.cloudapp.net/">elmcity</a></em>');
      this.$stories.html(this.eventsHTML);
      this.render(shouldRewriteURL);
    },

    resetToDefault: function() {
      this.dateRange = 4;
      this.query = "";
      this.page = 1;
      this.type = this.types["rss"];
      this.sort = 1;
      this.likedBy = -1;
      this.postedBy = -1;
      this.topic = -2;
      this.source = -1;
    }
  });
});
