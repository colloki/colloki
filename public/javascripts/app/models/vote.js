$(function() {
  window.Vote = Backbone.Model.extend({
    urlRoot: APP_ROOT_PATH + 'votes'
  });
});