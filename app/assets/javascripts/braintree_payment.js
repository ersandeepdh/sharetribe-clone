$(function(){

  $(".default_card").click(function(){
    $.post($(this).attr("data-url"), function(data){
      console.log(data);
    })
  })

  $("a#add-new-card-link").fancybox({
    maxWidth  : 700,
    maxHeight : 400,
    fitToView : false,
    width   : '70%',
    height    : '70%',
    autoSize  : false,
    closeClick  : false,
    openEffect  : 'none',
    closeEffect : 'none'
  });

})