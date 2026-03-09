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

    // ─── Lens canvas setup ───────────────────────────────────────────────────
    // We draw a semi-transparent colour fill on this canvas, then apply
    // CSS filter to the canvas element ONLY — never to document.body.
    // This ensures the game scene appears tinted while all HUD elements
    // (which sit in #camera-overlay with isolation:isolate) stay clean.
    var lensCanvas  = document.getElementById('lens-canvas');
    var lensCtx     = lensCanvas.getContext('2d');
    var acidOverlay = document.getElementById('acid-overlay');
    var lensRaf     = null;
    var currentFilterCSS = 'none';
    var isAcid           = false;

    function resizeLens() {
        lensCanvas.width  = window.innerWidth;
        lensCanvas.height = window.innerHeight;
    }
    resizeLens();
    window.addEventListener('resize', resizeLens);

    // Draw a very thin dark vignette each frame so the filter has
    // actual pixels to operate on (pure transparent canvas = no-op).
    function drawLens() {
        var w = lensCanvas.width;
        var h = lensCanvas.height;
        lensCtx.clearRect(0, 0, w, h);

        // Thin dark vignette edges — subtle, lets game render show through
        var grad = lensCtx.createRadialGradient(w/2, h/2, h*0.35, w/2, h/2, h*0.75);
        grad.addColorStop(0,   'rgba(0,0,0,0.00)');
        grad.addColorStop(1,   'rgba(0,0,0,0.38)');
        lensCtx.fillStyle = grad;
        lensCtx.fillRect(0, 0, w, h);

        lensRaf = requestAnimationFrame(drawLens);
    }

    function startLens() {
        if (lensRaf) return;
        lensCanvas.style.display = 'block';
        drawLens();
    }
    function stopLens() {
        if (lensRaf) { cancelAnimationFrame(lensRaf); lensRaf = null; }
        lensCanvas.style.display = 'none';
        lensCanvas.style.filter  = 'none';
        if (lensCtx) lensCtx.clearRect(0, 0, lensCanvas.width, lensCanvas.height);
    }

    // ─── Filter application ──────────────────────────────────────────────────
    // Apply CSS filter to the CANVAS only.  Never touch document.body.
    function setFilter(css, name, filterType) {
        currentFilterCSS = (!css || css === 'none') ? 'none' : css;
        isAcid = (filterType === 'acid');

        // Canvas filter
        lensCanvas.style.filter = currentFilterCSS;

        // Acid drip overlay
        if (isAcid) {
            acidOverlay.style.display = 'block';
        } else {
            acidOverlay.style.display = 'none';
        }

        $('#filter-label').text(name || 'None');
    }

    // ─── Countdown + flash + screenshot ─────────────────────────────────────
    function doCountdownAndShoot() {
        if (shootLocked) return;
        shootLocked = true;

        $('#cam-controls, #filter-bar').fadeOut(200);

        var $cd    = $('#cam-countdown');
        var $flash = $('#cam-flash');
        var counts = ['3','2','1'];
        var i = 0;

        function showNext() {
            if (i < counts.length) {
                $cd.text(counts[i]).show();
                i++;
                setTimeout(showNext, 900);
            } else {
                $cd.hide();
                $flash.css({ display:'block', opacity:1 })
                      .animate({ opacity: 0 }, 500, function() { $flash.hide(); });
                $.post('https://' + GetParentResourceName() + '/camShoot', JSON.stringify({}));
                $('#cam-saved-toast').stop(true).css({ display:'block', opacity:1 })
                    .delay(2200).fadeOut(600);
                setTimeout(function() {
                    $('#cam-controls, #filter-bar').fadeIn(300);
                }, 700);
                shootLocked = false;
            }
        }
        showNext();
    }

    // ─── Keyboard layout ─────────────────────────────────────────────────────
    var keyMap = {
        'Numpad8':     'up',
        'Numpad2':     'down',
        'Numpad4':     'left',
        'Numpad6':     'right',
        'Numpad7':     'fwd',
        'Numpad9':     'back',
        'Numpad1':     'filter_prev',
        'Numpad3':     'filter_next',
        'Numpad5':     'reset',
        'Numpad0':     'exit',
        'NumpadEnter': 'shoot',
        'Enter':       'shoot',
        'ArrowUp':     'up',
        'ArrowDown':   'down',
        'ArrowLeft':   'left',
        'ArrowRight':  'right',
        'Backspace':   'exit',
        'Escape':      'exit',
    };

    $(document).on('keydown', function(e) {
        if (!cameraActive) return;
        var dir = keyMap[e.code] || keyMap[e.key];
        if (!dir) return;
        e.preventDefault();
        if (dir === 'shoot') { doCountdownAndShoot(); return; }
        $.post('https://' + GetParentResourceName() + '/camMove', JSON.stringify({
            dir: dir,
            pcx: camTarget.pcx,
            pcy: camTarget.pcy,
            pcz: camTarget.pcz,
        }));
    });

    // ─── ID Card display ─────────────────────────────────────────────────────
    function setupIDCard(array) {
        if (!array || typeof array !== 'object') return;
        var sex = array.sex === 'Female' ? 'F' : 'M';
        var displayId = array.licenseNumber || array.prev_license
            || ('GMRP-' + String(array.charid || 'N/A').padStart(6,'0'));
        $('.charid').html(displayId);
        $('.license').html(array.prev_license || displayId);
        $('.sex').html(sex);
        $('.hair').html(array.hair || 'N/A');
        $('.eyes').html(array.eye  || 'N/A');
        $('.height').html(array.height || 'N/A');
        $('.weight').html(array.weight || 'N/A');
        $('.religious').html(array.religious || '');
        $('.dateofbirth').html(array.date || 'N/A');
        $('.age').html(array.age || 'N/A');
        $('.name').html(array.name || 'N/A');
        $('.country').html(array.country || 'Goth Mommy RP');
        $('.card-zone').html(array.cityname || 'N/A');
        $('.playerimg').attr('src', array.img || '');
        $('.id-card').removeClass('animate__animated animate__fadeOutRight')
            .addClass('animate__animated animate__fadeInRight').show();
    }
    function closeIDCard() {
        ShowIdCard = false;
        $('.id-card').removeClass('animate__animated animate__fadeInRight')
            .addClass('animate__animated animate__fadeOutRight')
            .one('animationend', function() { $(this).hide(); });
    }

    // ─── Form submit ─────────────────────────────────────────────────────────
    $('#submit').click(function () {
        $.post('https://' + GetParentResourceName() + '/createIdCard', JSON.stringify({
            name:      $('#name').val(),
            cityname:  $('#cityname').val(),
            religious: $('#religious').val(),
            age:       $('#ageinput').val(),
            date:      $('#dateinput').val(),
            height:    $('#heightinput').val(),
            weight:    $('#weightinput').val(),
            hair:      $('#hair').val(),
            eye:       $('#eye').val(),
            sex:       $('#sex-women').prop('checked') ? 'Female' : 'Male',
            itemId:    $('#previewphoto').attr('data-itemid'),
            img:       $('#previewphoto').attr('src'),
            illegal:   setIllegal
        }));
        closePrintPhoto();
        $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
    });

    function CreateIdCardSetData(data, illegal) {
        setIllegal = illegal;
        $('#name').val(data.name);
        var city = data.city || 'Blackwater';
        $('#cityname').val($('#cityname option[value="'+city+'"]').length ? city : 'Other');
        var rel = data.religious || '';
        $('#religious').val($('#religious option[value="'+rel+'"]').length ? rel : '');
        $('#ageinput').val(data.age);
        $('#weightinput').val(data.weight ? data.weight+'KG' : '80KG');
        if (data.sex === 'Male')   { $('#sex-man').prop('checked',true);  $('#sex-women').prop('checked',false); }
        if (data.sex === 'Female') { $('#sex-women').prop('checked',true); $('#sex-man').prop('checked',false);  }
        $('#sex-man,#sex-women').change(function() {
            $('#sex-man,#sex-women').not($(this)).prop('checked',false);
        });
        if (!illegal) {
            var maxYear = 1899 - data.age;
            $('#dateinput').attr('max', maxYear+'-12-31').attr('min', maxYear+'-01-01').val(maxYear+'-01-01');
        }
        $('#previewphoto').attr('src', data.img).attr('data-itemid', data.itemId);
        var hmap = {0.85:"4'8",0.90:"4'9",0.95:"4'10",1.0:"5'0",1.05:"5'1",1.10:"5'2"};
        $('#heightinput').val(hmap[data.height] || "5'0");
        var hair = data.hair || 'Black';
        $('#hair').val($('#hair option[value="'+hair+'"]').length ? hair : 'Black');
        var eye = data.eye || 'Brown';
        $('#eye').val($('#eye option[value="'+eye+'"]').length ? eye : 'Brown');
    }

    function showPrintPhoto(img) {
        ShowPhoto = true;
        $('.photograph .photo').attr('src', img);
        $('.photograph').fadeIn(500);
    }
    function closePrintPhoto() {
        ShowPhoto = false;
        $('.photograph,.printphoto,.create,.previewcreate-photo').fadeOut(500);
    }

    $('.preview').click(function() {
        var imgLink = $('#link').val();
        if (imgLink) $('.photo').attr('src', imgLink);
        else $.post('https://' + GetParentResourceName() + '/notify', JSON.stringify({ text:'noimg' }));
    });
    $('.close,.close-create').click(function() {
        closePrintPhoto();
        $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
    });
    $('.print').click(function() {
        var imgLink = $('#link').val();
        if (imgLink) {
            closePrintPhoto();
            $.post('https://' + GetParentResourceName() + '/print', JSON.stringify({ imgLink: imgLink }));
        } else {
            $.post('https://' + GetParentResourceName() + '/notify', JSON.stringify({ text:'noimg' }));
        }
    });
    $(document).keyup(function(e) {
        if (cameraActive) return;
        if (e.key === 'Escape') {
            var closed = false;
            if (ShowPhoto)  { closePrintPhoto(); closed = true; }
            if (ShowIdCard) { closeIDCard();     closed = true; }
            if (closed) $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
        }
    });

    var ShowPhoto  = false;
    var ShowIdCard = false;

    // ─── Message handler ─────────────────────────────────────────────────────
    window.addEventListener('message', function(event) {
        var d = event.data;
        switch (d.action) {
            case 'openIdCard':   ShowIdCard = true; setupIDCard(d.array); break;
            case 'close':        closeIDCard(); break;
            case 'print':        $('.printphoto').fadeIn(500); break;
            case 'showphoto':    ShowPhoto = true; showPrintPhoto(d.array.img); break;
            case 'createidcard':
                if (d.illegal === true) {
                    $('#cityname,#heightinput,#ageinput,#sex-man,#sex-women').removeAttr('disabled');
                    $('#dateinput').removeAttr('min').removeAttr('max');
                }
                CreateIdCardSetData(d.array, d.illegal);
                $('.create,.previewcreate-photo').fadeIn(500);
                break;

            case 'setFilter':
                setFilter(d.css, d.name, d.filterType);
                break;

            case 'showCameraOverlay':
                if (d.visible) {
                    camTarget    = { pcx: d.pcx||0, pcy: d.pcy||0, pcz: d.pcz||0 };
                    cameraActive = true;
                    shootLocked  = false;
                    // Reset filter state
                    lensCanvas.style.filter = 'none';
                    acidOverlay.style.display = 'none';
                    $('#filter-label').text('None');
                    // Start the lens canvas render loop
                    startLens();
                    $('#cam-controls, #filter-bar').show();
                    $('#camera-overlay').show();
                } else {
                    cameraActive = false;
                    stopLens();
                    acidOverlay.style.display = 'none';
                    $('#camera-overlay').hide();
                    $('#filter-label').text('');
                    $('#cam-countdown').hide();
                    $('#cam-saved-toast').stop(true).hide();
                }
                break;
        }
    });
});
