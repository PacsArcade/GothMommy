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

    function clearFilters() {
        $solid.hide().css('background-color', '');
        $pixel.hide();
        if (pixelCtx) pixelCtx.clearRect(0, 0, pixelCanvas.width, pixelCanvas.height);
        $fog.hide();
        $acid.hide();
    }

    // -------------------------------------------------------
    // PIXELATED
    // 32px blocks at low opacity so the game scene shows
    // through clearly with a warm mosaic tint.
    // Drawn ONCE (no shimmer animation) - stable mosaic.
    // -------------------------------------------------------
    function startPixel(bs) {
        bs = bs || 32;
        var W = window.innerWidth;
        var H = window.innerHeight;
        var cols = Math.ceil(W / bs);
        var rows = Math.ceil(H / bs);
        pixelCanvas.width  = W;
        pixelCanvas.height = H;
        for (var y = 0; y < rows; y++) {
            for (var x = 0; x < cols; x++) {
                // Warm sepia tones, varied slightly per block
                var r = 60  + Math.floor(Math.random() * 50);
                var g = 35  + Math.floor(Math.random() * 30);
                var b = 8   + Math.floor(Math.random() * 18);
                var a = (0.22 + Math.random() * 0.18).toFixed(2); // 0.22-0.40
                pixelCtx.fillStyle = 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';
                pixelCtx.fillRect(x * bs, y * bs, bs - 1, bs - 1); // -1 creates a thin dark gap = block edge
            }
        }
        $pixel.show();
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
            startPixel(d.size || 32);
        }
        $('#filter-label').text(d.name || 'None');
    }

    // -------------------------------------------------------
    // Countdown
    // Use inline flex so digit is centred both axes.
    // -------------------------------------------------------
    function showCount(text) {
        var $cd = $('#cam-countdown');
        $cd.text(text).css('display', 'flex');
    }
    function hideCount() {
        $('#cam-countdown').css('display', 'none').text('');
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
                // Fire Lua native screenshot export
                $.post('https://'+GetParentResourceName()+'/camShoot', JSON.stringify({}));
                // NOTE: F12 is intercepted by Steam before game/CEF.
                // Players should use their own screenshot key.
                // We do NOT show a misleading "Photo Saved" toast.
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
                }
                break;
        }
    });
});
