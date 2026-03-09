$(document).ready(function () {
    $('.id-card').hide();
    $('.photograph').hide();
    $('.printphoto').hide();
    $('.create').hide();
    $('.previewcreate-photo').hide();

    var setIllegal   = false;
    var camTarget    = { pcx: 0, pcy: 0, pcz: 0 };
    var cameraActive = false;
    var shootLocked  = false;

    var $solid = $('#fl-solid');
    var $pixel = $('#fl-pixel');
    var $fog   = $('#fl-fog');
    var $acid  = $('#fl-acid');
    var pixelCanvas = document.getElementById('pixel-canvas');
    var pixelCtx    = pixelCanvas ? pixelCanvas.getContext('2d') : null;
    var pixelAnim   = null;

    function clearFilters() {
        $solid.hide().css('background-color', '');
        stopPixel();
        $pixel.hide();
        $fog.hide();
        $acid.hide();
    }

    // -------------------------------------------------------
    // PIXELATED
    // CEF can't read game framebuffer pixels, so we fake the
    // low-res look:
    //   - The #fl-pixel div has a semi-transparent sepia base
    //     (rgba 0.45) so the game scene shows through dimly.
    //   - On top of that, the canvas draws large solid-colour
    //     blocks using warm sepia tones with ~0.55 opacity.
    //   - The combination: game scene → sepia tint → chunky
    //     colour blocks → result looks like a very low-res
    //     warm mosaic over the scene.
    //   - Every 120ms the block colours are re-randomised with
    //     slight variation so the blocks shimmer/shift, adding
    //     to the 8-bit feel.
    // -------------------------------------------------------
    function startPixel(bs) {
        bs = bs || 18;  // default 18px blocks — visibly chunky
        var W = window.innerWidth;
        var H = window.innerHeight;
        var cols = Math.ceil(W / bs);
        var rows = Math.ceil(H / bs);

        pixelCanvas.width  = W;
        pixelCanvas.height = H;

        function drawFrame() {
            for (var y = 0; y < rows; y++) {
                for (var x = 0; x < cols; x++) {
                    // Warm sepia palette: r 35-90, g 20-55, b 5-20
                    var r = 35  + Math.floor(Math.random() * 55);
                    var g = 20  + Math.floor(Math.random() * 35);
                    var b = 5   + Math.floor(Math.random() * 15);
                    var a = (0.40 + Math.random() * 0.30).toFixed(2);
                    pixelCtx.fillStyle = 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';
                    pixelCtx.fillRect(x * bs, y * bs, bs, bs);
                }
            }
        }

        drawFrame();
        $pixel.show();
        // Animate — redraw every 150ms for the shimmer effect
        pixelAnim = setInterval(drawFrame, 150);
    }

    function stopPixel() {
        if (pixelAnim) { clearInterval(pixelAnim); pixelAnim = null; }
        if (pixelCtx) pixelCtx.clearRect(0, 0, pixelCanvas.width, pixelCanvas.height);
    }

    function setFilter(d) {
        clearFilters();
        var type = d.filterType;
        if (!type) {
            // None
        } else if (type === 'solid') {
            $solid.css('background-color',
                'rgba('+(d.r||0)+','+(d.g||0)+','+(d.b||0)+','+(d.a||0.40)+')');
            $solid.show();
        } else if (type === 'fog') {
            $fog.show();
        } else if (type === 'acid') {
            $acid.show();
        } else if (type === 'pixel') {
            startPixel(d.size || 18);
        }
        $('#filter-label').text(d.name || 'None');
    }

    // -------------------------------------------------------
    // Screenshot: fire F12 as a synthetic KeyboardEvent.
    // RedM NUI intercepts keyboard events at the CEF/browser
    // level — a synthesised keydown with the correct key code
    // should reach the same intercept layer as a physical press.
    // The Lua side also fires the native screenshot export.
    // -------------------------------------------------------
    function fireF12() {
        var down = new KeyboardEvent('keydown', {
            key: 'F12', code: 'F12',
            keyCode: 123, which: 123,
            bubbles: true, cancelable: true
        });
        var up = new KeyboardEvent('keyup', {
            key: 'F12', code: 'F12',
            keyCode: 123, which: 123,
            bubbles: true, cancelable: true
        });
        document.dispatchEvent(down);
        window.dispatchEvent(down);
        setTimeout(function() {
            document.dispatchEvent(up);
            window.dispatchEvent(up);
        }, 80);
    }

    // -------------------------------------------------------
    // Countdown: use .visible class so display:flex is applied
    // (plain .show() would set display:block, breaking centering)
    // -------------------------------------------------------
    function showCount(text) {
        $('#cam-countdown').text(text).addClass('visible');
    }
    function hideCount() {
        $('#cam-countdown').removeClass('visible').text('');
    }

    function doCountdownAndShoot() {
        if (shootLocked) return;
        shootLocked = true;
        $('#cam-controls,#filter-bar').fadeOut(200);
        var $flash = $('#cam-flash');
        var counts = ['3', '2', '1'], i = 0;
        function showNext() {
            if (i < counts.length) {
                showCount(counts[i]); i++;
                setTimeout(showNext, 900);
            } else {
                hideCount();
                $flash.css({display:'block', opacity:1}).animate({opacity:0}, 500, function(){ $flash.hide(); });
                // Lua native screenshot export
                $.post('https://'+GetParentResourceName()+'/camShoot', JSON.stringify({}));
                // Synthetic F12 press for client screenshot binding
                fireF12();
                $('#cam-saved-toast').stop(true).css({display:'block', opacity:1}).delay(2500).fadeOut(600);
                setTimeout(function(){ $('#cam-controls,#filter-bar').fadeIn(300); }, 700);
                shootLocked = false;
            }
        }
        showNext();
    }

    var keyMap = {
        'Numpad8':'up',    'Numpad2':'down',
        'Numpad4':'left',  'Numpad6':'right',
        'Numpad7':'fwd',   'Numpad9':'back',
        'Numpad1':'filter_prev', 'Numpad3':'filter_next',
        'Numpad5':'reset', 'Numpad0':'exit',
        'NumpadEnter':'shoot', 'Enter':'shoot',
        'ArrowUp':'up','ArrowDown':'down','ArrowLeft':'left','ArrowRight':'right',
        'Backspace':'exit','Escape':'exit',
    };
    $(document).on('keydown', function(e) {
        if (!cameraActive) return;
        var dir = keyMap[e.code] || keyMap[e.key];
        if (!dir) return;
        e.preventDefault();
        if (dir === 'shoot') { doCountdownAndShoot(); return; }
        $.post('https://'+GetParentResourceName()+'/camMove', JSON.stringify({
            dir: dir, pcx: camTarget.pcx, pcy: camTarget.pcy, pcz: camTarget.pcz,
        }));
    });

    function setupIDCard(array) {
        if (!array || typeof array !== 'object') return;
        var sex = array.sex === 'Female' ? 'F' : 'M';
        var displayId = array.licenseNumber || array.prev_license
            || ('GMRP-'+String(array.charid||'N/A').padStart(6,'0'));
        $('.charid').html(displayId); $('.license').html(array.prev_license||displayId);
        $('.sex').html(sex); $('.hair').html(array.hair||'N/A'); $('.eyes').html(array.eye||'N/A');
        $('.height').html(array.height||'N/A'); $('.weight').html(array.weight||'N/A');
        $('.religious').html(array.religious||''); $('.dateofbirth').html(array.date||'N/A');
        $('.age').html(array.age||'N/A'); $('.name').html(array.name||'N/A');
        $('.country').html(array.country||'Goth Mommy RP'); $('.card-zone').html(array.cityname||'N/A');
        $('.playerimg').attr('src', array.img||'');
        $('.id-card').removeClass('animate__animated animate__fadeOutRight')
            .addClass('animate__animated animate__fadeInRight').show();
    }
    function closeIDCard() {
        ShowIdCard = false;
        $('.id-card').removeClass('animate__animated animate__fadeInRight')
            .addClass('animate__animated animate__fadeOutRight')
            .one('animationend', function(){ $(this).hide(); });
    }

    $('#submit').click(function(){
        $.post('https://'+GetParentResourceName()+'/createIdCard', JSON.stringify({
            name:$('#name').val(), cityname:$('#cityname').val(), religious:$('#religious').val(),
            age:$('#ageinput').val(), date:$('#dateinput').val(), height:$('#heightinput').val(),
            weight:$('#weightinput').val(), hair:$('#hair').val(), eye:$('#eye').val(),
            sex:$('#sex-women').prop('checked')?'Female':'Male',
            itemId:$('#previewphoto').attr('data-itemid'), img:$('#previewphoto').attr('src'),
            illegal:setIllegal
        }));
        closePrintPhoto();
        $.post('https://'+GetParentResourceName()+'/close', JSON.stringify({}));
    });
    function CreateIdCardSetData(data, illegal) {
        setIllegal = illegal;
        $('#name').val(data.name);
        var city = data.city||'Blackwater'; $('#cityname').val($('#cityname option[value="'+city+'"]').length ? city : 'Other');
        var rel = data.religious||''; $('#religious').val($('#religious option[value="'+rel+'"]').length ? rel : '');
        $('#ageinput').val(data.age);
        $('#weightinput').val(data.weight ? data.weight+'KG' : '80KG');
        if (data.sex==='Male')   { $('#sex-man').prop('checked',true);  $('#sex-women').prop('checked',false); }
        if (data.sex==='Female') { $('#sex-women').prop('checked',true); $('#sex-man').prop('checked',false); }
        $('#sex-man,#sex-women').change(function(){ $('#sex-man,#sex-women').not($(this)).prop('checked',false); });
        if (!illegal) { var my=1899-data.age; $('#dateinput').attr('max',my+'-12-31').attr('min',my+'-01-01').val(my+'-01-01'); }
        $('#previewphoto').attr('src',data.img).attr('data-itemid',data.itemId);
        var hmap={0.85:"4'8",0.90:"4'9",0.95:"4'10",1.0:"5'0",1.05:"5'1",1.10:"5'2"};
        $('#heightinput').val(hmap[data.height]||"5'0");
        var hair = data.hair||'Black'; $('#hair').val($('#hair option[value="'+hair+'"]').length ? hair : 'Black');
        var eye  = data.eye||'Brown';  $('#eye').val($('#eye option[value="'+eye+'"]').length ? eye : 'Brown');
    }
    function showPrintPhoto(img){ ShowPhoto=true; $('.photograph .photo').attr('src',img); $('.photograph').fadeIn(500); }
    function closePrintPhoto(){ ShowPhoto=false; $('.photograph,.printphoto,.create,.previewcreate-photo').fadeOut(500); }
    $('.preview').click(function(){ var l=$('#link').val(); if(l) $('.photo').attr('src',l); else $.post('https://'+GetParentResourceName()+'/notify',JSON.stringify({text:'noimg'})); });
    $('.close,.close-create').click(function(){ closePrintPhoto(); $.post('https://'+GetParentResourceName()+'/close',JSON.stringify({})); });
    $('.print').click(function(){
        var l=$('#link').val();
        if (l) { closePrintPhoto(); $.post('https://'+GetParentResourceName()+'/print',JSON.stringify({imgLink:l})); }
        else $.post('https://'+GetParentResourceName()+'/notify',JSON.stringify({text:'noimg'}));
    });
    $(document).keyup(function(e){
        if (cameraActive) return;
        if (e.key==='Escape') {
            var closed=false;
            if (ShowPhoto)  { closePrintPhoto(); closed=true; }
            if (ShowIdCard) { closeIDCard();     closed=true; }
            if (closed) $.post('https://'+GetParentResourceName()+'/close',JSON.stringify({}));
        }
    });

    var ShowPhoto=false, ShowIdCard=false;

    window.addEventListener('message', function(event) {
        var d = event.data;
        switch (d.action) {
            case 'openIdCard':   ShowIdCard=true; setupIDCard(d.array); break;
            case 'close':        closeIDCard(); break;
            case 'print':        $('.printphoto').fadeIn(500); break;
            case 'showphoto':    ShowPhoto=true; showPrintPhoto(d.array.img); break;
            case 'createidcard':
                if (d.illegal===true) {
                    $('#cityname,#heightinput,#ageinput,#sex-man,#sex-women').removeAttr('disabled');
                    $('#dateinput').removeAttr('min').removeAttr('max');
                }
                CreateIdCardSetData(d.array, d.illegal);
                $('.create,.previewcreate-photo').fadeIn(500);
                break;
            case 'setFilter': setFilter(d); break;
            case 'showCameraOverlay':
                if (d.visible) {
                    camTarget = {pcx:d.pcx||0, pcy:d.pcy||0, pcz:d.pcz||0};
                    cameraActive=true; shootLocked=false;
                    clearFilters(); hideCount();
                    $('#filter-label').text('None');
                    $('#cam-controls,#filter-bar').show();
                    $('#camera-overlay').show();
                } else {
                    cameraActive=false; clearFilters(); hideCount();
                    $('#camera-overlay').hide();
                    $('#filter-label').text('');
                    $('#cam-saved-toast').stop(true).hide();
                }
                break;
        }
    });
});
