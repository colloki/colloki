$(function() {
  window.FollowView = Backbone.View.extend({
    events: {
      "click": "update"
    },

    initialize: function() {
      _.bindAll(this, 'update', 'follow', 'unfollow');
      this.user = this.options.user;
      this.viewer = this.options.viewer;
      this.following = this.options.following;
      this.model = new Follow();
      this.render();
    },

    render: function() {
      if (!this.viewer) {
        this.$el
          .addClass("disabled")
          .attr("title", "Log In to follow this user");
      } else if (this.viewer.id == this.user.id) {
        this.$el.hide();
      } else if (this.following) {
        this.$el.removeClass("btn-success")
          .addClass("btn-danger")
          .html("Unfollow");
      } else {
        this.$el.removeClass("btn-danger")
          .addClass("btn-success")
          .html("Follow");
      }
    },

    update: function() {
      if (this.following) {
        this.unfollow();
      } else {
        this.follow();
      }
    },

    follow: function() {
      this.following = true;
      this.model.save({
        user_id: this.user.id
      });
      this.render();
    },

    unfollow: function() {
      this.following = false;
      this.model.unfollow({
        user_id: this.user.id
      });
      this.render();
    }
  });
});
