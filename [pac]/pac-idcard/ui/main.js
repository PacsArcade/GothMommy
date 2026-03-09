$(document).ready(function () {
    $(".id-card").hide();
    $(".photograph").hide();
    $(".printphoto").hide();
    $(".create").hide();
    $(".previewcreate-photo").hide();
    var setIllegal = false;
    var camTarget  = { pcx: 0, pcy: 0, pcz: 0 };
    var cameraActive = false;

    // ── Camera filter ────────────────────────────────────────────────────
    // Filter is applied to #cam-filter-layer, a full-screen div BEHIND the HUD.
    // This keeps the HUD readable while tinting the scene.
    function setFilter(css, name) {
        var f = (!css || css === 'none') ? 'none' : css;
        document.getElementById('cam-filter-layer').style.filter = f;
        $("#filter-label").text(name || 'None');
    }

    // ── Numpad / keyboard layout for camera ──────────────────────────────
    // Numpad layout:
    //   8 = cam up        2 = cam down
    //   4 = cam left      6 = cam right
    //   7 = zoom in       9 = zoom out   (fwd/back on X axis)
    //   1 = filter prev   3 = filter next
    //   5 = reset camera to default
    //   0 / Backspace / Escape = exit
    //
    // Also supports arrow keys for up/down/left/right.
    var keyMap = {
        'Numpad8':      'up',
        'Numpad2':      'down',
        'Numpad4':      'left',
        'Numpad6':      'right',
        'Numpad7':      'fwd',
        'Numpad9':      'back',
        'Numpad1':      'filter_prev',
        'Numpad3':      'filter_next',
        'Numpad5':      'reset',
        'Numpad0':      'exit',
        'ArrowUp':      'up',
        'ArrowDown':    'down',
        'ArrowLeft':    'left',
        'ArrowRight':   'right',
        'Backspace':    'exit',
        'Escape':       'exit',
    };

    $(document).on('keydown', function(e) {
        if (!cameraActive) return;
        var dir = keyMap[e.code] || keyMap[e.key];
        if (!dir) return;
        e.preventDefault();
        $.post('https://' + GetParentResourceName() + '/camMove', JSON.stringify({
            dir: dir,
            pcx: camTarget.pcx,
            pcy: camTarget.pcy,
            pcz: camTarget.pcz,
        }));
    });

    // ── ID Card display ──────────────────────────────────────────────────
    function setupIDCard(array) {
        if (!array || typeof array !== 'object') return;
        var sex = array.sex === "Female" ? "F" : "M";
        var displayId = array.licenseNumber || array.prev_license || ("GMRP-" + String(array.charid || 'N/A').padStart(6, '0'));
        $(".charid").html(displayId);
        $(".license").html(array.prev_license || displayId);
        $(".sex").html(sex);
        $(".hair").html(array.hair || "N/A");
        $(".eyes").html(array.eye || "N/A");
        $(".height").html(array.height || "N/A");
        $(".weight").html(array.weight || "N/A");
        $(".religious").html(array.religious || "");
        $(".dateofbirth").html(array.date || "N/A");
        $(".age").html(array.age || "N/A");
        $(".name").html(array.name || "N/A");
        $(".country").html(array.country || "Goth Mommy RP");
        $(".card-zone").html(array.cityname || "N/A");
        $(".playerimg").attr("src", array.img || "");
        $(".id-card").removeClass("animate__animated animate__fadeOutRight")
            .addClass("animate__animated animate__fadeInRight").show();
    }

    function closeIDCard() {
        ShowIdCard = false;
        $(".id-card").removeClass("animate__animated animate__fadeInRight")
            .addClass("animate__animated animate__fadeOutRight")
            .one('animationend', function() { $(this).hide(); });
    }

    // ── Form submit ───────────────────────────────────────────────────────
    $("#submit").click(function () {
        $.post('https://' + GetParentResourceName() + '/createIdCard', JSON.stringify({
            name:        $("#name").val(),
            cityname:    $("#cityname").val(),
            religious:   $("#religious").val(),
            age:         $("#ageinput").val(),
            date:        $("#dateinput").val(),
            height:      $("#heightinput").val(),
            weight:      $("#weightinput").val(),
            hair:        $("#hair").val(),
            eye:         $("#eye").val(),
            sex:         $("#sex-women").prop('checked') ? "Female" : "Male",
            itemId:      $("#previewphoto").attr("data-itemid"),
            img:         $('#previewphoto').attr('src'),
            illegal:     setIllegal
        }));
        closePrintPhoto();
        $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
    });

    function CreateIdCardSetData(data, illegal) {
        setIllegal = illegal;
        $("#name").val(data.name);
        var city = data.city || "Blackwater";
        $("#cityname").val($("#cityname option[value='" + city + "']").length ? city : "Other");
        var rel = data.religious || "";
        $("#religious").val($("#religious option[value='" + rel + "']").length ? rel : "");
        $("#ageinput").val(data.age);
        $("#weightinput").val(data.weight ? data.weight + "KG" : "80KG");
        if (data.sex === "Male") {
            $("#sex-man").prop("checked", true); $("#sex-women").prop("checked", false);
        } else if (data.sex === "Female") {
            $("#sex-women").prop("checked", true); $("#sex-man").prop("checked", false);
        }
        $("#sex-man, #sex-women").change(function () {
            $("#sex-man, #sex-women").not($(this)).prop("checked", false);
        });
        if (!illegal) {
            var maxYear = 1899 - data.age;
            $("#dateinput").attr("max", maxYear + "-12-31").attr("min", maxYear + "-01-01").val(maxYear + "-01-01");
        }
        $("#previewphoto").attr("src", data.img).attr("data-itemid", data.itemId);
        var heightMap = {0.85:"4'8",0.90:"4'9",0.95:"4'10",1.0:"5'0",1.05:"5'1",1.10:"5'2"};
        $("#heightinput").val(heightMap[data.height] || "5'0");
        var hair = data.hair || "Black";
        $("#hair").val($("#hair option[value='" + hair + "']").length ? hair : "Black");
        var eye = data.eye || "Brown";
        $("#eye").val($("#eye option[value='" + eye + "']").length ? eye : "Brown");
    }

    function showPrintPhoto(img) {
        ShowPhoto = true;
        $(".photograph .photo").attr("src", img);
        $(".photograph").fadeIn(500);
    }

    function closePrintPhoto() {
        ShowPhoto = false;
        $(".photograph, .printphoto, .create, .previewcreate-photo").fadeOut(500);
    }

    $(".preview").click(function () {
        var imgLink = $("#link").val();
        if (imgLink) $(".photo").attr("src", imgLink);
        else $.post('https://' + GetParentResourceName() + '/notify', JSON.stringify({ text: "noimg" }));
    });

    $(".close, .close-create").click(function () {
        closePrintPhoto();
        $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
    });

    $(".print").click(function () {
        var imgLink = $("#link").val();
        if (imgLink) {
            closePrintPhoto();
            $.post('https://' + GetParentResourceName() + '/print', JSON.stringify({ imgLink: imgLink }));
        } else {
            $.post('https://' + GetParentResourceName() + '/notify', JSON.stringify({ text: "noimg" }));
        }
    });

    $(document).keyup(function (e) {
        if (cameraActive) return;
        if (e.key === "Escape") {
            var isClosed = false;
            if (ShowPhoto)  { closePrintPhoto(); isClosed = true; }
            if (ShowIdCard) { closeIDCard();     isClosed = true; }
            if (isClosed) $.post('https://' + GetParentResourceName() + '/close', JSON.stringify({}));
        }
    });

    let ShowPhoto  = false;
    let ShowIdCard = false;

    // ── Message handler ──────────────────────────────────────────────────
    window.addEventListener('message', function (event) {
        var d = event.data;
        switch (d.action) {
            case 'openIdCard':
                ShowIdCard = true;
                setupIDCard(d.array);
                break;
            case 'close':
                closeIDCard();
                break;
            case 'print':
                $(".printphoto").fadeIn(500);
                break;
            case 'showphoto':
                ShowPhoto = true;
                showPrintPhoto(d.array.img);
                break;
            case 'createidcard':
                if (d.illegal === true) {
                    $("#cityname, #heightinput, #ageinput, #sex-man, #sex-women").removeAttr("disabled");
                    $("#dateinput").removeAttr("min").removeAttr("max");
                }
                CreateIdCardSetData(d.array, d.illegal);
                $(".create, .previewcreate-photo").fadeIn(500);
                break;
            case 'setFilter':
                setFilter(d.css, d.name);
                break;
            case 'showCameraOverlay':
                if (d.visible) {
                    camTarget = { pcx: d.pcx || 0, pcy: d.pcy || 0, pcz: d.pcz || 0 };
                    cameraActive = true;
                    // Reset filter layer
                    document.getElementById('cam-filter-layer').style.filter = 'none';
                    $("#filter-label").text('None');
                    $("#camera-overlay").show();
                } else {
                    cameraActive = false;
                    $("#camera-overlay").hide();
                    document.getElementById('cam-filter-layer').style.filter = 'none';
                    $("#filter-label").text('');
                }
                break;
        }
    });
});
