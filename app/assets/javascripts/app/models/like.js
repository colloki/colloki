$(function() {
  window.Like = Backbone.Model.extend({
    urlRoot: gon.app_url + 'votes'
  });
});
