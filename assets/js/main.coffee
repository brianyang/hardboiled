#= require 'lib/jquery-1.7.1.min.js'
#= require 'lib/underscore.js'
#= require 'lib/backbone.js'
#= require 'lib/mustache.js'

###
Defaults

###
$.ajaxSetup
  type: 'POST'
  contentType: 'application/json'

###
jQuery Document Ready

Anything that messes with the dom needs to start after here
###
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

  ###
  Todo list

  ###


  $todoapp = $ '#todoapp'
  if $todoapp.length

    TodoSync = (method, model, options) ->

      now.Todo_call method, model.attributes, (result) ->
        options.success result

    window.Todo = Backbone.Model.extend
      idAttribute: "_id"

      defaults: ->
        done: false
        order: Todos.nextOrder()

      toggle: ->
        @save done: not @get("done")
      
      sync: TodoSync
    
    window.TodoList = Backbone.Collection.extend
      model: Todo
      done: ->
        @filter (todo) ->
          todo.get "done"

      remaining: ->
        @without.apply this, @done()

      nextOrder: ->
        return 1  unless @length
        @last().get("order") + 1

      comparator: (todo) ->
        todo.get "order"
      
      sync: TodoSync
    
    window.TodoView = Backbone.View.extend
      tagName: "li"
      template: _.template($("#item-template").html())
      events:
        "click .check": "toggleDone"
        "dblclick div.todo-text": "edit"
        "click span.todo-destroy": "clear"
        "keypress .todo-input": "updateOnEnter"

      initialize: ->
        @model.bind "change", @render, this
        @model.bind "destroy", @remove, this

      render: ->
        $(@el).html @template(@model.toJSON())
        @setText()
        this

      setText: ->
        text = @model.get("text")
        @$(".todo-text").text text
        @input = @$(".todo-input")
        @input.bind("blur", _.bind(@close, this)).val text

      toggleDone: ->
        @model.toggle()

      edit: ->
        $(@el).addClass "editing"
        @input.focus()

      close: ->
        @model.save text: @input.val()
        $(@el).removeClass "editing"

      updateOnEnter: (e) ->
        @close()  if e.keyCode is 13

      remove: ->
        $(@el).remove()

      clear: ->
        @model.destroy()
    
    window.AppView = Backbone.View.extend
      el: $todoapp
      statsTemplate: _.template($("#stats-template").html())
      events:
        "keypress #new-todo": "createOnEnter"
        "keyup #new-todo": "showTooltip"
        "click .todo-clear a": "clearCompleted"

      initialize: ->
        @input = @$("#new-todo")
        Todos.bind "add", @addOne, this
        Todos.bind "reset", @addAll, this
        Todos.bind "all", @render, this
        Todos.fetch()

      render: ->
        @$("#todo-stats").html @statsTemplate(
          total: Todos.length
          done: Todos.done().length
          remaining: Todos.remaining().length
        )

      addOne: (todo) ->
        view = new TodoView(model: todo)
        $("#todo-list").append view.render().el

      addAll: ->
        Todos.each @addOne

      createOnEnter: (e) ->
        text = @input.val()
        return  if not text or e.keyCode isnt 13
        Todos.create text: text
        @input.val ""

      clearCompleted: ->
        _.each Todos.done(), (todo) ->
          todo.destroy()

        false

      showTooltip: (e) ->
        tooltip = @$(".ui-tooltip-top")
        val = @input.val()
        tooltip.fadeOut()
        clearTimeout @tooltipTimeout  if @tooltipTimeout
        return  if val is "" or val is @input.attr("placeholder")
        show = ->
          tooltip.show().fadeIn()

        @tooltipTimeout = _.delay(show, 1000)
    
    now.ready () ->

      now.Todo_reset = (todos) ->
        Todos.reset todos

      now.Todo_add = (todo) ->
        Todos.add todo

      now.Todo_set = (todo) ->
        Todos.get(todo._id).set todo
      
      now.Todo_remove = (todo) ->
        Todos.get(todo._id).destroy()
      
      unless window.Todos
        window.Todos = new TodoList
        window.App = new AppView