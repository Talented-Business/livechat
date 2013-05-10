# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->  
  $("input:checkbox").each ->
    t = $(this)
    t.wrap "<span class=\"checkbox\"></span>"
    if $(this).is(":checked")
      t.prop "checked", true
      t.parent().addClass "checked"
    else
      t.prop "checked", false
      t.parent().removeClass "checked"    
  $('#tabs').tabs()
  $("#modal-reminder").dialog
    width: 550
    modal: true
  $("#modal-reminder").dialog("close").css "height", "550px"
