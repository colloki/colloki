$(function() {
  window.VoteView = Backbone.View.extend({
    el: ".like-btn",
    count_el: ".vote-count",
    likers_el: "#story-likers",
    // -1: cannot vote, 0: not voted, 1: has voted
    state: 0,

    events: {
      "click": "vote"
    },

    initialize: function(data) {
      _.bindAll(this, 'render', 'vote', 'add', 'remove');

      this.count = data.count;
      this.state = data.state;
      this.story_id = data.story_id;
      this.user_id = data.user_id;
      this.user_login = data.user_login;
      this.user_email_hash = data.user_email_hash;

      this.collection = new Votes();
      if (this.state == 1) {
        var v = new Vote({id: data.id});
        this.collection.add(v);
      }

      this.render();
    },

    render: function() {
      $(this.count_el).html(this.count + " likes");
      if (this.state == -1) {
        $(this.el).attr("title", this.count + " likes")
        .addClass("disabled");
      }
      else if (this.state == 0) {
        $(this.el).attr("title", "Like")
        .removeClass("voted")
        .addClass("success");
      }
      else {
        $(this.el).attr("title", "Unlike")
        .addClass("voted")
        .addClass("success");
      }
      return this;
    },

    vote: function() {
      if (this.state == -1)
        return;
      if (this.state == 0)
        this.add();
      else
        this.remove();
    },

    // vote up
    add: function() {
      var v = new Vote();
      this.collection.add(v);
      var self = this;
      v.save({story_id: this.story_id}, {success: function(model, response) {
        $(self.likers_el).append(JST.story_liker({model: v.toJSON(),
          user_id: self.user_id,
          user_login: self.user_login,
          user_email_hash: self.user_email_hash,
          count: self.count,
          liked_by_exists: ($(self.likers_el+">h4").length == 1)}
        ));
      }});
      this.count ++;
      this.state = 1;
      this.render();
    },

    // vote down
    remove: function() {
      var self = this;
      this.collection.at(0).destroy({success: function(model, response) {
        $("#liker"+self.user_id).remove();
      }});
      this.count --;
      this.state = 0;
      this.render();
    }
  });
});