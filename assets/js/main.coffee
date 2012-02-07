#= require 'lib/underscore.js'
#= require 'lib/backbone.js'

###
Defaults

###
$.ajaxSetup
  type: 'POST'
  contentType: 'application/json'



$ ->

  ###
  Navigation

  Make the correct/active link in the navigation "active".
  ###
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
