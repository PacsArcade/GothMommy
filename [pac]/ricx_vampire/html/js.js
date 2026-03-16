$('body').fadeOut(0);

/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
window.addEventListener('message', function(event) {
  switch (event.data.action) {
    case 'hud':
        $('body').html(event.data.html);
        $('body').fadeIn(0);
        break;
    case 'close':
        InteractClose({key:'Escape'});
        break;
    default:
        break;
    }
});
/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
function NoMouse(s) {
    $('body').css('pointer-events', 'none');
    setTimeout(function() {
      $('body').css('pointer-events', 'auto');
    }, s * 1000);
}
/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
function NowAudio(src, volume) {
    audio = new Audio(src);
    audio.volume = volume
    audio.play()
}
/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
function InteractClose(event, sound) {
    if (event.key === 'Escape' && $('body').is(':visible')) {
        setTimeout(function() {
            ResetBody()
            $.post('https://ricx_vampire/ricx_vampire:close');  
        }, 0.25 * 1000);
        if (sound) {NowAudio(sound,0.5)}
    }
}
/*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
function ResetBody() {
    $('body').html('');
    $('body').off('keydown.interactClose');
    $('body').fadeOut(0);
}