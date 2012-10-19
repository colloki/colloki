$(function() {
  window.Comment = Backbone.Model.extend({
    urlRoot: APP_ROOT_PATH + 'comments',

    validate: function(attrs) {
      if (attrs.body === "") {
        return "Comment cannot be empty";
      }
    }
  });
});