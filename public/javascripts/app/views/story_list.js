$(function() {
  window.StoryListView = Backbone.View.extend({
    events: {
      "click .source": "filterBySource",
      "click .date-range": "filterByDateRange",
      "click .topic-link": "filterByTopic"
    },

    initialize: function() {
      _.bindAll(this, "render", "append", "filterBySource", "filterByDateRange", "onScroll");
      this.delegateEvents();
      this.collection = new Stories();
      this.$stories = $(".topic-stories", this.$el);
      this.dateRange = 1;
      this.query = "";
      this.page = 1;
      this.paginationBufferPx = 50;
      this.isLoading = false;

      if (this.options.topic) {
        this.topic = this.options.topic.id;
      } else {
        this.topic = -2;
      }

      // TODO: for some reason, collection.reset doesn't work here.
      var len = this.options.data.length;
      for (var i = 0; i < len; i++) {
        this.options.data[i].current_user = this.options.current_user;
        var c = new Story(this.options.data[i]);
        this.collection.add(c);
        this.append(c);
      }

      this.$stories.imagesLoaded($.proxy(function() {
        this.$stories.masonry({
          itemSelector: ".story-item"
        });
      }, this));

      $(window).scroll(this.onScroll);
    },

    render: function() {
      //
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
            console.log(c);
            this.collection.add(c);
            this.append(c);
          }
        }

        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry('reload');
        }, this));

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
        for (var i = 0; i < len; i++) {
          data[i].current_user = this.options.current_user;
          var c = new Story(data[i]);
          this.collection.add(c);
          this.append(c);
        }

        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry('reload');
        }, this));
        this.isLoading = false;
      }, this));
    },

    load: function(callback) {
      this.isLoading = true;
      var request = "/search.json?query=" + this.query + "&range=" + this.dateRange + "&page=" + this.page + "&topic=" + this.topic;
      $.getJSON(request, callback);
    },

    filterBySource: function(event) {
      this.query = $(event.target).data("value");
      this.reset();
    },

    filterByDateRange: function(event) {
      var $el = $(event.target);
      $el.addClass("active").siblings().removeClass("active");
      this.dateRange = $el.data("value");
      this.reset();
    },

    filterByTopic: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      var $li = $el.parent("li");
      $li.addClass("active").siblings().removeClass("active");
      this.topic = $el.data("id");
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
