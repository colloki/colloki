$(function() {
  window.StoryListView = Backbone.View.extend({
    emptyMessage: "Oops! We didn't find anything...Change filters or refresh!",

    events: {
      "click .source": "filterBySource",
      "click .date-range": "filterByDateRange",
      "click .topic": "filterByTopic",
      "click .kind": "filterByKind",
      "keypress .search": "filterByQuery",
      "click .liked_by": "filterByLikedBy"
    },

    initialize: function() {
      _.bindAll(this, "render", "append", "filterBySource", "filterByDateRange", "onScroll");
      this.delegateEvents();
      this.collection = new Stories();
      this.$stories = $(".topic-stories", this.$el);
      this.dateRange = 1;
      this.query = "";
      this.page = 1;
      this.kind = 2;
      this.paginationBufferPx = 50;
      this.isLoading = false;
      this.likedBy = -1;
      this.$sourceFilter = $(".filter-source", this.$el);
      this.$topicFilter = $(".filter-topic", this.$el);

      if (this.options.topic) {
        this.topic = this.options.topic.id;
      } else {
        this.topic = -2;
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
      this.$stories.imagesLoaded($.proxy(function() {
        this.$stories.masonry('reload');
      }, this));
      $(".has-tooltip").tooltip();
    },

    append: function(story) {
      var view = new StoryView({
        model: story
      });

      this.$stories.append(view.render().el);
      this.render();
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

          this.$stories.imagesLoaded($.proxy(function() {
            this.$stories.masonry('reload');
          }, this));
        } else {
          this.$stories.html($("<h4>", {
            "class": "topic-empty-message",
            html: this.emptyMessage
          }));
        }

        this.isLoading = false;
      }, this));
    },

    load: function(callback) {
      this.isLoading = true;
      var request = "/search.json?query=" + this.query + "&range=" + this.dateRange + "&page=" + this.page + "&topic=" + this.topic + "&kind=" + this.kind + "&liked_by=" + this.likedBy;
      $.getJSON(request, callback);
    },

    filterBySource: function(event) {
      this.query = $(event.target).data("value");
      this.likedBy = -1;
      this.reset();
    },

    filterByDateRange: function(event) {
      var $el = $(event.target);
      $el.addClass("active").siblings().removeClass("active");
      this.dateRange = $el.data("value");
      this.likedBy = -1;
      this.reset();
    },

    filterByTopic: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      var $li = $el.parent("li");
      $li.addClass("active").siblings().removeClass("active");
      this.topic = $el.data("id");
      this.likedBy = -1;
      this.reset();
    },

    filterByKind: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      var $li = $el.parent("li");
      $li.addClass("active")
        .find("i").addClass("icon-white")
        .end()
        .siblings().removeClass("active")
        .find("i").removeClass("icon-white");
      this.kind = $el.data("value");
      if (this.kind != "2") {
        this.$topicFilter.hide();
        this.$sourceFilter.hide();
      } else {
        this.$topicFilter.show();
        this.$sourceFilter.show();
      }
      this.likedBy = -1;
      this.reset();
    },

    filterByQuery: function(event) {
      if (event.charCode != 13) {return;}
      event.preventDefault();
      var $el = $(event.target);
      this.query = $el.val();
      $el.val("");
      this.likedBy = -1;
      this.reset();
    },

    filterByLikedBy: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      var $li = $el.parent("li");
      $li.addClass("active")
        .find("i").addClass("icon-white")
        .end()
        .siblings().removeClass("active")
        .find("i").removeClass("icon-white");
      this.likedBy = $el.data("value");
      this.reset();
    },

    onScroll: function() {
      if (this.isLoading) {return;}
      var $window = $(window);
      var pixelsFromWindowBottomToBottom = 0 + $(document).height() - $window.scrollTop() - $(window).height();
      if (pixelsFromWindowBottomToBottom - this.paginationBufferPx < 0) {
        this.nextPage();
      }
    }
  });
});
