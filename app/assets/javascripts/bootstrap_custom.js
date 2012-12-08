// Hack to make dropdowns work on mobile devices
// https://github.com/twitter/bootstrap/commit/ed74992853054c57f33ef5d21941f0869e287552
$(document).on('touchstart.dropdown.data-api', '.dropdown-menu', function (e) { e.stopPropagation(); })
