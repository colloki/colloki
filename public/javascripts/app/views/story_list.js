$(function() {
  window.StoryListView = Backbone.View.extend({
    events: {
      "click .source": "filterBySource"
    },

    initialize: function() {
      _.bindAll(this, "render", "append", "filterBySource");
      this.delegateEvents();
      this.collection = new Stories();
      this.$stories = $(".topic-stories", this.$el);

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

    filterBySource: function(event) {
      var query = $(event.target).data("value");
      $.getJSON("/search.json?query=" + query, $.proxy(function(data) {
        console.log(data);
        this.collection.reset();
        this.$stories.html("");
        var len = data.length;
        for (var i = 0; i < len; i++) {
          data[i].current_user = this.options.current_user;
          var c = new Story(data[i]);
          this.collection.add(c);
          this.append(c);
        }
      }, this));
    }
  });
});
