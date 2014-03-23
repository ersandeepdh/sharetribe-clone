$(function(){

  $(".default_card").click(function(){
    $.post($(this).attr("data-url"), function(data){
      console.log(data);
    })
  })

  $("a#add-new-card-link").fancybox({
    maxWidth  : 700,
    maxHeight : 300,
    fitToView : false,
    width   : '70%',
    height    : '70%',
    autoSize  : false,
    closeClick  : false,
    openEffect  : 'none',
    closeEffect : 'none'
  });

  $("a#edit-card-link").fancybox({
    maxWidth  : 700,
    maxHeight : 300,
    fitToView : false,
    width   : '70%',
    height    : '70%',
    autoSize  : false,
    closeClick  : false,
    openEffect  : 'none',
    closeEffect : 'none'
  });

  function mod10_check(val){ var nondigits = new RegExp(/[^0-9]+/g); var number = val.replace(nondigits,''); var pos, digit, i, sub_total, sum = 0; var strlen = number.length; if(strlen < 13){ return false; } for(i=0;i<strlen;i++){ pos = strlen - i; digit = parseInt(number.substring(pos - 1, pos)); if(i % 2 == 1){ sub_total = digit * 2; if(sub_total > 9){ sub_total = 1 + (sub_total - 10); } } else { sub_total = digit; } sum += sub_total; } if(sum > 0 && sum % 10 == 0){ return true; } return false; }
  
  $("#add-card-button").click(function(){
    if (mod10_check($("#cc_number").val())){
      $("#add-card-form").submit();
    }else{
      alert("Invalid credit card");
    }

  })

})