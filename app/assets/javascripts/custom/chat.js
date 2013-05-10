jQuery(document).ready(function(){

	jQuery('.chatsearch input').bind('focusin focusout',function(e){
		if(e.type == 'focusin') {
			if(jQuery(this).val() == 'Search') jQuery(this).val('');	
		} else {
			if(jQuery(this).val() == '') jQuery(this).val('Search');	
		}
	});
	
	jQuery('.messagebox button').click(function(){
		enterMessage();
	});
	
	jQuery('.messagebox textarea').keypress(function(e){
		if(e.which == 13){
      enterMessage();
      $("#new_chat_message").submit();
    }
			
	});
  $('#new_chat_message').on('ajax:beforeSend', function(event, xhr, settings) {
    $('.messagebox textarea#chat_message_message').val('');
  });	
	function enterMessage() {
		var msg = jQuery('.messagebox textarea#chat_message_message').val();			
		if(msg != '') {
			jQuery('#chatmessageinner').append('<p><strong>You:</strong> '+msg+'</p>');
			jQuery("#chatmessage").animate({scrollTop: jQuery("#chatmessage").prop("scrollHeight")});
		}	
	}
	
});
