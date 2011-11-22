// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(e) {
  $(".topbar").dropdown();
  $(".like-count, .comment-count, .like-btn").twipsy({
    animate: false,
    delayIn: 10
  });
  $(".story-liker").twipsy({
    animate: false,
    delayIn: 10,
    placement: 'below'
  });
});

