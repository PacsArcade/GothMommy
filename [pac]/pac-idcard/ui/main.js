$(document).ready(function () {
    $(".id-card").hide();
    $(".photograph").hide();
    $(".printphoto").hide();
    $(".create").hide();
    $(".previewcreate-photo").hide();
    var setIllegal = false;

    // ── Camera filter overlay ──────────────────────────────────────────────
    function setFilter(css, name) {
        var overlay = $("#camera-overlay");
        if (css === 'none' || !css) {
            overlay.css('filter', 'none');
        } else {
            overlay.css('filter', css);
        }
        $("#filter-label").text(name || '');
    }

    // ── ID Card display ───────────────────────────────────────────────────
    function setupIDCard(array) {
        if (!array || typeof array !== 'object') {
            console.error('ID Card data is invalid:', array);
            return;
        }
        var sex = array.sex === "Female" ? "F" : "M";
        $(".charid").html(array.charid || "N/A");
        $(".license").html(array.prev_license || `GMRP-${array.charid || "N/A"}`);
        $(".sex").html(sex);
        $(".hair").html(array.hair || "N/A");
        $(".eyes").html(array.eye || "N/A");
        $(".height").html(array.height || "N/A");
        $(".weight").html(array.weight || "N/A");
        $(".religious").html(array.religious || "");
        $(".dateofbirth").html(array.date || "N/A");
        $(".age").html(array.age || "N/A");
        $(".name").html(array.name || "N/A");
        $(".country").html(array.country || "N/A");
        $(".card-zone").html(array.cityname || "N/A");
        $(".playerimg").attr("src", array.img || "/path/to/default/image.png");
        $(".id-card")
            .removeClass("animate__animated animate__fadeOutRight")
            .addClass("animate__animated animate__fadeInRight")
            .show();
    }

    function closeIDCard() {
        ShowIdCard = false;
        $(".id-card")
            .removeClass("animate__animated animate__fadeInRight")
            .addClass("animate__animated animate__fadeOutRight")
            .one('animationend', function() { $(this).hide(); });
    }

    // ── Form submit ───────────────────────────────────────────────────────
    $("#submit").click(function () {
        var name        = $("#name").val();
        var cityname    = $("#cityname").val();
        var religious   = $("#religious").val();
        var age         = $("#ageinput").val();
        var dateinput   = $("#dateinput").val();
        var heightinput = $("#heightinput").val();
        var weightinput = $("#weightinput").val();
        var hair        = $("#hair").val();
        var eye         = $("#eye").val();
        var sex         = $("#sex-women").prop('checked') ? "Female" : "Male";
        var itemId      = $("#previewphoto").attr("data-itemid");
        var img         = $('#previewphoto').attr('src');
        $.post(`https://${GetParentResourceName()}/createIdCard`, JSON.stringify({
            name: name, cityname: cityname, religious: religious,
            age: age, date: dateinput, height: heightinput,
            weight: weightinput, hair: hair, eye: eye,
            sex: sex, img: img, itemId: itemId, illegal: setIllegal
        }));
        closePrintPhoto();
        $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
    });

    function CreateIdCardSetData(data, illegal) {
        setIllegal = illegal;
        $("#name").val(data.name);
        $("#cityname").val(data.city);

        // Set religion dropdown
        var rel = data.religious || "";
        if ($("#religious option[value='" + rel + "']").length) {
            $("#religious").val(rel);
        } else {
            $("#religious").val("");
        }

        $("#ageinput").val(data.age);
        $("#weightinput").val(`${data.weight}KG`);

        if (data.sex === "Male") {
            $("#sex-man").prop("checked", true);
            $("#sex-women").prop("checked", false);
        } else if (data.sex === "Female") {
            $("#sex-women").prop("checked", true);
            $("#sex-man").prop("checked", false);
        }

        $("#sex-man, #sex-women").change(function () {
            $("#sex-man, #sex-women").not($(this)).prop("checked", false);
        });

        if (!illegal) {
            var maxYear = 1899 - data.age;
            $("#dateinput").attr("max", maxYear + "-12-31");
            $("#dateinput").attr("min", maxYear + "-01-01");
            $("#dateinput").val(maxYear + "-01-01");
        }

        $("#previewphoto").attr("src", data.img).attr("data-itemid", data.itemId);

        var heightMap = {0.85:"4'8",0.90:"4'9",0.95:"4'10",1.0:"5'0",1.05:"5'1",1.10:"5'2"};
        $("#heightinput").val(heightMap[data.height] || "5'0");
    }

    function showPrintPhoto(img) {
        ShowPhoto = true;
        $(".photograph .photo").attr("src", img);
        $(".photograph").fadeIn(500);
    }

    function closePrintPhoto() {
        ShowPhoto = false;
        $(".photograph").fadeOut(500);
        $(".printphoto").fadeOut(500);
        $(".create").fadeOut(500);
        $(".previewcreate-photo").fadeOut(500);
    }

    $(".preview").click(function () {
        var imgLink = $("#link").val();
        if (imgLink) {
            $(".photo").attr("src", imgLink);
        } else {
            $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({ text: "noimg" }));
        }
    });

    $(".close, .close-create").click(function () {
        closePrintPhoto();
        $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
    });

    $(".print").click(function () {
        var imgLink = $("#link").val();
        if (imgLink) {
            closePrintPhoto();
            $.post(`https://${GetParentResourceName()}/print`, JSON.stringify({ imgLink: imgLink }));
        } else {
            $.post(`https://${GetParentResourceName()}/notify`, JSON.stringify({ text: "noimg" }));
        }
    });

    $(document).keyup(function (e) {
        if (e.key === "Escape") {
            var isClosed = false;
            if (ShowPhoto)  { closePrintPhoto(); isClosed = true; }
            if (ShowIdCard) { closeIDCard();     isClosed = true; }
            if (isClosed) {
                $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
            }
        }
    });

    let ShowPhoto  = false;
    let ShowIdCard = false;

    // ── Message handler ───────────────────────────────────────────────────
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
                $(".create").fadeIn(500);
                $(".previewcreate-photo").fadeIn(500);
                break;
            case 'setFilter':
                setFilter(d.css, d.name);
                break;
            case 'showCameraOverlay':
                if (d.visible) {
                    $("#camera-overlay").show();
                } else {
                    $("#camera-overlay").hide();
                    setFilter('none', '');
                }
                break;
        }
    });
});
