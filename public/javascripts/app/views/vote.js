$(function() {
  window.VoteView = Backbone.View.extend({
    el        : ".like-btn",
    count_el  : ".vote-count",
    likers_el : "#story-likers",

    events: {
      "click": "vote"
    },

    initialize: function(data) {
      _.bindAll(this, 'render', 'vote', 'add', 'remove');
      this.data = data;

      if (this.data.state == 1)
        this.model = new Vote({id: this.data.id});

      this.render();
    },

    render: function() {
      $(this.count_el).html(this.data.count + " likes");

      if (this.data.state == -1) {
        $(this.el).attr("title", this.data.count + " likes")
        .addClass("disabled");
      }
      else if (this.data.state == 0) {
        $(this.el).attr("title", "Like")
        .removeClass("voted")
        .addClass("btn-success");
      }
      else {
        $(this.el).attr("title", "Unlike")
        .addClass("voted")
        .addClass("btn-success");
      }
      return this;
    },

    vote: function() {
      if (this.data.state == -1)
        return;
      if (this.data.state == 0)
        this.add();
      else
        this.remove();
    },

    // vote up
    add: function() {
      this.model = new Vote();
      var self = this;
      this.model.save({story_id: this.data.story_id}, {success: function(model, response) {
        if ($("#liker" + self.data.user_id).length == 0) {
          $(self.likers_el).append(JST.story_liker({
            data: self.data,
            liked_by_exists: ($(self.likers_el + " > h4").length == 1)
          }));
        }
      }});
      this.data.count ++;
      this.data.state = 1;
      this.render();
    },

    // vote down
    remove: function() {
      var self = this;
      this.model.destroy({success: function(model, response) {
        $("#liker" + self.data.user_id).remove();
      }});
      this.data.count --;
      this.data.state = 0;
      this.render();
    }
  });
});