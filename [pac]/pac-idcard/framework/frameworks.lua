LoadTimeout = 30
Framework = "none"
onPlayerLoadEvent = "none"

if GetResourceState('vorp_core') == 'started' then
    Framework = "VORP"
    onPlayerLoadEvent = "vorp:SelectedCharacter"
    print("^2[INFO]^0 Framework selected: ^3" .. Framework .. "^0")
else
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            print("^1[ERROR]^0 No suitable framework found. ^2Please install ^3vorp_core^0.")
        end
    end)
end

if IsDuplicityVersion() then
    if Framework == "VORP" then
        local VorpCore = exports.vorp_core:GetCore()
        VorpInv = exports.vorp_inventory:vorp_inventoryApi()

        function FXRegisterUsableItem(itemname, callBack)
            exports.vorp_inventory:registerUsableItem(itemname, function(data)
                callBack({ source = data.source, item = data.item })
            end)
        end

        function FXCloseInventory(src)
            exports.vorp_inventory:closeInventory(src)
        end

        function FXRemoveItem(src, itemName, itemCount, Metadata, ItemId)
            Metadata = Metadata or {}
            if ItemId then
                return exports.vorp_inventory:subItemById(src, ItemId)
            else
                return exports.vorp_inventory:subItem(src, itemName, itemCount, Metadata)
            end
        end

        function FXAddItem(src, itemName, itemCount, Metadata)
            return exports.vorp_inventory:addItem(src, itemName, itemCount, Metadata)
        end

        function FXHaveMoney(src, moneytype, count)
            local User      = VorpCore.getUser(src)
            local Character = User.getUsedCharacter
            if moneytype == "cash"  and Character.money >= count then return true end
            if moneytype == "gold"  and Character.gold  >= count then return true end
            return false
        end

        function FXRemoveMoney(src, moneytype, count)
            local User      = VorpCore.getUser(src)
            local Character = User.getUsedCharacter
            Character.removeCurrency(moneytype == "gold" and 1 or 0, count)
            return true
        end

        function FXAddMoney(src, moneytype, count)
            local User      = VorpCore.getUser(src)
            local Character = User.getUsedCharacter
            Character.addCurrency(moneytype == "gold" and 1 or 0, count)
            return true
        end

        function FXGetCharacterInformations(src, charid, cb)
            local array = {}
            exports.oxmysql:execute("SELECT * FROM characters WHERE charidentifier = ?", {charid}, function(result)
                if result[1] then
                    array.height    = json.decode(result[1].skinPlayer).Scale
                    array.sex       = result[1].gender
                    array.weight    = math.random(result[1].gender == "Male" and 70 or 45, result[1].gender == "Male" and 100 or 65)
                    array.firstname = result[1].firstname
                    array.lastname  = result[1].lastname
                    array.age       = result[1].age
                end
                cb(array)
            end)
        end

        function FXGetPlayerData(src)
            local User      = VorpCore.getUser(src)
            local Character = User.getUsedCharacter
            return {
                firstname      = Character.firstname,
                lastname       = Character.lastname,
                charIdentifier = Character.charIdentifier,
                cash           = Character.money,
                gold           = Character.gold,
                admin          = User.getGroup == "admin",
                job            = Character.job,
            }
        end
    end
else
    -- Client side
    if Framework == "VORP" then
        VorpCore = exports.vorp_core:GetCore()

        RegisterNetEvent('vorp:SelectedCharacter', function()
            TriggerServerEvent('fx-idcard:server:GetData')
        end)
    end
end
