# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->  
  $("#modal-messages-history").dialog
    width: 850
    modal: true
  $("#modal-messages-history").dialog("close").css "height", "750px"
