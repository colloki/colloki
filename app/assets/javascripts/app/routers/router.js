$(function() {
  window.AppRouter = Backbone.Router.extend({
    $el: $(".topic-body"),
    current_user: gon.current_user,
    view: null,

    // todo: use regex
    // todo: support date ranges
    routes: {
      "": "default",
      ":range/news": "default",
      ":range/news/:sort": "default",

      "events": "events",
      "likes": "likes",
      ":range/shared": "shared",
      ":range/chatter": "chatter",

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
          current_user: this.current_user,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange),
          router: this
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
          current_user: this.current_user,
          query: query,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange),
          router: this
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
          current_user: this.current_user,
          topic: topic,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange),
          router: this
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
          current_user: this.current_user,
          source: source,
          sort: this.sortInt(sort),
          dateRange: this.dateRangeInt(dateRange),
          router: this
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
          current_user: this.current_user,
          router: this,
          type: 6
        });
      }

    },

    likes: function() {
      if (this.view) {
        this.view.showType(5);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          router: this,
          likedBy: this.current_user.id,
          type: 5
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
          current_user: this.current_user,
          router: this,
          type: 1,
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    chatter: function(dateRange) {
      if (this.view) {
        this.view.dateRange = this.dateRangeInt(dateRange);
        this.view.showType("3,4");
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          router: this,
          type: "3,4",
          dateRange: this.dateRangeInt(dateRange)
        });
      }
    },

    rewriteURL: function(view) {
      var route = "";

      if (view.type == 1 || view.type == 2 || view.type == "3,4") {
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
      } else if (view.type == "3,4") {
        route += "/chatter";
      } else if (view.type == 5) {
        route += "/likes";
      } else if (view.type == 6) {
        route += "/events";
      } else {
        route += "/news";
      }

      if (view.query != "") {
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
