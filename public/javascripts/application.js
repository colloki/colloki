// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(e) {
  $(".topbar").dropdown();
  $(".like-count, .comment-count, .story-like").twipsy({
    animate: false,
    delayIn: 10
  });
});