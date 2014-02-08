'use strict';

$(function () {
  var pathname = location.pathname;
  $('#menu li a').each(function (index, element) {
    if (element.pathname === pathname) {
      $(element).parent().addClass('active');
    }
  });
});
