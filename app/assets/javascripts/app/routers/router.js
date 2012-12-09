$(function() {
  window.AppRouter = Backbone.Router.extend({
    $el: $(".topic-body"),
    view: null,
    user: gon.current_user,
    viewer: gon.current_user,

    routes: {
      "": "default",
      ":range/news": "default",
      ":range/news/:sort": "default",

      "events": "events",
      "map": "map",
      "likes": "likes",
      "following": "following",
      "shared": "shared",

      ":range/chatter": "chatter",
      ":range/chatter/:type": "chatter",
      ":range/chatter/:type/search/:query": "chatter",
      ":range/chatter/:type/source/:source": "chatterForSource",

      ":range/news/search/:query": "search",
      ":range/search/:query": "search",
      ":range/news/search/:query/:sort": "search",
      ":range/search/:query/:sort": "search",

      ":range/news/topic/:topic": "topic",
      ":range/topic/:topic": "topic",
      ":range/news/topic/:topic/:sort": "topic",
      ":range/topic/:topic/:sort": "topic",

      ":range/news/source/:source": "source",
      ":range/source/:source": "source",
      ":range/news/source/:source/:sort": "source",
      ":range/source/:source/:sort": "source",

      ":route/:action": "dateRange"
    },

    default: function(dateRange, sort) {
      if (this.view) {
        this.view.resetToDefault();

        if (dateRange) {
          this.view.dateRange = this.dateRangeInt(dateRange);
        }

        if (sort) {
          this.view.sort = this.sortInt(sort);
        }

        this.view.showType(2);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    search: function(dateRange, query, sort) {
      if (this.view) {
        this.view.resetToDefault();
        this.view.dateRange = this.dateRangeInt(dateRange);

        if (sort) {
          this.view.sort = this.sortInt(sort);
        }

        this.view.showQuery(query);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          query: query,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    topic: function(dateRange, topic, sort) {
      if (this.view) {
        this.view.resetToDefault();
        this.view.dateRange = this.dateRangeInt(dateRange);
        this.view.type = 2;

        if (sort) {
          this.view.sort = this.sortInt(sort);
        }

        this.view.showTopic(topic);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          topic: topic,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    source: function(dateRange, source, sort) {
      if (this.view) {
        this.view.resetToDefault();
        this.view.dateRange = this.dateRangeInt(dateRange);

        if (sort) {
          this.view.sort = this.sortInt(sort);
        }

        this.view.showSource(source);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          source: source,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    dateRange: function(route, action) {
      // todo: build this
    },

    events: function() {
      if (this.view) {
        this.view.showType(6);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          type: 6
        });
      }
    },

    map: function() {
      if (this.view) {
        this.view.showType(9);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          type: 9
        });
      }

    },

    likes: function() {
      if (this.view) {
        this.view.showType(5);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          type: 5
        });
      }
    },

    following: function() {
      if (this.view) {
        this.view.showType(7);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          user: this.user,
          viewer: this.viewer,
          router: this,
          type: 7
        });
      }
    },

    shared: function(dateRange) {
      if (this.view) {
        this.view.dateRange = this.dateRangeInt(dateRange);
        this.view.showType(1);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          type: 1,
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    chatter: function(dateRange, type, query) {
      if (this.view) {
        this.view.dateRange = this.dateRangeInt(dateRange);

        if (query) {
          this.view.query = query;
        }

        if (type == "facebook") {
          this.view.showType(3);
        } else {
          this.view.showType(4);
        }

      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          query: query,
          type: (type == "facebook") ? 3 : 4,
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    chatterForSource: function(dateRange, type, source) {
      if (this.view) {
        this.view.dateRange = this.dateRangeInt(dateRange);

        if (query) {
          this.view.query = query;
        }

        this.type = type;
        this.showSource(source);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          router: this,
          user: this.user,
          viewer: this.viewer,
          source: source,
          type: (type == "facebook") ? 3 : 4,
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    // todo(ankit): store these type numbers at a common place. it is a mess
    rewriteURL: function(view) {
      var route = "";

      if (view.type == 2 || view.type == 3 || view.type == 4) {
        if (view.dateRange == 2) {
          route = "today"
        } else if (view.dateRange == 1) {
          route = "all";
        } else {
          route = "week";
        }
      }

      if (view.type == 1) {
        route += "/shared";
      } else if (view.type == 4) {
        route += "/chatter/twitter";
      } else if (view.type == 3) {
        route += "/chatter/facebook";
      } else if (view.type == 5) {
        route += "/likes";
      } else if (view.type == 6) {
        route += "/events";
      } else if (view.type == 7) {
        route += "/following";
      } else if (view.type == 9) {
        route += "/map";
      } else {
        route += "/news";
      }

      if (view.query) {
        route += "/search/" + view.query;
      } else if (view.source != -1) {
        route += "/source/" + view.source;
      } else if (view.topic != -2) {
        route += "/topic/" + view.topic;
      }

      var sort;
      if (view.type == 2 && view.sort == 2) {
        route += "/date";
      }

      this.navigate(route);
    },

    dateRangeInt: function(dateRange) {
      if (dateRange === "today") {
        return 2;
      } else if (dateRange === "all") {
        return 1;
      } else {
        return 4;
      }
    },

    sortInt: function(sort) {
      if (sort === "date") {
        return 2;
      } else {
        return 1;
      }
    }
  });
});
