$(function() {
  window.Comments = Backbone.Collection.extend({
    model: Comment,
    url: '/comments'
  });
});