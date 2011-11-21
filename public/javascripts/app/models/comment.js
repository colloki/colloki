$(function() {
  window.Comment = Backbone.Model.extend({
    rootUrl: '/comments',

    validate: function(attrs) {
      if (attrs.body === "") {
        return "Comment cannot be empty";
      }
    }
  });
});