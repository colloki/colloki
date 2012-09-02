$(function() {
  window.StoryListView = Backbone.View.extend({
    events: {
      //
    },

    initialize: function() {
      _.bindAll(this, "render", "append");
      this.delegateEvents();
      this.collection = new Stories();

      // TODO: for some reason, collection.reset doesn't work here.
      var len = this.options.data.length;
      for (var i = 0; i < len; i++) {
        this.options.data[i].current_user = this.options.current_user;
        var c = new Story(this.options.data[i]);
        this.collection.add(c);
        this.append(c);
      }

      this.$el.imagesLoaded($.proxy(function() {
        this.$el.masonry({
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

      this.$el.append(view.render().el);
      this.render();
    }
  });
});
