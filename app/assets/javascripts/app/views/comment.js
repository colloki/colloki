$(function() {
  window.CommentView = Backbone.View.extend({
    template: JST['app/templates/comment'],

    events: {
      "click .delete-comment": "clear"
    },

    initialize: function() {
      _.bindAll(this, 'render', 'clear', 'remove');
    },

    render: function() {
      var pretty_timestamp = moment(this.model.attributes.created_at).fromNow();

      this.$el.html(
        this.template({
          model: this.model.toJSON(),
          image_url: get_user_image_url(this.model.attributes.user),
          pretty_timestamp: pretty_timestamp,
          user_id: this.options.user_id
        })
      );

      return this;
    },

    clear: function() {
      var self = this;
      this.model.destroy({success: function() {
        self.remove();
      }});
    },

    remove: function() {
      $(this.el).remove();
    }
  });
});
