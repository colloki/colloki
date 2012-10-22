$(function() {
  window.Story = Backbone.Model.extend({
    urlRoot: gon.app_url + 'stories'
  });
});
