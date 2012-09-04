$(function() {
  window.StoryView = Backbone.View.extend({
    textLength: 200,

    events: {
    },

    initialize: function() {
      _.bindAll(this, "render");
    },

    transformData: function(story) {
      // Icon src. If it is a user post, set icon to user's gravatar.
      if (story.kind === 1) {
        story.icon_src = "http://gravatar.com/avatar/" + story.user_email_hash + ".jpg?s=26";
        story.icon_url = "/users/" + story.user.id;
      } else {
        story.icon_src = "http://www.google.com/s2/favicons?domain_url=" + story.url;
        story.icon_url = story.source_url;
      }

      if (story.title) {
        story.title = story.title.replace(/(<([^>]+)>)/ig,"");
        story.title = jQuery.trim(story.title).substring(0, this.textLength) + "...";
      }

      if (story.description) {
        story.description = story.description.replace(/(<([^>]+)>)/ig,"");
        story.description = jQuery.trim(story.description).substring(0, this.textLength) + "...";
      }

      if (story.published_at) {
        story.pretty_timestamp = moment(story.published_at).fromNow();
      } else {
        story.pretty_timestamp = moment(story.created_at).fromNow();
      }

      return story;
    },

    render: function() {
      var story = this.transformData(this.model.toJSON());
      this.$el.html(
        JST['topics/story'](story)
      );

      this.likeView = new LikeView({
        el: $(".like-btn", this.$el),
        story: this.model.attributes
      });

      return this;
    }
  });
});
