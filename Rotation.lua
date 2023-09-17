-- Growtopia Rotation Script v1.8.9
-- If you need any help with item ids you can go to https://github.com/Edinbo/Growtopia_IDList/blob/main/itemid.txt
-- also if you need any help with pack names you can go to https://github.com/Edinbo/Growtopia_IDList/blob/main/packid.txt aswell

Bot = {}

Bot["IMHANDSOME19"] = {
    slot = 1,
    webhookLink = "", -- Discord Webhook Link
    messageId = "", -- send a message with your webhook and copy that message id 
    startFrom = 1, -- start from (which world from the list))
    worldList = {"World1", "World2", "World3"}, --World List
    doorFarm = "doorid", -- World Door ID
    upgradeBackpack = 0
}



webhookOffline = "" -- Discord Webhook Link

webhookLinkPack = "" -- Discord Webhook Link
messageIdPack = "" -- send a message with your webhook and copy that message id 

webhookLinkSeed = "" -- Discord Webhook Link
messageIdSeed = "" -- send a message with your webhook and copy that message id 

storageSeed, doorSeed, patokanSeed = "CMVZV", "SEEDST0RAGE", 16 -- Seed Storage World, Seed Storage door ID, where to drop via ID (for example 16 = grass (so it drops seeds on grass))
storagePack, doorPack, patokanPack = "CMVZW", "PACKST0RAGE", 1422 -- Pack Storage World, Pack Storage door ID, where to drop via ID (for example 1422 = Display Box (so pack is dropped on display box))

statusLink = "" -- Discord Webhook Link
statusLinkBot = true -- true = status link on, false = off

blacklistTile = false -- tiles to never go
blacklist = {
    {x = -1, y = -1},
    {x = 0, y = -1},
    {x = 1, y = -1}
}

itmId = 4584 -- Which block to break via ID (4584 = Pepper Tree)
itmSeed = itmId + 1 -- Which seed to plant (4584 + 1 = Pepper Tree Seed)

delayHarvest = 130 -- harvest delay (in ms)
delayPlant = 130 -- plant delay (in ms)
delayPunch = 170 -- punch delay (in ms)
delayPlace = 130 -- place delay (in ms)

tileNumber = 5 -- if its 5 when you are breaking the farmables you break 5 tiles at once
customTile = false -- custom place to break
customX = 0 -- custom place x
customY = 0 -- custom place y

separatePlant = false -- plant seperately
dontPlant = false -- dont plant seed
buyAfterPNB = true -- buy after place and break
root = false -- root
looping = true -- loop after finishing worlds

pack = "World Lock [2000 Gems]" -- this is title for webhook you dont need to change this
packList = {242} -- id (this is world lock id)
packName = "world_lock" -- pack name
minimumGem = 2000 -- minimum gem to start buying (you can set this to 20k and buy when you have 20k gems in your account)
packPrice = 2000 -- pack price
packLimit = 200 -- limit to buy until inventory is full

joinWorldAfterStore = false -- after storing join world (recommended = false)
worldToJoin = {"World1", "World2", "World3"} -- world list to join after storing
joinDelay = 5000 -- join delay

restartTimer = true -- restart timer
customShow = false -- custom show
showList = 3 -- show only 3 

goods = {98, 18, 32, 6336, 9640, itmId, itmSeed} -- anything other than this will get deleted from inventory

items = {
    {name = "World Lock", id = 242, emote = "<:world_lock:1011929928519925820>"}, -- webhook texts
    {name = "Pepper Tree", id = 4584, emote = "<:pepper_tree:1011930020836544522>"},
    {name = "Pepper Tree Seed", id = 4585, emote = "<:pepper_tree_seed:1011930051744374805>"},
}

