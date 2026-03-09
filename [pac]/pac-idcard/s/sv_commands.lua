-- /deleteidcard [serverid]
RegisterCommand(Config.DeletePlayerDataCommand, function(source, args)
    if not args or not args[1] then
        return Notify({ source=source, text=Locale("errorcommand"), type="error", time=4000 })
    end

    local src       = source
    local srcData   = FXGetPlayerData(src)
    local isAdmin   = srcData.admin
    local isAuthJob = false

    for _, job in ipairs(Config.AuthorizedJobs) do
        if srcData.job == job then isAuthJob = true; break end
    end

    if not isAdmin and not isAuthJob then
        return Notify({ source=src, text=Locale("nojob"), type="error", time=4000 })
    end

    local targetId   = tonumber(args[1])
    local targetData = FXGetPlayerData(targetId)
    if not targetData then
        return Notify({ source=src, text="Player not found.", type="error", time=4000 })
    end

    local charid = targetData.charIdentifier

    -- Save prev_license before deletion
    exports.oxmysql:execute("SELECT data FROM pac_idcard WHERE charid = ?", {charid}, function(result)
        if result and result[1] then
            local cardData = json.decode(result[1].data)
            local prevLicense = cardData.charid or ""
            exports.oxmysql:execute(
                "INSERT INTO pac_idcard_history (charid, prev_license, deleted_at) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE prev_license=VALUES(prev_license), deleted_at=NOW()",
                { charid, prevLicense }
            )
        end
        exports.oxmysql:execute("DELETE FROM pac_idcard WHERE charid = ?", {charid})
        TriggerClientEvent('fx-idcard:client:clearData', targetId)
        Notify({ source=src, text=Locale("successdelete"), type="success", time=4000 })
    end)
end, false)

-- /checkid [serverid]
RegisterCommand(Config.CheckIdCommand, function(source, args)
    if not args or not args[1] then
        return Notify({ source=source, text="Usage: /" .. Config.CheckIdCommand .. " [serverid]", type="error", time=4000 })
    end

    local src       = source
    local srcData   = FXGetPlayerData(src)
    local isAdmin   = srcData.admin
    local isAuthJob = false

    for _, job in ipairs(Config.AuthorizedJobs) do
        if srcData.job == job then isAuthJob = true; break end
    end

    if not isAdmin and not isAuthJob then
        return Notify({ source=src, text=Locale("nojob"), type="error", time=4000 })
    end

    local targetId   = tonumber(args[1])
    local targetData = FXGetPlayerData(targetId)
    if not targetData then
        return Notify({ source=src, text="Player not found.", type="error", time=4000 })
    end

    local realCharid = targetData.charIdentifier

    exports.oxmysql:execute("SELECT data FROM pac_idcard WHERE charid = ?", {realCharid}, function(result)
        if not result or not result[1] then
            return Notify({ source=src, text="~COLOR_RED~No ID card on file for this person.", type="error", time=5000 })
        end

        local cardData    = json.decode(result[1].data)
        local cardCharid  = tostring(cardData.charid or "")
        local realStr     = tostring(realCharid)

        -- Forgery check: card charid doesn't match real charid
        local isForgery = not cardCharid:find(realStr, 1, true)

        if isForgery then
            -- Log it
            exports.oxmysql:execute(
                "INSERT INTO pac_idcard_forgery_log (real_charid, card_charid, checked_by, checked_at) VALUES (?, ?, ?, NOW())",
                { realCharid, cardCharid, realCharid }
            )
            Notify({ source=src, text="~COLOR_RED~FORGERY DETECTED~COLOR_WHITE~ — This ID does not match territory records.", type="error", time=6000 })
        else
            Notify({ source=src, text="~COLOR_GREEN~ID VERIFIED~COLOR_WHITE~ — " .. (cardData.name or "Unknown") .. " | " .. cardCharid, type="success", time=5000 })
        end
    end)
end, false)
