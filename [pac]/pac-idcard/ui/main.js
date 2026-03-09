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

    var filterLayer  = document.getElementById('cam-filter-layer');

    // ── Filter ────────────────────────────────────────────────────────
    // Apply to BOTH the tint layer AND document.body so the game scene
    // (which renders behind the NUI page) appears tinted.
    // The HUD uses isolation:isolate to prevent inheriting the filter.
    function setFilter(css, name) {
        var f = (!css || css === 'none') ? 'none' : css;
        filterLayer.style.filter    = f;
        document.body.style.filter  = f;
        $('#filter-label').text(name || 'None');
    }

    // ── Countdown + flash + screenshot ───────────────────────────────
    function doCountdownAndShoot() {
        if (shootLocked) return;
        shootLocked = true;

        // Hide controls and filter bar during countdown
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
                // White flash
                $flash.css({ display:'block', opacity:1 })
                      .animate({ opacity: 0 }, 500, function() { $flash.hide(); });
                // Tell Lua to capture screenshot
                $.post('https://' + GetParentResourceName() + '/camShoot', JSON.stringify({}));
                // Show saved toast bottom-right (above Steam ~80px)
                $('#cam-saved-toast').stop(true).css({ display:'block', opacity:1 })
                    .delay(2200).fadeOut(600);
                // Restore controls
                setTimeout(function() {
                    $('#cam-controls, #filter-bar').fadeIn(300);
                }, 700);
                shootLocked = false;
            }
        }
        showNext();
    }

    // ── Keyboard layout ───────────────────────────────────────────────
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

    // ── ID Card display ───────────────────────────────────────────────
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

    // ── Form submit ───────────────────────────────────────────────────
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

    // ── Message handler ───────────────────────────────────────────────
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
                setFilter(d.css, d.name);
                break;
            case 'showCameraOverlay':
                if (d.visible) {
                    camTarget    = { pcx: d.pcx||0, pcy: d.pcy||0, pcz: d.pcz||0 };
                    cameraActive = true;
                    shootLocked  = false;
                    filterLayer.style.filter   = 'none';
                    document.body.style.filter = 'none';
                    $('#filter-label').text('None');
                    filterLayer.style.display  = 'block';
                    $('#cam-controls, #filter-bar').show();
                    $('#camera-overlay').show();
                } else {
                    cameraActive = false;
                    $('#camera-overlay').hide();
                    filterLayer.style.display  = 'none';
                    filterLayer.style.filter   = 'none';
                    document.body.style.filter = 'none';
                    $('#filter-label').text('');
                    $('#cam-countdown').hide();
                    $('#cam-saved-toast').stop(true).hide();
                }
                break;
        }
    });
});
