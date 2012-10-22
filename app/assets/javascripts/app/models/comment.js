$(function() {
  window.Comment = Backbone.Model.extend({
    urlRoot: gon.app_url + 'comments',

    validate: function(attrs) {
      if (attrs.body === "") {
        return "Comment cannot be empty";
      }
    }
  });
});
