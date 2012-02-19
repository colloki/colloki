// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(e) {
  
  $(".topbar").dropdown();
  $(".has_popover").popover({
    placement: 'bottom',
    delay: 500
  });

  // Tooltips
  $(".has_tooltip").tooltip();
});