list = {}
tree = {}
waktu = {}
worlds = {}
fossil = {}
tileBreak = {}
loop = 0
profit = 0
listNow = 1
strWaktu = ""
t = os.time()
start = Bot[getBot().name:upper()].startFrom
stop = #Bot[getBot().name:upper()].worldList
doorFarm = Bot[getBot().name:upper()].doorFarm
messageId = Bot[getBot().name:upper()].messageId
worldList = Bot[getBot().name:upper()].worldList
totalList = #Bot[getBot().name:upper()].worldList
webhookLink = Bot[getBot().name:upper()].webhookLink
upgradeBackpack = Bot[getBot().name:upper()].upgradeBackpack

for i = start,#worldList do
    table.insert(worlds,worldList[i])
end

if looping then
    for i = 0,start - 1 do
        table.insert(worlds,worldList[i])
    end
end

for _,pack in pairs(packList) do
    table.insert(goods,pack)
end

for i = math.floor(tileNumber/2),1,-1 do
    i = i * -1
    table.insert(tileBreak,i)
end
for i = 0, math.ceil(tileNumber/2) - 1 do
    table.insert(tileBreak,i)
end

if (showList - 1) >= #worldList then
    customShow = false
end

if dontPlant then
    separatePlant = false
end

function includesNumber(table, number)
    for _,num in pairs(table) do
        if num == number then
            return true
        end
    end
    return false
end

function bl(world)
    blist = {}
    fossil[world] = 0
    for _,tile in pairs(getTiles()) do
        if tile.fg == 6 then
            doorX = tile.x
            doorY = tile.y
        elseif tile.fg == 3918 then
            fossil[world] = fossil[world] + 1
        end
    end
    if blacklistTile then
        for _,tile in pairs(blacklist) do
            table.insert(blist,{x = doorX + tile.x, y = doorY + tile.y})
        end
    end
end

function tilePunch(x,y)
    for _,num in pairs(tileBreak) do
        if getTile(x - 1,y + num).fg ~= 0 or getTile(x - 1,y + num).bg ~= 0 then
            return true
        end
    end
    return false
end

function tilePlace(x,y)
    for _,num in pairs(tileBreak) do
        if getTile(x - 1,y + num).fg == 0 and getTile(x - 1,y + num).bg == 0 then
            return true
        end
    end
    return false
end

function check(x,y)
    for _,tile in pairs(blist) do
        if x == tile.x and y == tile.y then
            return false
        end
    end
    return true
end

function warp(world,id)
    nukecheck = 0
    while getBot().world ~= world:upper() and not nuked do
        while getBot().status ~= "online" do
            sleep(1000)
        end
        sendPacket(3,"action|join_request\nname|"..world:upper().."\ninvitedWorld|0")
        sleep(5000)
        if nukecheck == 50 then
            nuked = true
        else
            nukecheck = nukecheck + 1
        end
    end
    if id ~= "" and not nuked then
        while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 and not nuked do
            while getBot().status ~= "online" do
                sleep(1000)
            end
            sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
            sleep(1000)
        end
    end
end

function waktuWorld()
    strWaktu = ""
    if customShow then
        for i = showList,1,-1 do
            newList = listNow - i
            if newList <= 0 then
                newList = newList + totalList
            end
            strWaktu = strWaktu.."\n"..worldList[newList]:upper().." ( "..(waktu[worldList[newList]] or "?").." | "..(tree[worldList[newList]] or "?").." )"
        end
    else
        for _,world in pairs(worldList) do
            strWaktu = strWaktu.."\n"..world:upper().." ( "..(waktu[world] or "?").." | "..(tree[world] or "?").." )"
        end
    end
end

