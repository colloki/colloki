$(function() {
  window.CommentsListView = Backbone.View.extend({
    el: $("#comments"),

    events: {
      "click #add-comment": "add"
    },

    initialize: function(data) {
      _.bindAll(this, 'render', 'add', 'addAll', 'append', 'remove');

      this.input = this.$("#comment_body");
      this.story_id = this.$("#comment_story_id").val();

      this.collection = new Comments();
      this.collection.bind('reset', this.addAll);
      this.collection.bind('destroy', this.remove);
      this.count = 0;

      // todo: for some reason, collection.reset is not working. that'll be more elegant here
      for (var i = 0; i < data.length; i++) {
        var c = new Comment(data[i]);
        this.collection.add(c);
        this.append(c);
      }
    },

    render: function() {
      // Update the comment count
      var html = this.count + " Comment";
      if (this.count != 1)
        html += "s";
      this.$("#comment-count").html(html);
    },

    // Save a new comment
    add: function(attribs) {
      var c = new Comment();
      var self = this;
      self.collection.add(c);
      c.save({ body: this.input.val(), story_id: this.story_id }, { success: function(c, response) {
        self.append(c);
      }});
    },

    // Add all comments in collection to UI
    addAll: function() {
      this.collection.each(this.append);
    },

    // Add single comment to UI
    append: function(comment) {
      var view = new CommentView({ model: comment });
      $('.comment-entries', this.el).append(view.render().el);
      this.input.val('').focus();
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