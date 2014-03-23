$(function(){
  $(".remove-listing-image").click(function(){
    listing_id = $(this).attr("data-listing_id");
    id = $(this).attr("data-id");
    image_div = $(this).parent();
    image_div.html("<img src='/assets/loading.gif' width='35' height='35'> removing");
    $.ajax({
       url: '/listings/'+listing_id+'/images/'+id,
       type: 'DELETE',
       success: function(response) {
        $(image_div).remove();
       },
       error: function(){
        alert("Error, please check your internet connection and try to remove again!");
       }
    })

  })
})