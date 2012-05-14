
  $(function(){
    var xOffset = -16,
        yOffset = 16,
        spinner = 'images/ajax-loader.gif';
    $("body").append("<div id='preview' style='display: none'><img src='"+spinner+"' alt='foto...' /></div>"); 

    function photo_sticker(td, image_url) {
      var preview = $("#preview"),
          preview_img = $("img", preview);
      var show_photo = function(e) {
        preview_img.attr('src', spinner);
        preview
          .css("top",(e.pageY - xOffset) + "px")
          .css("left",(e.pageX + yOffset) + "px")
          .show();            
        preview_img.attr('src', image_url);
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
                preview.hide();            
                preview_img.attr('src', spinner);
              }
            );
            td.mousemove(function(e){
              preview
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