function botInfo(info)
    te = os.time() - t
    fossill = fossil[getBot().world] or 0
    local text = [[
        $webHookUrl = "]]..webhookLink..[[/messages/]]..messageId..[["
        $CPU = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select -ExpandProperty Average
        $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
        $Memory = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
        $RAM = [math]::Round($Memory, 0)
        $thumbnailObject = @{
            url = ""
        }
        $footerObject = @{
            text = "by https://github.com/Edinbo"
        }
        $fieldArray = @(
            @{
                name = "Current Status"
                value = "]]..info..[["
                inline = "false"
            }
            @{
                name = "GrowID"
                value = "]]..getBot().name..[["
                inline = "true"
            }
            @{
                name = "Status"
                value = "]]..getBot().status..[["
                inline = "true"
            }
            @{
                name = "Level"
                value = "]]..getBot().level..[["
                inline = "true"
            }
            @{
                name = "Captcha"
                value = "]]..getBot().captcha..[["
                inline = "true"
            }
            @{
                name = "Gems"
                value = "]]..findItem(112)..[["
                inline = "true"
            }
            @{
                name = "Current World"
                value = "]]..getBot().world..[["
                inline = "true"
            }
            @{
                name = "Fossil Count"
                value = "]]..fossill..[["
                inline = "true"
            }
            @{
                name = "World Order (]]..loop..[[ Loop)"
                value = "]]..start..[[ / ]]..stop..[["
                inline = "true"
            }
            @{
                name = "Pack"
                value = "]]..pack..[["
                inline = "true"
            }
            @{
                name = "Profit"
                value = "]]..profit..[[ WL"
                inline = "true"
            }
            @{
                name = "CPU & RAM Usage"
                value = "$CPU% CPU Usage | $RAM% RAM Usage"
                inline = "true"
            }
            @{
                name = "World List"
                value = "]]..strWaktu..[["
                inline = "false"
            }
            @{
                name = "Bot Uptime"
                value = "]]..math.floor(te/86400)..[[ Days ]]..math.floor(te%86400/3600)..[[ Hours ]]..math.floor(te%86400%3600/60)..[[ Minutes"
                inline = "false"
            }
        )
        $embedObject = @{
            title = "**]]..getBot().name..[[ | Slot - ]]..Bot[getBot().name:upper()].slot..[[**"
            color = "]]..math.random(1111111,9999999)..[["
            thumbnail = $thumbnailObject
            footer = $footerObject
            fields = $fieldArray
        }
        $embedArray = @($embedObject)
        $payload = @{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

function packInfo(link,id,desc)
    local text = [[
        $webHookUrl = "]]..link..[[/messages/]]..id..[["
        $thumbnailObject = @{
            url = ""
        }
        $footerObject = @{
            text = "by Edinbo"
        }
        $fieldArray = @(
            @{
                name = "Dropped Items"
                value = "]]..desc..[["
                inline = "false"
            }
        )
        $embedObject = @{
            title = "**Pack and Seed | Info**"
            color = "]]..math.random(111111,999999)..[["
            thumbnail = $thumbnailObject
            footer = $footerObject
            fields = $fieldArray
        }
        $embedArray = @($embedObject)
        $payload = @{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

function reconInfo()
    local text = [[
        $webHookUrl = "]]..webhookOffline..[["
        $payload = @{
            content = "]]..getBot().name..[['s ( Slot - ]]..Bot[getBot().name:upper()].slot..[[ ) Current Status Is ]]..getBot().status..[[ @everyone"
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

function getContent(link)
    local cmd = io.popen('powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Write-Host (Invoke-WebRequest -Uri "'..link..'")"')
    return cmd:read("*all")
end

function reconnect(world,id,x,y)
    if getBot().status ~= "online" then
        botInfo("Reconnecting")
        sleep(100)
        reconInfo()
        sleep(100)
        while true do
            connect()
            sleep(1000)
            while getBot().status == "online" and getBot().world ~= world:upper() do
                sendPacket(3,"action|join_request\nname|"..world:upper().."\ninvitedWorld|0")
                sleep(5000)
            end
            if getBot().status == "online" and getBot().world == world:upper() then
                if id ~= "" then
                    while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 do
                        sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
                        sleep(1000)
                    end
                end
                if x and y and getBot().status == "online" and getBot().world == world:upper() then
                    while math.floor(getBot().x / 32) ~= x or math.floor(getBot().y / 32) ~= y do
                        findPath(x,y)
                        sleep(100)
                    end
                end
                if getBot().status == "online" and getBot().world == world:upper() then
                    if x and y then
                        if getBot().status == "online" and math.floor(getBot().x / 32) == x and math.floor(getBot().y / 32) == y then
                            break
                        end
                    elseif getBot().status == "online" then
                        break
                    end
                end
            end
        end
        botInfo("Succesfully Reconnected")
        sleep(100)
        reconInfo()
        sleep(100)
        botInfo("Farming")
        sleep(100)
    end
end

function round(n)
    return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function tileDrop1(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if stack < 20 and count <= (4000 - num) then
        return true
    end
    return false
end

function tileDrop2(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if count <= (4000 - num) then
        return true
    end
    return false
end

function storePack()
    for _,pack in pairs(packList) do
        for _,tile in pairs(getTiles()) do
            if tile.fg == packID or tile.bg == packID then
                if tileDrop1(tile.x,tile.y,findItem(pack)) then
                    while math.floor(getBot().x / 32) ~= (tile.x - 1) or math.floor(getBot().y / 32) ~= tile.y do
                        findPath(tile.x - 1,tile.y)
                        sleep(1000)
                        reconnect(storagePack,doorPack,tile.x - 1,tile.y)
                    end
                    while findItem(pack) > 0 and tileDrop1(tile.x,tile.y,findItem(pack)) do
                        sendPacket(2,"action|drop\n|itemID|"..pack)
                        sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..pack.."|\ncount|"..findItem(pack))
                        sleep(500)
                        reconnect(storagePack,doorPack,tile.x - 1,tile.y)
                    end
                end
            end
            if findItem(pack) == 0 then
                break
            end
        end
    end
end

function itemInfo(ids)
    local result = {name = "null", id = ids, emote = "null"}
    for _,item in pairs(items) do
        if item.id == ids then
            result.name = item.name
            result.emote = item.emote
            return result
        end
    end
    return result
end

function infoPack()
    local store = {}
    for _,obj in pairs(getObjects()) do
        if store[obj.id] then
            store[obj.id].count = store[obj.id].count + obj.count
        else
            store[obj.id] = {id = obj.id, count = obj.count}
        end
    end
    local str = ""
    for _,object in pairs(store) do
        str = str.."\n"..itemInfo(object.id).emote.." "..itemInfo(object.id).name.." : x"..object.count
    end
    return str
end

function join()
    botInfo("Clearing World Logs")
    sleep(100)
    for _,wurld in pairs(worldToJoin) do
        warp(wurld,"")
        sleep(joinDelay)
        reconnect(wurld,"")
    end
end

function storeSeed(world)
    botInfo("Storing Seed")
    sleep(100)
    collectSet(false,3)
    sleep(100)
    warp(storageSeed,doorSeed)
    sleep(100)
    for _,tile in pairs(getTiles()) do
        if tile.fg == patokanSeed or tile.bg == patokanSeed then
            if tileDrop2(tile.x,tile.y,100) then
                while math.floor(getBot().x / 32) ~= (tile.x - 1) or math.floor(getBot().y / 32) ~= tile.y do
                    findPath(tile.x - 1,tile.y)
                    sleep(1000)
                    reconnect(storageSeed,doorSeed,tile.x - 1,tile.y)
                end
                while findItem(itmSeed) >= 100 and tileDrop2(tile.x,tile.y,100) do
                    sendPacket(2,"action|drop\n|itemID|"..itmSeed)
                    sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..itmSeed.."|\ncount|100")
                    sleep(500)
                    reconnect(storageSeed,doorSeed,tile.x - 1,tile.y)
                end
            end
            if findItem(itmSeed) < 100 then
                break
            end
        end
    end
    packInfo(webhookLinkSeed,messageIdSeed,infoPack())
    sleep(100)
    if joinWorldAfterStore then
        join()
        sleep(100)
    end
    warp(world,doorFarm)
    sleep(100)
    collectSet(true,3)
    sleep(100)
    botInfo("Farming")
    sleep(100)
end

function buy()
    botInfo("Buying and Storing Pack")
    sleep(100)
    collectSet(false,3)
    sleep(100)
    warp(storagePack,doorPack)
    sleep(100)
    while findItem(112) >= packPrice do
        for i = 1, packLimit do
            sendPacket(2,"action|buy\nitem|"..packName)
            sleep(500)
            if findItem(packList[0]) == 0 then
                sendPacket(2,"action|buy\nitem|upgrade_backpack")
                sleep(500)
            else
                profit = profit + 1
            end
            if findItem(112) < packPrice then
                break
            end
        end
        storePack()
        sleep(100)
        reconnect(storagePack,doorPack)
    end
    packInfo(webhookLinkPack,messageIdPack,infoPack())
    sleep(100)
    if joinWorldAfterStore then
        join()
        sleep(100)
    end
end

function clear()
    for _,item in pairs(getInventory()) do
        if not includesNumber(goods, item.id) then
            sendPacket(2, "action|trash\n|itemID|"..item.id)
            sendPacket(2, "action|dialog_return\ndialog_name|trash_item\nitemID|"..item.id.."|\ncount|"..item.count) 
            sleep(100)
        end
    end
end

function take(world)
    botInfo("Taking Seed")
    sleep(100)
    while findItem(itmSeed) == 0 do
        collectSet(false,3)
        sleep(100)
        warp(storageSeed,doorSeed)
        sleep(100)
        for _,obj in pairs(getObjects()) do
            if obj.id == itmSeed then
                findPath(round(obj.x / 32),math.floor(obj.y / 32))
                sleep(1000)
                collect(2)
                sleep(1000)
            end
            if findItem(itmSeed) == 200 then
                sendPacket(2,"action|drop\n|itemID|"..itmSeed)
                sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..itmSeed.."|\ncount|100")
                break
            end
        end
        packInfo(webhookLinkSeed,messageIdSeed,infoPack())
        sleep(100)
        if joinWorldAfterStore then
            join()
            sleep(100)
        end
        warp(world,doorFarm)
        sleep(100)
        collectSet(true,3)
        sleep(100)
    end
end

function plant(world)
    for _,tile in pairs(getTiles()) do
        if findItem(itmSeed) == 0 and not dontPlant then
            take(world)
            sleep(100)
            botInfo("Farming")
            sleep(100)
        end
        if tile.flags ~= 0 and tile.y ~= 0 and getTile(tile.x,tile.y - 1).fg == 0 then
            if not blacklistTile or check(tile.x,tile.y) then
                findPath(tile.x,tile.y - 1)
                while getTile(tile.x,tile.y - 1).fg == 0 and getTile(tile.x,tile.y).flags ~= 0 do
                    place(itmSeed,0,0)
                    sleep(delayPlant)
                    reconnect(world,doorFarm,tile.x,tile.y - 1)
                end
            end
        end
    end
    if findItem(itmSeed) >= 100 then
        storeSeed(world)
        sleep(100)
    end
end

function pnb(world)
    if findItem(itmId) >= tileNumber then
        if not customTile then
            ex = 1
            ye = math.floor(getBot().y / 32)
            if ye > 40 then
                ye = ye - 10
            elseif ye < 11 then
                ye = ye + 10
            end
            if getTile(ex,ye).fg ~= 0 and getTile(ex,ye).fg ~= itmSeed then
                ye = ye - 1
            end
        else
            ex = customX
            ye = customY
        end
        while math.floor(getBot().x / 32) ~= ex or math.floor(getBot().y / 32) ~= ye do
            findPath(ex,ye)
            sleep(100)
        end
        if tileNumber > 1 then
            while findItem(itmId) >= tileNumber and findItem(itmSeed) < 190 do
                while tilePlace(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg == 0 and getTile(ex - 1,ye + i).bg == 0 then
                            place(itmId,-1,i)
                            sleep(delayPlace)
                            reconnect(world,doorFarm,ex,ye)
                        end
                    end
                end
                while tilePunch(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg ~= 0 or getTile(ex - 1,ye + i).bg ~= 0 then
                            punch(-1,i)
                            sleep(delayPunch)
                            reconnect(world,doorFarm,ex,ye)
                        end
                    end
                end
                reconnect(world,doorFarm,ex,ye)
            end
        else
            while findItem(itmId) > 0 and findItem(itmSeed) < 190 do
                while getTile(ex - 1,ye).fg == 0 and getTile(ex - 1,ye).bg == 0 do
                    place(itmId,-1,0)
                    sleep(delayPlace)
                    reconnect(world,doorFarm,ex,ye)
                end
                while getTile(ex - 1,ye).fg ~= 0 or getTile(ex - 1,ye).bg ~= 0 do
                    punch(-1,0)
                    sleep(delayPunch)
                    reconnect(world,doorFarm,ex,ye)
                end
            end
        end
        clear()
        sleep(100)
         if statusLinkBot then
          if request("GET",statusLink) == "Offline" and getBot().status == "online" then
            disconnect()
            sleep(1000)
          while request("GET",statusLink) == "Offline" do
               sleep(10000)
            end
               connect()
               sleep(1000)
               recon = true
              elseif request("GET",statusLink) == "online" and getBot().status == "offline" then
                    connect()
                   sleep(1000)
               end
            end
        if buyAfterPNB and findItem(112) >= minimumGem then
            buy()
            sleep(100)
            warp(world,doorFarm)
            sleep(100)
            collectSet(true,3)
            sleep(100)
            botInfo("Farming")
            sleep(100)
        end
    end
end

function harvest(world)
    botInfo("Farming")
    sleep(100)
    tree[world] = 0
    if dontPlant then
        for _,tile in pairs(getTiles()) do
            if getTile(tile.x,tile.y - 1).ready and getTile(tile.x,tile.y - 1).fg == itmSeed then
                if not blacklistTile or check(tile.x,tile.y) then
                    tree[world] = tree[world] + 1
                    findPath(tile.x,tile.y - 1)
                    while getTile(tile.x,tile.y - 1).fg == itmSeed do
                        punch(0,0)
                        sleep(delayHarvest)
                        reconnect(world,doorFarm,tile.x,tile.y - 1)
                    end
                    if root then
                        while getTile(tile.x, tile.y).fg == (itmId + 4) and getTile(tile.x, tile.y).flags ~= 0 do
                            punch(0, 1)
                            sleep(delayHarvest)
                            reconnect(world,doorFarm,tile.x,tile.y - 1)
                        end
                        clear()
                        sleep(100)
                    end
                end
            end
            if findItem(itmId) >= 190 then
                pnb(world)
                sleep(100)
                if findItem(itmSeed) >= 190 then
                    storeSeed(world)
                    sleep(100)
                end
            end
        end
    elseif not separatePlant then
        for _,tile in pairs(getTiles()) do
            if findItem(itmSeed) == 0 then
                take(world)
                sleep(100)
                botInfo("Farming")
                sleep(100)
            end
            if getTile(tile.x,tile.y - 1).ready or (tile.flags ~= 0 and tile.y ~= 0 and getTile(tile.x,tile.y - 1).fg == 0) then
                if not blacklistTile or check(tile.x,tile.y) then
                    tree[world] = tree[world] + 1
                    findPath(tile.x,tile.y - 1)
                    while getTile(tile.x,tile.y - 1).fg == itmSeed do
                        punch(0,0)
                        sleep(delayHarvest)
                        reconnect(world,doorFarm,tile.x,tile.y - 1)
                    end
                    if root then
                        while getTile(tile.x, tile.y).fg == (itmId + 4) and getTile(tile.x, tile.y).flags ~= 0 do
                            punch(0, 1)
                            sleep(delayHarvest)
                            reconnect(world,doorFarm,tile.x,tile.y - 1)
                        end
                        clear()
                        sleep(100)
                    end
                    while getTile(tile.x,tile.y - 1).fg == 0 and getTile(tile.x,tile.y).flags ~= 0 do
                        place(itmSeed,0,0)
                        sleep(delayPlant)
                        reconnect(world,doorFarm,tile.x,tile.y - 1)
                    end
                end
            end
            if findItem(itmId) >= 190 then
                pnb(world)
                sleep(100)
                if findItem(itmSeed) >= 190 then
                    storeSeed(world)
                    sleep(100)
                end
            end
        end
    else
        for _,tile in pairs(getTiles()) do
            if getTile(tile.x,tile.y - 1).ready then
                if not blacklistTile or check(tile.x,tile.y) then
                    tree[world] = tree[world] + 1
                    findPath(tile.x,tile.y - 1)
                    while getTile(tile.x,tile.y - 1).fg == itmSeed do
                        punch(0,0)
                        sleep(delayHarvest)
                        reconnect(world,doorFarm,tile.x,tile.y - 1)
                    end
                    if root then
                        while getTile(tile.x, tile.y).fg == (itmId + 4) and getTile(tile.x, tile.y).flags ~= 0 do
                            punch(0, 1)
                            sleep(delayHarvest)
                            reconnect(world,doorFarm,tile.x,tile.y - 1)
                        end
                        clear()
                        sleep(100)
                    end
                end
            end
            if findItem(itmId) >= 190 then
                pnb(world)
                sleep(100)
                plant(world)
                sleep(100)
            end
        end
    end
    pnb(world)
    sleep(100)
    if separatePlant then
        plant(world)
        sleep(100)
    end
    if findItem(112) >= minimumGem then
        buy()
        sleep(100)
    end
end

setBool("Auto Reconnect", false)

if findItem(98) == 0 then
    warp(storagePack,doorPack)
    sleep(100)
    collectSet(false,3)
    sleep(100)
    for _,obj in pairs(getObjects()) do
        if obj.id == 98 then
            findPath(round(obj.x / 32),math.floor(obj.y / 32))
            sleep(1000)
            collect(2)
            sleep(1000)
        end
        if findItem(98) > 0 then
            break
        end
    end
    move(-1,0)
    sleep(100)
    sendPacket(2,"action|drop\n|itemID|98")
    sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|98|\ncount|"..(findItem(98) - 1))
    sleep(500)
    wear(98)
    sleep(500)
end

for i = 1,upgradeBackpack do
    sendPacket(2,"action|buy\nitem|upgrade_backpack")
    sleep(500)
end

while true do
    for index,world in pairs(worlds) do
        waktuWorld()
        sleep(100)
        warp(world,doorFarm)
        sleep(100)
        if not nuked then
            if findItem(itmSeed) == 0 and not dontPlant then
                take(world)
                sleep(100)
            end
            collectSet(true,3)
            sleep(100)
            bl(world)
            sleep(100)
            botInfo("Starting "..world)
            sleep(100)
            tt = os.time()
            harvest(world)
            sleep(100)
            tt = os.time() - tt
            botInfo("Finished "..world)
            sleep(100)
            waktu[world] = math.floor(tt/3600).." Hours "..math.floor(tt%3600/60).." Minutes"
            sleep(100)
            if joinWorldAfterStore then
                join()
                sleep(100)
            end
        else
            waktu[world] = "NUKED"
            tree[world] = "NUKED"
            nuked = false
            sleep(5000)
        end
        if start < stop then
            start = start + 1
        else
            if restartTimer then
                waktu = {}
                tree = {}
            end
            start = 1
            loop = loop + 1
        end
    end
    if not looping then
        waktuWorld()
        sleep(100)
        botInfo("Finished All World, Removing Bot!")
        sleep(100)
        removeBot(getBot().name)
        break
    end
end
