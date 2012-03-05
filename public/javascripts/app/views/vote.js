$(function() {
  window.VoteView = Backbone.View.extend({

    events: {
      "click": "vote"
    },

    initialize: function() {
      _.bindAll(this, 'render', 'vote', 'add', 'remove');

      this.$count   = this.$el.find(".like-count");
      this.$star    = this.$el.find("i");
      this.$likers  = $("#story-likers");
      this.$liker   = $("#story-liker" + this.options.user.id);

      if (this.options.state == 1) {
        this.model = new Vote({
          id: this.options.id
        });
      }

      this.delegateEvents();
      this.render();
    },

    setTitle: function(title) {
      this.$el
      .attr('data-original-title', title);
    },

    render: function() {
      this.$count.html(this.options.count);

      if (this.options.state == -2) {
        this.setTitle(this.options.count + " likes. Sign In to Like.");
        this.$el.addClass("disabled");
      }

      else if (this.options.state == -1) {
        this.setTitle(this.options.count + " likes");
        this.$el.addClass("disabled");
      }

      else if (this.options.state == 0) {
        this.setTitle("Like");
        this.$star
        .removeClass('icon-star')
        .addClass('icon-star-empty');
      }

      else {
        this.setTitle("Unlike");
        this.$star
        .removeClass('icon-star-empty')
        .addClass('icon-star');
      }

      return this;
    },

    vote: function() {
      if (this.options.state == -1)
        return;
      if (this.options.state == 0)
        this.add();
      else
        this.remove();
    },

    // vote up
    add: function() {
      this.model = new Vote();
      var self = this;
      this.model.save({
        story_id: this.options.story_id}, {
        success: function(model, response) {
          if (!this.$liker || this.$liker.length == 0) {
            self.$likers.append(JST.story_liker({
              count: self.options.count,
              user: self.options.user,
              gravatar_url: get_gravatar_url(self.options.user.email, 24),
              exists: self.$likers.find("h4").length == 1
            }));
          }
        }
      });

      this.options.count ++;
      this.options.state = 1;
      this.render();
    },

    // vote down
    remove: function() {
      var self = this;
      this.model.destroy({success: function(model, response) {
        this.$liker.remove();
      }});

      this.options.count --;
      this.options.state = 0;
      this.render();
    }
  });
});