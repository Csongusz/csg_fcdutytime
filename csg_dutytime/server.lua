local data
local webhook = "https://discord.com/api/webhooks/877114152605335593/vbcgKRtYBbg3ZiFVrN2zBGlCVZl_bm-KjFhuHg5VSOBZkIcIbjMWU648HvZpbkSPKyRL" 
local image   = "https://prod.cloud.rockstargames.com/crews/sc/0291/19566919/publish/emblem/emblem_512.png"

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local discord_webhook = {
    url = webhook,
    image = image
}

function ExtractIdentifiers()
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

RegisterServerEvent('GetPlayerData')
AddEventHandler('GetPlayerData', function()
  local identifier = ExtractIdentifiers()
  MySQL.ready(function ()
  MySQL.Async.fetchAll(
    'SELECT * FROM users WHERE identifier = @identifier',{['@identifier'] = identifier.steam},
    function(result)
    	data = result
    end)
  end)
  TriggerClientEvent("GetPlayerData", source, data)
end)

RegisterNetEvent("csg_dutytime:getName")
AddEventHandler("csg_dutytime:getName", function()
    local csgIdentifier = ExtractIdentifiers()
    local resultcsg = "Null"
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @id",{['@id'] = csgIdentifier.steam}, 
        function(result)
				resultcsg = result[1].lastname
				return(resultcsg)
		end) 
end)

RegisterNetEvent('csg_dutytime:getNamef')
AddEventHandler('csg_dutytime:getNamef', function(source)
	local identifiers = ExtractIdentifiers()
	local steam = identifiers.steam
	MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `identifier` = @id",
	{["@id"] = steam},
	function(result)
		return result[1].lastname
	end)
end)

RegisterServerEvent('csg_dutytime:getJob')
AddEventHandler('csg_dutytime:getJob',function()
	local source = source 
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayers[i] == source then
			TriggerClientEvent('csg_dutytime:setJob',xPlayers[i],xPlayer.job.name)
		end
	end
end)

RegisterServerEvent('csg_dutytime:changejob')
AddEventHandler('csg_dutytime:changejob', function(_job, _state)
	local user = ESX.GetPlayerFromId(source)				   
    if _state then
        TriggerClientEvent("SetCount", source, true)
        user.setJob(_job, user.getJob().grade)      
    else
        TriggerClientEvent("SetCount", source, false)
        user.setJob("off".. _job, user.getJob().grade)
	end
end)

RegisterServerEvent('csg_dutytime:send')
AddEventHandler('csg_dutytime:send',function(author, state, _job, time)
	if state then
		PerformHttpRequest(discord_webhook.url, 
    	function(err, text, header) end, 
    	'POST',
		json.encode({username = "L.S.P.D - Recepció・🪐", content = author.. _U('enter_job_dc')..' | '.. _job , avatar_url=discord_webhook.image }), {['Content-Type'] = 'application/json'}) 
	else
		PerformHttpRequest(discord_webhook.url, 
		function(err, text, header) end, 
		'POST',
		json.encode({username = "L.S.P.D - Recepció・🪐", content = author.. _U('exit_job_dc')..' | '.. _job.. ' | '.. _U('inservicetime').. time.. ' '.. _U('time') , avatar_url=discord_webhook.image }), {['Content-Type'] = 'application/json'}) 
	end
end)