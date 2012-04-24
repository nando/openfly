
  $(function(){
    var xOffset = -16,
        yOffset = 16;

    function photo_sticker(td, image_url) {
      var show_photo = function(e) {
        $("#preview").remove();
        $("body").append("<div id='preview'><img src='"+ image_url +"' alt='Foto del piloto' /></div>"); 
        $("#preview")
          .css("top",(e.pageY - xOffset) + "px")
          .css("left",(e.pageX + yOffset) + "px")
          .fadeIn("fast");            
      };
      var photo_handler = function(e) {
        $.ajax({
          url:image_url,
          type:'HEAD',
          error: function(){
            td.unbind('mouseenter',photo_handler);
          },
          success: function(){
            show_photo(e);
            td.unbind('mouseenter',photo_handler);
            td.hover(show_photo,
              function(){
                $("#preview").remove();
              }
            );
            td.mousemove(function(e){
              $("#preview")
                .css("top",(e.pageY - xOffset) + "px")
                .css("left",(e.pageX + yOffset) + "px");
            });
          }
        });
      };
      $(td).bind('mouseenter', photo_handler);
    };

    $('div.article table tr td span.pilot_id').each(function(){
      var span = $(this),
          pilot_id = span.html(),
          td = span.parent('td'),
          td_glider = td.nextAll('td');
      photo_sticker(td, 'images/pilots/' + pilot_id + '.jpg'); 
      photo_sticker(td_glider, 'images/pilots/' + pilot_id + '_glider.jpg'); 
    }); 
  });
