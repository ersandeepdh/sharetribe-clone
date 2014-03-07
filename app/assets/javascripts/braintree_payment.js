$(function(){
  $(".default_card").click(function(){
    $.post($(this).attr("data-url"), function(data){
      console.log(data);
    })
  })
})