$(function() {
  window.Votes = Backbone.Collection.extend({
    model: window.Vote,
    url: '/votes'
  });
});