$(function() {
  window.AppRouter = Backbone.Router.extend({
    $el: $(".topic-body"),
    current_user: gon.current_user,
    view: null,

    // todo: use regex
    // todo: support date ranges
    routes: {
      "": "default",
      "news": "default",
      "news/:sort": "default",

      "events": "events",
      "likes": "likes",
      "shared": "shared",
      "chatter": "chatter",

      "news/search/:query": "search",
      "search/:query": "search",
      "news/search/:query/:sort": "search",
      "search/:query/:sort": "search",

      "news/topic/:topic": "topic",
      "topic/:topic": "topic",
      "news/topic/:topic/:sort": "topic",
      "topic/:topic/:sort": "topic",

      "news/source/:source": "source",
      "source/:source": "source",
      "news/source/:source/:sort": "source",
      "source/:source/:sort": "source",

      ":route/:action": "dateRange"
    },

    default: function(sort) {
      if (this.view) {
        this.view.topic = -2;
        if (sort) {
          this.view.sort = sort;
        }
        this.view.showType(2);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          sort: sort,
          router: this
        });
      }
    },

    search: function(query, sort) {
      if (this.view) {
        this.view.showQuery(query, sort);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          query: query,
          sort: sort,
          router: this
        });
      }
    },

    topic: function(topic, sort) {
      if (this.view) {
        this.view.type = 2;
        this.view.showTopic(topic, sort);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          topic: topic,
          sort: sort,
          router: this
        });
      }
    },

    source: function(source, sort) {
      if (this.view) {
        this.view.showSource(source, sort);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          source: source,
          sort: sort,
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

    shared: function() {
      if (this.view) {
        this.view.showType(1);
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          router: this,
          type: 1
        });
      }
    },

    chatter: function() {
      if (this.view) {
        this.view.showType("3,4");
      } else {
        this.view = new window.StoryListView({
          el: this.$el,
          current_user: this.current_user,
          router: this,
          type: "3,4"
        });
      }
    },

    rewriteURL: function(view) {
      var route = "";
      if (view.type == 1) {
        route = "shared";
      } else if (view.type == "3,4") {
        route = "chatter";
      } else if (view.type == 5) {
        route = "likes";
      } else if (view.type == 6) {
        route = "events";
      } else {
        route = "news";
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
    }
  });
});
