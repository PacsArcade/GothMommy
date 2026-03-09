local vesikalikPlease = {}

RegisterNetEvent("fx-idcard:server:print", function(link)
    local src = source
    if Config.Prices.printphoto then
        if FXHaveMoney(src, "cash", Config.Prices.printphoto) then
            FXRemoveMoney(src, "cash", Config.Prices.printphoto)
        else
            return Notify({ source=src, text=Locale("nomoney",{money=Config.Prices.printphoto}), type="error", time=4000 })
        end
    end
    local metadata = { description = Locale("photodesc").."</br>"..link, img = link }
    FXAddItem(src, Config.PrintPhotoItem, 1, metadata)
    Notify({ source=src, text=Locale("successprint"), type="success", time=4000 })
end)

RegisterNetEvent('fx-idcard:server:GetData', function()
    local src = source
    local Character = FXGetPlayerData(src)
    local charid = Character.charIdentifier
    exports.oxmysql:execute("SELECT * FROM pac_idcard WHERE charid = ?", {charid}, function(result)
        if result and result[1] then
            TriggerClientEvent('fx-idcard:client:setData', src, json.decode(result[1].data))
        else
            TriggerClientEvent('fx-idcard:client:clearData', src)
        end
    end)
end)

RegisterNetEvent('fx-idcard:server:useImagePlease', function(city)
    vesikalikPlease[tostring(source)] = city
    SetTimeout(Config.SelectPhotoTime * 1000, function()
        vesikalikPlease[tostring(source)] = nil
    end)
end)

RegisterNetEvent('fx-idcard:server:setBucket', function(bucket)
    SetPlayerRoutingBucket(source, bucket)
end)

RegisterNetEvent("fx-idcard:server:ShowUi", function(targets, typee, data)
    local src = source
    TriggerClientEvent("fx-idcard:client:PreviewPhoto", src, typee, data)
    for _, v in ipairs(targets) do
        TriggerClientEvent("fx-idcard:client:PreviewPhoto", v, typee, data)
    end
end)

FXRegisterUsableItem(Config.PrintPhotoItem, function(data)
    local src           = data.source
    local link          = data.item.metadata.img
    local PrintPhotoId  = data.item.id
    FXCloseInventory(src)

    if vesikalikPlease[tostring(src)] then
        local city = vesikalikPlease[tostring(src)]
        vesikalikPlease[tostring(src)] = nil

        if not Config.IDCardNPC[city].illegal then
            local Character = FXGetPlayerData(src)
            FXGetCharacterInformations(src, Character.charIdentifier, function(charData)
                local cardData = {
                    name      = charData.firstname .. " " .. charData.lastname,
                    age       = charData.age,
                    sex       = charData.sex,
                    charid    = Character.charIdentifier,
                    height    = charData.height,
                    weight    = charData.weight,
                    city      = city,
                    img       = link,
                    itemId    = PrintPhotoId,
                    religious = Config.Religious[math.random(1, #Config.Religious)],
                }
                Wait(1000)
                TriggerClientEvent("fx-idcard:client:CreateIdcardUi", src, cardData, false)
            end)
        else
            local fakeData = {
                name      = "",
                age       = "",
                sex       = "",
                charid    = "",
                height    = "",
                weight    = "",
                city      = Config.IDCardNPC[city].fakeLabel,
                img       = link,
                itemId    = PrintPhotoId,
                religious = Config.Religious[math.random(1, #Config.Religious)],
            }
            TriggerClientEvent("fx-idcard:client:CreateIdcardUi", src, fakeData, true)
        end
    else
        TriggerClientEvent("fx-idcard:client:ShowUi", src, "photo", {img = link})
    end
end)

FXRegisterUsableItem(Config.ManIdCardItem, function(data)
    local src = data.source
    FXCloseInventory(src)
    TriggerClientEvent("fx-idcard:client:ShowUi", src, "idcard", data.item.metadata.CardData)
end)

FXRegisterUsableItem(Config.WomanIdCardItem, function(data)
    local src = data.source
    FXCloseInventory(src)
    TriggerClientEvent("fx-idcard:client:ShowUi", src, "idcard", data.item.metadata.CardData)
end)

RegisterNetEvent("fx-idcard:server:ShowIdCard", function(data)
    local src = source
    TriggerClientEvent("fx-idcard:client:ShowUi", src, "idcard", data)
end)

RegisterNetEvent('fx-idcard:server:buyIdCard', function(data)
    local src       = source
    local Character = FXGetPlayerData(src)
    local charid    = Character.charIdentifier
    local price     = data.illegal and (Config.Prices.illegal or 0) or (Config.Prices.idcard or 0)

    if price > 0 then
        if FXHaveMoney(src, "cash", price) then
            FXRemoveMoney(src, "cash", price)
            local removed = FXRemoveItem(src, Config.PrintPhotoItem, 1, {img=data.img}, tonumber(data.itemId))
            if not removed then
                return Notify({ source=src, text=Locale("noprintphoto"), type="error", time=4000 })
            end
        else
            return Notify({ source=src, text=Locale("nomoney",{money=price}), type="error", time=4000 })
        end
    end

    -- Fake ID — randomise charid
    if data.illegal then
        local len = string.len(tostring(charid))
        charid = math.random(10^(len-1), (10^len)-1)
    end

    -- Build license number with prefix
    local licenseNumber = Config.LicensePrefix .. "-" .. string.format("%06d", charid)

    if Config.TakeCardType == "sql" then
        exports.oxmysql:execute("SELECT * FROM pac_idcard WHERE charid = ?", {charid}, function(result)
            if not result[1] then
                exports.oxmysql:execute(
                    "INSERT INTO pac_idcard (`charid`, `data`) VALUES (@charid, @data)",
                    { charid = charid, data = json.encode(data) }
                )
                TriggerClientEvent('fx-idcard:client:setData', src, data)
                Notify({ source=src, text=Locale("successidcard"), type="success", time=4000 })
            else
                Notify({ source=src, text=Locale("alreadyidcard"), type="error", time=4000 })
            end
        end)
    elseif Config.TakeCardType == "item" then
        if not data.illegal then
            exports.oxmysql:execute("SELECT * FROM pac_idcard WHERE charid = ?", {charid}, function(result)
                if not result[1] then
                    exports.oxmysql:execute(
                        "INSERT INTO pac_idcard (`charid`, `data`) VALUES (@charid, @data)",
                        { charid = charid, data = json.encode(data) }
                    )
                    TriggerClientEvent('fx-idcard:client:setData', src, data)
                    Notify({ source=src, text=Locale("successidcard"), type="success", time=4000 })
                else
                    Notify({ source=src, text=Locale("alreadyidcard"), type="error", time=4000 })
                end
            end)
        end

        local item = data.sex == "Female" and Config.WomanIdCardItem or Config.ManIdCardItem
        local metadata = {
            description = Locale("idcarddesc", { name=data.name, charid=licenseNumber }),
            CardData = {
                name      = data.name,
                cityname  = data.cityname,
                religious = data.religious,
                age       = data.age,
                date      = data.date,
                height    = data.height,
                weight    = data.weight,
                hair      = data.hair,
                eye       = data.eye,
                sex       = data.sex,
                charid    = licenseNumber,
                img       = data.img,
            }
        }
        FXAddItem(src, item, 1, metadata)
        Notify({ source=src, text=Locale("addIdCard"), type="success", time=4000 })
    end
end)
