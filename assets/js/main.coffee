#= require 'lib/underscore.js'


$.ajaxSetup
  type: 'POST'
  contentType: 'application/json'



$ ->
  $navbar = $ '.navbar'
  $navbar.each ->
    pathname = document.location.pathname
    $nav_li = $(this).find '.nav li'
    $nav_li.each ->
      $t = $ this
      href = $t.find('a').attr 'href'
      if href is pathname
        $nav_li.removeClass 'active'
        $t.addClass 'active'
