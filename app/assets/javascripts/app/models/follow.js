$(function() {
  window.Follow = Backbone.Model.extend({
    urlRoot: gon.app_url + 'follows',

    unfollow: function(data) {
      $.post(this.urlRoot + '/unfollow', data, function(){});
    }
  });
});
