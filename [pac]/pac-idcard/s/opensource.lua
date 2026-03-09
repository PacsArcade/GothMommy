-- Jobs that can use /checkid and /deleteidcard
local AuthorizedJobs = {
    ["sheriff"] = true,
    ["lawenforcement"] = true,
    ["marshal"] = true,
    ["deputy"] = true,
}

local function isAuthorized(src)
    local Character = FXGetPlayerData(src)
    if Character.admin then return true end
    if Character.job and AuthorizedJobs[Character.job] then return true end
    return false
end

RegisterCommand(Config.DeletePlayerDataCommand, function(source, args)
    if args and args[1] then
        local src = source
        if isAuthorized(src) then
            local target = FXGetPlayerData(tonumber(args[1]))
            local targetCharId = target.charIdentifier

            -- Save previous license number before deleting
            exports.oxmysql:execute("SELECT data FROM fx_idcard WHERE charid = ?", {targetCharId}, function(result)
                local prevLicense = string.format("GMRP-%s", tostring(targetCharId))
                if result and result[1] then
                    local ok, decoded = pcall(json.decode, result[1].data)
                    if ok and decoded and decoded.charid then
                        prevLicense = string.format("GMRP-%s", tostring(decoded.charid))
                    end
                end

                exports.oxmysql:execute(
                    "DELETE FROM fx_idcard WHERE charid = ?",
                    {targetCharId},
                    function()
                        -- Store prev_license so next card creation can reference it
                        exports.oxmysql:execute(
                            "INSERT INTO fx_idcard_history (charid, prev_license, deleted_at) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE prev_license = VALUES(prev_license), deleted_at = NOW()",
                            {targetCharId, prevLicense}
                        )
                        TriggerClientEvent('fx-idcard:client:updateData', tonumber(args[1]))
                        Notify({
                            source = source,
                            text = Locale("successdelete"),
                            type = "success",
                            time = 4000
                        })
                    end
                )
            end)
        else
            Notify({
                source = source,
                text = Locale("nojob"),
                type = "error",
                time = 4000
            })
        end
    else
        Notify({
            source = source,
            text = Locale("errorcommand"),
            type = "error",
            time = 4000
        })
    end
end)

-- /checkid [playerid] - Law enforcement + admin only
-- Compares the presented card's charid against the real character identifier.
-- A mismatch means the card is forged.
RegisterCommand("checkid", function(source, args)
    if not isAuthorized(source) then
        Notify({
            source = source,
            text = "You are not authorized to verify identity documents.",
            type = "error",
            time = 4000
        })
        return
    end

    if not args or not args[1] then
        Notify({
            source = source,
            text = "Usage: /checkid [player server id]",
            type = "error",
            time = 4000
        })
        return
    end

    local targetSrc = tonumber(args[1])
    if not targetSrc then
        Notify({
            source = source,
            text = "Invalid player ID.",
            type = "error",
            time = 4000
        })
        return
    end

    local targetChar = FXGetPlayerData(targetSrc)
    if not targetChar then
        Notify({
            source = source,
            text = "Could not retrieve target player data.",
            type = "error",
            time = 4000
        })
        return
    end

    local realCharId = targetChar.charIdentifier

    exports.oxmysql:execute("SELECT data FROM fx_idcard WHERE charid = ?", {realCharId}, function(result)
        if not result or not result[1] then
            -- No card on file at all
            Notify({
                source = source,
                text = string.format("~COLOR_YELLOW~%s %s~COLOR_WHITE~ has no identity card on record.", targetChar.firstname, targetChar.lastname),
                type = "error",
                time = 6000
            })
            return
        end

        local ok, cardData = pcall(json.decode, result[1].data)
        if not ok or not cardData then
            Notify({
                source = source,
                text = "Error reading identity card data.",
                type = "error",
                time = 4000
            })
            return
        end

        local cardCharId = tostring(cardData.charid)
        local realCharIdStr = tostring(realCharId)

        if cardCharId ~= realCharIdStr then
            -- Charid mismatch = forged card
            Notify({
                source = source,
                text = string.format("~COLOR_RED~FORGERY DETECTED~COLOR_WHITE~ — Card ID ~COLOR_YELLOW~%s~COLOR_WHITE~ does not match record for ~COLOR_YELLOW~%s %s~COLOR_WHITE~.", cardCharId, targetChar.firstname, targetChar.lastname),
                type = "error",
                time = 8000
            })
            -- Also alert the target player that their documents were inspected
            Notify({
                source = targetSrc,
                text = "An officer has inspected your identity documents.",
                type = "info",
                time = 5000
            })
        else
            -- Legitimate card
            Notify({
                source = source,
                text = string.format("~COLOR_GREEN~IDENTITY VERIFIED~COLOR_WHITE~ — ~COLOR_YELLOW~%s %s~COLOR_WHITE~, Card No: ~COLOR_YELLOW~GMRP-%s~COLOR_WHITE~.", targetChar.firstname, targetChar.lastname, cardCharId),
                type = "success",
                time = 6000
            })
            Notify({
                source = targetSrc,
                text = "An officer has inspected your identity documents.",
                type = "info",
                time = 5000
            })
        end
    end)
end)
