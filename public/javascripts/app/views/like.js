$(function() {
  window.LikeView = Backbone.View.extend({

    events: {
      "click": "like"
    },

    initialize: function() {
      _.bindAll(this, 'render', 'like', 'add', 'remove');

      this.story = this.options.story;
      this.user = this.story.current_user;
      this.votes = this.story.votes;
      this.count = this.votes.length;

      if (!this.user) {
        this.state = -2;
      } else if (this.story.user && this.story.user.id === this.user.id) {
        this.state = -1;
      } else {
        this.state = 0;

        for (var i = 0; i < this.count; i++) {
          if (this.votes[i].user_id === this.user.id) {
            this.state = 1;
            this.vote = this.votes[i];
            break;
          }
        }
      }

      this.$count = $(".like-count", this.$el);
      this.$star = $("i", this.$el);
      this.$likers = $("#story-likers");
      if (this.user) {
        this.$liker = $("#story-liker" + this.user.id);
      }

      if (this.state === 1) {
        this.model = new Like({
          id: this.vote.id
        });
      }

      this.delegateEvents();
      this.render();
    },

    setTitle: function(title) {
      this.$el.attr('data-original-title', title);
    },

    render: function() {
      this.$count.html(this.count);

      if (this.state === -2) {
        this.setTitle(this.count + " likes. Sign In to Like.");
        this.$el.addClass("disabled");
      }

      else if (this.state === -1) {
        this.setTitle(this.count + " likes");
        this.$el.addClass("disabled");
      }

      else if (this.state === 0) {
        this.setTitle("Like");
        this.$star.removeClass('icon-star').addClass('icon-star-empty');
      }

      else {
        this.setTitle("Unlike");
        this.$star.removeClass('icon-star-empty').addClass('icon-star');
      }

      return this;
    },

    like: function() {
      if (this.state === -1) {
        return;
      } else if (this.state === 0) {
        this.add();
      } else {
        this.remove();
      }
    },

    add: function() {
      this.model = new Like();

      var self = this;

      this.model.save({
        story_id: this.story.id}, {
        success: function(model, response) {
          if (!this.$liker || this.$liker.length === 0) {
            self.$likers.append(JST.story_liker({
              count: self.count,
              user: self.user,
              gravatar_url: get_gravatar_url(self.user.email, 24),
              exists: self.$likers.find("h4").length == 1
            }));
          }
        }
      });

      this.count++;
      this.state = 1;
      this.render();
    },

    remove: function() {
      var self = this;

      this.model.destroy({success: function(model, response) {
        this.$liker.remove();
      }});

      this.count--;
      this.state = 0;
      this.render();
    }
  });
});
