local job         = nil
local _firstname  = "Null"
local _lastname   = "Null"
local counting    = false
local time        = 0
local lastcount   = 0

AddEventHandler('playerSpawned', function(spawn)
	TriggerServerEvent('csg_dutytimer:getJob')
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  	TriggerServerEvent('csg_dutytimer:getJob')
end)


ESX = nil


RegisterNetEvent("GetPlayerData")
AddEventHandler("GetPlayerData", function(data)
    if data == nil then
        return
    end
    _lastname      = data[1].lastname
    _firstname     = data[1].firstname
end)

RegisterNetEvent("SetCount")
AddEventHandler("SetCount", function(state)
    if state then
        counting = true
        print(state)
    elseif state == false then
        counting = false
        print(state)
    end
end)

Citizen.CreateThread(function()
    while true do
        _sleep = 60000
        TriggerServerEvent('GetPlayerData')
        if _lastname == "Null" or _name == "Null" then
            _sleep = 0
            TriggerServerEvent('GetPlayerData')
        end
        Citizen.Wait(_sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        if counting then
            _sleep = 60000
            Citizen.Wait(_sleep)
            time = time + 1
            print(time)
            lastcount = time
        else
            if time ~= -1 then
                time = -1
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        local _sleep = 1000
        local _char = PlayerPedId()
        local _charPos = GetEntityCoords(_char)
        local _name = GetPlayerName(PlayerId())
        if #(_charPos - Config.policePos ) < 2 then
            _sleep = 0    
            JobBuilder(_char, _charPos, _firstname.. _lastname, "police", Config.policePos, "L.S.P.D", _firstname, _lastname, lastcount)
        elseif #(_charPos - Config.ambulancePos ) < 2 then
            _sleep = 0    
            JobBuilder(_char, _charPos, _firstname.. _lastname, "ambulance", Config.ambulancePos, "E.M.S", _firstname, _lastname, lastcount)
        elseif #(_charPos - Config.taxiPos ) < 2 then
            _sleep = 0    
            JobBuilder(_char, _charPos, _firstname.. " ".. _lastname, "taxi", Config.taxiPos, "Taxi", _firstname, _lastname, lastcount)
        end
        Citizen.Wait(_sleep)
    end
end)

function JobBuilder(_char, _charPos, _name, jobName, jobPos, jobLabel, name, lastname, time)     
    local x, y, z = table.unpack(jobPos)
    local secondPos = vector3(x,y,z+0.3)
     if job == nil then
         TriggerServerEvent('csg_dutytimer:getJob')
     end
    if job == "off".. jobName then
        Create3D(secondPos, _U('greet_job').. " ".. name.. " ".. lastname)
        Create3D(jobPos, _U('enter_job'))
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent('csg_dutytimer:changejob', jobName, true)
            TriggerServerEvent('csg_dutytimer:send', _name, true, jobLabel, time)
        end
    elseif job == jobName then
         Create3D(secondPos, _U('greet_job').. " ".. name.. " ".. lastname)
         Create3D(jobPos, _U('exit_job')) 
         if IsControlJustPressed(0, 38) then
             TriggerServerEvent('csg_dutytimer:changejob', jobName, false, jobName)
             TriggerServerEvent('csg_dutytimer:send', _name, false, jobLabel, time)
         end
     else
         Create3D(jobPos, _U('not_job').. " ".. jobLabel)
     end
end

Create3D = function(coords, texto)
    local x, y, z = table.unpack(coords)
    z = z+1
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(5)
        AddTextComponentString(texto)
        DrawText(_x,_y)
    end
end

RegisterNetEvent('csg_dutytimer:setJob')
AddEventHandler('csg_dutytimer:setJob', function(jobcsg)
  	job = jobcsg
end)