$(function() {
  window.StoryView = Backbone.View.extend({
    template: JST['app/templates/story_item'],

    textLength: 100,
    textLengthWithoutImage: 200,

    initialize: function() {
      _.bindAll(this, "render", "transformData", "formatText");
    },

    transformData: function(story) {
      // Icon src. If it is a user post, set icon to user's gravatar.
      if (story.kind === 1) {
        story.icon_src = "http://gravatar.com/avatar/" + story.user_email_hash + ".jpg?s=26";
        story.icon_url = "/users/" + story.user.login;
      } else {
        story.icon_src = "http://www.google.com/s2/favicons?domain_url=" + story.url;
        story.icon_url = story.source_url;
      }

      if (story.description) {
        story.description = this.formatText(story);
      }

      // If it is a tweet, linkify @author and #hashtags
      if (story.kind === 4) {
        story.title = this.formatTweet(story.title);
      }

      if (story.published_at) {
        story.pretty_timestamp = moment(story.published_at).fromNow();
      } else {
        story.pretty_timestamp = moment(story.created_at).fromNow();
      }

      return story;
    },

    formatText: function(story) {
      var text = $.trim(story.description.replace(/(<([^>]+)>)/ig,""));

      var length;
      if (story.image_src) {
        length = this.textLength;
      } else {
        length = this.textLengthWithoutImage;
      }

      if (text.length > length) {
        text = text.substring(0, length) + "...";
      }

      return this.replaceURLWithHTMLLinks(text);
    },

    // http://stackoverflow.com/questions/37684/how-to-replace-plain-urls-with-links
    replaceURLWithHTMLLinks: function(text) {
      var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
      return text.replace(exp,"<a href='$1'>$1</a>");
    },

    formatTweet: function(tweet) {
      tweet = tweet.replace(/(^|\s)@(\w+)/g, '$1@<a href="http://www.twitter.com/$2">$2</a>');
      tweet = tweet.replace(/(^|\s)#(\w+)/g, '$1#<a href="http://search.twitter.com/search?q=%23$2">$2</a>');
      return this.replaceURLWithHTMLLinks(tweet);
    },

    render: function() {
      var story = this.transformData(this.model.toJSON());
      this.$el.html(this.template(story));

      this.likeView = new LikeView({
        el: $(".like-btn", this.$el),
        story: this.model.attributes,
        votes: this.model.attributes.votes,
        viewer: this.model.attributes.viewer
      });

      return this;
    }
  });
});
