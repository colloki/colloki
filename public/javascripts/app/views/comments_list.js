$(function() {
  window.CommentsListView = Backbone.View.extend({
    events: {
      "click .add-comment": "add"
    },

    initialize: function() {
      _.bindAll(this, 'render', 'add', 'addAll', 'append', 'remove');

      this.$count   = this.$el.find('.comment-count');
      this.$input   = this.$el.find('.comment-body');
      this.$entries = this.$el.find('.comment-entries');

      this.delegateEvents();

      this.collection = new Comments();
      this.collection.bind('reset', this.addAll);
      this.collection.bind('destroy', this.remove);
      this.count = 0;

      // TODO: for some reason, collection.reset is not working. 
      // that'll be more elegant here
      for (var i = 0; i < this.options.data.length; i++) {
        var c = new Comment(this.options.data[i]);
        this.collection.add(c);
        this.append(c);
      }
    },

    render: function() {
      // Update the comment count
      var html = this.count + " Comment";
      if (this.count != 1)
        html += "s";
      this.$count.html(html);
    },

    // Save a new comment
    add: function(e) {
      e.preventDefault();
      var c = new Comment();
      var self = this;
      self.collection.add(c);
      c.save({ 
        body: this.$input.val(),
        story_id: this.options.story_id
      }, {
        success: function(c, response) {
          self.append(c);
        }
      });
    },

    // Add all comments in collection to UI
    addAll: function() {
      this.collection.each(this.append);
    },

    // Add single comment to UI
    append: function(comment) {
      var view = new CommentView({
        model: comment,
        user_id: this.options.user_id
      });

      this.$entries.append(view.render().el);
      this.$input.val('');
      this.count ++;
      this.render();
    },

    // Remove comment from UI
    remove: function() {
      this.count --;
      this.render();
    }
  });
});