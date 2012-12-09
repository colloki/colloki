$(function() {
  window.StoryListView = Backbone.View.extend({
    // Message to show if the response is empty
    emptyMessage: "We weren't able to find anything...You can see this <a href='/'>week's stories</a>",
    // If the current set of fetched stories is complete.
    complete: false,
    // Number of items fetched per page
    perPageCount: 12,
    isMapLoaded: false,
    // the different views
    types: {
      "user": {
        id: 1,
        header: "Shared by VTS Users"
      },

      "rss": {
        id: 2
      },

      "facebook": {
        id: 3,
        header: "Discussions on Facebook"
      },

      "twitter": {
        id: 4,
        header: "Discussions on Twitter"
      },

      "likes": {
        id: 5,
        header: "Your Likes"
      },

      "events": {
        id: 6
      },

      "following": {
        id: 7,
        header: "People You're Following <a class='who-to-follow' href='/whotofollow'>See who to follow</a>",
        empty: "There is no activity from the people you're following... See suggestions on <a href='/whotofollow'>who to follow</a>"
      },

      "by-user": {
        id: 8
      },

      "map": {
        id: 9
      }
    },

    events: {
      "click .source": "filterBySource",
      "click .date-range": "filterByDateRange",
      "touchstart.dropdown.data-api .date-range": "filterByDateRange",
      "click .topic": "filterByTopic",
      "touchstart.dropdown.data-api .topic": "filterByTopic",
      "click .type": "filterByType",
      "keyup .search-query": "filterByQuery",
      "click .sort": "sortBy",
      "click .hashtag": "filterByHashtag",
      "click .more": "nextPage",
      "click .search-cancel": "cancelSearch"
    },

    initialize: function() {
      _.bindAll(this,
        "preRender",
        "render",
        "append",

        "selectButton",
        "selectNavTab",
        "selectNavPill",

        "resetHeader",

        "sortBy",

        "filterBySource",
        "showSource",

        "filterByDateRange",
        "showDateRange",

        "filterByTopic",
        "showTopic",
        "resetTopic",

        "filterByType",
        "showType",

        "filterByQuery",
        "showQuery",
        "resetQuery",
        "cancelSearch",

        "filterByHashtag",
        "showHashtag",
        "resetHashtag",

        "showLikes",
        "showEvents",
        "showMap",

        "nextPage",
        "showLoading",
        "hideLoading",
        "showEmptyMessage");

      this.delegateEvents();
      this.collection = new Stories();

      this.$stories = this.$('.topic-stories');
      this.$header = this.$('.topic-header');
      this.$loading = this.$('.loading');
      this.$more = this.$('.more');
      this.$search = this.$('.search-query');
      this.$map = $(".map");

      this.filters = {
        $news: this.$(".filter-news-source"),
        $chatter: this.$(".filter-chatter"),
        $twitter: this.$(".filter-chatter-twitter"),
        $facebook: this.$(".filter-chatter-facebook"),
        $following: this.$(".filter-following"),
        $topic: this.$(".filter-topic"),
        $date: this.$(".filter-date"),
        $search: this.$(".filter-search"),
        $sort: this.$(".filter-sort"),
        $events: this.$(".filter-events")
      };

      this.paginationBufferPx = 50;
      this.isLoading = false;
      this.router = this.options.router;
      this.hashtag = "";
      this.resetToDefault();

      _.each(this.options, _.bind(function(value, key) {
        if (value) {
          this[key] = value;
        }
      }, this));

      this.eventsDate = moment().format('MM-DD-YYYY');

      this.$stories.imagesLoaded($.proxy(function() {
        this.$stories.masonry({
          itemSelector: ".story-item"
        });
      }, this));

      if (this.type == this.types["events"].id ||
        this.type == this.types["map"].id) {
        this.showType(this.type);
      } else {
        this.reset();
      }

      $('#datepicker').datepicker({
        autoclose: true,
        startDate: '-1d'
      }).on('changeDate', _.bind(function(event) {
        this.eventsDate = this.$datepickerField.val();
        this.showEvents();
      }, this));

      this.$datepickerField = $('.datepicker-field').val(this.eventsDate);

      Gmaps.map.callback = _.bind(function() {
        google.maps.event.addListenerOnce(Gmaps.map.map, 'idle', _.bind(function() {
          this.isMapLoaded = true;
          if (this.type == this.types["map"].id) {
            this.showType(this.type)
          }
        }, this));
      }, this);
    },

    // Show / hide the appropriate filters based on the current view
    // Gets called before rendering a view
    preRender: function() {
      if (this.type == this.types["rss"].id) {
        this.filters.$sort.show();
        this.filters.$date.show();
        this.filters.$news.show();
        this.filters.$chatter.hide();
        this.filters.$following.hide();
        this.filters.$events.hide();
        this.filters.$search.show();
        this.$map.hide();

        if (this.dateRange != 1 && this.source == -1 && !this.query) {
          this.filters.$topic.show();
        } else {
          this.filters.$topic.hide();
        }
      }

      else {
        this.filters.$topic.hide();
        this.filters.$news.hide();
        this.filters.$date.hide();
        this.filters.$sort.hide();

        if (this.type == this.types["events"].id) {
          this.filters.$events.show();
          this.filters.$search.hide();
        } else {
          this.filters.$events.hide();
          this.filters.$search.show();
        }

        if (this.type != this.types["map"].id) {
          this.$map.hide();
        }

        if (this.type == this.types["following"].id) {
          this.filters.$following.show();
        } else {
          this.filters.$following.hide();
        }

        if (this.type == this.types["twitter"].id ||
          this.type == this.types["facebook"].id) {
          this.filters.$date.show();
          this.filters.$chatter.show();

          if (this.type == this.types["twitter"].id) {
            this.filters.$twitter.show();
            this.filters.$facebook.hide();
          } else {
            this.filters.$twitter.hide();
            this.filters.$facebook.show();
          }
        } else {
          this.filters.$date.hide();
          this.filters.$chatter.hide();
        }
      }
    },

    // Render the page
    render: function(shouldRewriteURL) {
      this.hideLoading();

      if (this.type != this.types["rss"].id) {
        this.$stories.imagesLoaded($.proxy(function() {
          this.$stories.masonry('reload');
        }, this));
      }

      if (!isMobile.any()) {
        $(".has-tooltip").tooltip();
      }

      // if we are already at the end of the page, load the next page...
      setTimeout(_.bind(function() {
        if ($(document).height() == $(window).height() &&
          this.collection.length == 12) {
          this.nextPage();
        }
      }, this), 100);


      if (shouldRewriteURL) {
        this.router.rewriteURL(this);
      }

      this.$('.topic-stories').height(500);
    },

    // Append a story
    append: function(story) {
      var view = new StoryView({
        model: story
      });

      this.$stories.append(view.render().el);
    },

    // Load the next page
    nextPage: function() {
      if (this.complete) {
        return;
      }

      this.page++;
      this.preRender();
      this.$more.html("Loading...").attr('disabled', true);

      this.load($.proxy(function(data) {
        var len = data.length;
        if (len < this.perPageCount) {
          this.complete = true;
          this.$more.hide();
        }

        for (var i = 0; i < len; i++) {
          data[i].viewer = this.viewer;
          var c = new Story(data[i]);

          if (!this.collection.get(c.id)) {
            this.collection.add(c);
            this.append(c);
          }
        }

        this.render();
        this.isLoading = false;
        this.$more.html('More').attr('disabled', false);
      }, this));
    },

    // Reset the header of the page based on the current view
    // and the filter selections
    resetHeader: function() {
      var text;

      if (this.type == this.types["likes"].id) {
        text = this.types["likes"].header;
      } else if (this.type == this.types["following"].id) {
        text = this.types["following"].header;
      } else if (this.type == this.types["rss"].id) {

        if (this.dateRange == 4) {
          text = "This Week's Stories";
        } else if (this.dateRange == 2) {
          text = "Today's Stories";
        } else {
          text = "All Stories";
        }

        if (this.topic != -2) {
          text += " - " + $($(".topic[data-id="+ this.topic + "]").get(0)).text();
        } else if (this.source != -1) {
          text += " - " + this.source;
        } else if (this.query) {
          text += " - Search results for '" + this.query + "'";
        } else {
          text += " - [ Everything ]";
        }
      } else if (this.type == this.types["twitter"].id) {
        text = this.types["twitter"].header;
        if (this.query) {
          text += " - Search results for '" + this.query + "'";
        } else if (this.hashtag) {
          text += " - #" + this.hashtag;
        }
      } else if (this.type == this.types["facebook"].id) {
        text = this.types["facebook"].header;
        if (this.query) {
          text += " - Search results for '" + this.query + "'";
        } else if (this.source != -1) {
          text += " - " + this.source;
        }
      } else if (this.type == this.types["user"].id) {
        text = this.types["user"].header;
      }

      this.$header.html(text);
    },

    // Reset the view
    reset: function(shouldRewriteURL) {
      this.page = 1;
      this.complete = false;

      if (this.type != this.types["rss"].id) {
        if (this.type != this.types["twitter"].id &&
          this.type != this.types["facebook"].id) {
          this.resetQuery();
        }

        if (this.type != this.types["facebook"].id) {
          this.resetSource();
        }

        this.resetTopic();
      }

      // select the right filtering options
      this.selectNavPill($(".source[data-value='" + this.source + "']"));
      this.selectNavPill($(".topic[data-id=" + this.topic + "]"));
      this.selectNavPill($(".sort[data-value=" + this.sort + "]"));
      this.selectNavPill($(".date-range[data-value='" + this.dateRange + "']"));
      this.selectNavPill($(".hashtag[data-value='" + this.hashtag + "']"));
      if (this.type == 3) {
        this.selectNavPill($(".type[data-value='4']"));
      }
      this.selectNavPill($(".type[data-value='" + this.type + "']"));

      if (this.query) {
        $(".search-query", this.$el).val(this.query);
      }

      // set up for loading
      this.resetHeader();
      this.showLoading();
      this.preRender();

      this.load($.proxy(function(data) {
        // TODO: Get rid of this ugliness.
        this.collection.reset();
        this.$stories.html("");

        var len = data.length;
        if (len != 0) {
          for (var i = 0; i < len; i++) {
            data[i].viewer = this.viewer;
            var c = new Story(data[i]);
            this.collection.add(c);
            this.append(c);
          }
        } else {
          this.showEmptyMessage();
        }

        if (len < this.perPageCount) {
          this.complete = true;
          this.$more.hide();
        }

        this.isLoading = false;
        this.render(shouldRewriteURL);
      }, this));
    },

    // Load the page
    load: function(callback) {
      this.isLoading = true;

      var request = "/search.json?query=" + this.query +
        "&hashtag=" + this.hashtag +
        "&range=" + this.dateRange +
        "&page=" + this.page +
        "&topic=" + this.topic +
        "&type=" + this.type +
        "&sort=" + this.sort +
        "&source=" + this.source;

      if (this.user) {
        request += "&user_id=" + this.user.id;
      }

      this.preRender();
      $.getJSON(request, callback);
    },

    // Select a button
    selectButton: function($el) {
      $el.addClass("active").siblings().removeClass("active");
    },

    // Select a nav tab
    selectNavTab: function($el) {
      var $li = $el.parents("li");

      $li.addClass("active")
        .siblings().removeClass("active");
    },

    // Select a nav pill
    selectNavPill: function($el) {
      var $li = $el.parent("li");
      $li.addClass("active")
        .find("i").addClass("icon-white")
        .end()
        .siblings().removeClass("active")
        .find("i").removeClass("icon-white");
    },

    // Change the sorting option between popularity and date
    sortBy: function(event) {
      event.preventDefault();

      var $el = $(event.target);
      this.selectNavPill($el);
      this.sort = $el.data("value");
      this.reset(true);
    },

    // Change the date range i.e. today, this week, all.
    filterByDateRange: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.showDateRange($el.data("value"), true);
    },

    // Show the date filter
    showDateRange: function(dateRange, shouldRewriteURL) {
      this.dateRange = dateRange;
      this.reset(shouldRewriteURL);
    },

    // Change the topic
    filterByTopic: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.resetSource();
      this.resetQuery();
      this.showTopic($el.data("id"), true);
      // Hide the topic's popover so that the user can see the stories under it
      $(".popover").remove();
    },

    // Show the stories belonging to the specified topic
    showTopic: function(topic, shouldRewriteURL) {
      this.topic = topic;
      this.reset(shouldRewriteURL);
    },

    // Resets the topic to "Everything"
    resetTopic: function() {
      this.topic = -2;
    },

    // Filter by news source
    filterBySource: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.resetTopic();
      this.resetQuery();
      this.showSource($(event.target).data("value"), true);
    },

    // Show stories belonging to the specified news/facebook source
    showSource: function(source, shouldRewriteURL) {
      this.source = source;
      this.reset(shouldRewriteURL);
    },

    resetSource: function() {
      this.source = -1;
    },

    filterByType: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      if (!$el.hasClass("type")) {
        $el = $el.parents(".type");
      }

      this.showType($el.data("value"), true);
    },

    showType: function(type, shouldRewriteURL) {
      this.type = type;
      this.source = -1;

      if (this.type == this.types["events"].id) {
        this.showEvents(shouldRewriteURL);
      } else if (this.type == this.types["map"].id) {
        this.showMap(shouldRewriteURL);
      } else if (this.type == this.types["likes"].id) {
        this.showLikes(shouldRewriteURL);
      } else {
        this.reset(shouldRewriteURL);
      }
    },

    resetQuery: function() {
      this.query = "";
      this.$search.val("");
    },

    cancelSearch: function() {
      this.resetQuery();
      this.dateRange = 4;
      this.reset(true);
    },

    filterByQuery: function(event) {
      if (event.keyCode === 27 || this.$search.val() === "") {
        event.preventDefault();
        this.cancelSearch();
      } else if (event.keyCode === 13) {
        event.preventDefault();
        this.dateRange = 1;
        this.resetTopic();
        this.resetHashtag();
        this.resetSource();
        this.showQuery(this.$search.val());
      }
    },

    showQuery: function(query, shouldRewriteURL) {
      this.query = query;
      this.reset(shouldRewriteURL);
    },

    filterByHashtag: function(event) {
      event.preventDefault();
      var $el = $(event.target);
      this.showHashtag($el.data("value"));
    },

    showHashtag: function(hashtag) {
      this.hashtag = hashtag;
      this.reset(false);
    },

    resetHashtag: function() {
      this.hashtag = "";
    },

    // Show the Likes tab
    showLikes: function(shouldRewriteURL) {
      this.reset(shouldRewriteURL);
    },

    // Show the Events tab
    showEvents: function(shouldRewriteURL) {
      var parsedEventsDate = moment(this.eventsDate, "MM-DD-YYYY");
      this.$header.html('Events for ' + parsedEventsDate.format('MMMM Do YYYY'));
      this.preRender();
      this.selectNavPill($(".type[data-value='" + this.type + "']"));
      this.$stories.html('');
      this.showLoading();

      Events.render(parsedEventsDate.format('YYYY-MM-DD'), _.bind(function() {
        this.render(shouldRewriteURL);
        this.$more.hide();
      }, this));
    },

    // Show the Map tab
    showMap: function(shouldRewriteURL) {
      this.$header.html('Map of stories');
      this.preRender();
      this.selectNavPill($(".type[data-value='" + this.type + "']"));
      this.$stories.html('');
      this.showLoading();
      if (this.isMapLoaded) {
        Map.render(_.bind(function() {
          this.render(shouldRewriteURL);
          this.$more.hide();
        }, this));
      }
    },

    // Reset filters to the default
    resetToDefault: function() {
      this.dateRange = 4;
      this.query = "";
      this.page = 1;
      this.type = this.types["rss"].id;
      this.sort = 1;
      this.topic = -2;
      this.source = -1;
    },

    // Show the loading message
    showLoading: function() {
      this.$stories.hide();
      this.$more.hide();
      this.$loading.show();
    },

    // Hide the loading message
    hideLoading: function() {
      this.$stories.show();
      if (!this.complete) {
        this.$more.show();
      }

      this.$loading.hide();
    },

    // Show a message indicating nothing was found for the current
    // set of filters
    showEmptyMessage: function() {
      var $message = $("<p>", {
        "class": "lead empty-message"
      });

      var emptyForType;

      _.each(this.types, _.bind(function(type) {
        if (type.id == this.type) {
          if (type.empty) {
            emptyForType = type.empty;
          }
        }
      }, this));

      if (emptyForType) {
        $message.html(emptyForType);
      } else {
        $message.html(this.emptyMessage);
      }

      this.$stories.html($message);
    }
  });
});


var Events = {
  template: JST['app/templates/events'],

  render: function(date, callback) {
    $.getJSON('/events.json?date=' + date, function(events) {
      _.each(events, function(eventgroup) {
        var prettytime = moment(eventgroup[0].dtstart).format('h:mm a');
        $('.topic-stories').append(Events.template({
          events: eventgroup,
          time: prettytime
        }));
      });

      callback();
    });
  }
}

var Map = {
  render: function(callback) {
    $.getJSON('/map.json', function(markers) {
      Gmaps.map.replaceMarkers(markers);
      $('.map').show();
      google.maps.event.trigger(Gmaps.map.map, "resize");
      Gmaps.map.adjustMapToBounds();
      callback();
    });
  }
}
