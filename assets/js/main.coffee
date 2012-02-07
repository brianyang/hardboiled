#= require 'lib/jquery-1.7.1.min.js'
#= require 'lib/underscore.js'
#= require 'lib/knockout-2.0.0.js'

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
