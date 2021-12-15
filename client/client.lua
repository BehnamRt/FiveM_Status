BR = nil
local AllWeapons = json.decode('{"melee":{"dagger":"0x92A27487","bat":"0x958A4A8F","bottle":"0xF9E6AA4B","crowbar":"0x84BD7BFD","unarmed":"0xA2719263","flashlight":"0x8BB05FD7","golfclub":"0x440E4788","hammer":"0x4E875F73","hatchet":"0xF9DCBF2D","knuckle":"0xD8DF3C3C","knife":"0x99B507EA","machete":"0xDD5DF8D9","switchblade":"0xDFE37640","nightstick":"0x678B81B1","wrench":"0x19044EE0","battleaxe":"0xCD274149","poolcue":"0x94117305","stone_hatchet":"0x3813FC08"},"handguns":{"pistol":"0x1B06D571","pistol_mk2":"0xBFE256D4","combatpistol":"0x5EF9FEC4","appistol":"0x22D8FE39","stungun":"0x3656C8C1","pistol50":"0x99AEEB3B","snspistol":"0xBFD21232","snspistol_mk2":"0x88374054","heavypistol":"0xD205520E","vintagepistol":"0x83839C4","flaregun":"0x47757124","marksmanpistol":"0xDC4DB296","revolver":"0xC1B3C3D1","revolver_mk2":"0xCB96392F","doubleaction":"0x97EA20B8","raypistol":"0xAF3696A1"},"smg":{"microsmg":"0x13532244","smg":"0x2BE6766B","smg_mk2":"0x78A97CD0","assaultsmg":"0xEFE7E2DF","combatpdw":"0xA3D4D34","machinepistol":"0xDB1AA450","minismg":"0xBD248B55","raycarbine":"0x476BF155"},"shotguns":{"pumpshotgun":"0x1D073A89","pumpshotgun_mk2":"0x555AF99A","sawnoffshotgun":"0x7846A318","assaultshotgun":"0xE284C527","bullpupshotgun":"0x9D61E50F","musket":"0xA89CB99E","heavyshotgun":"0x3AABBBAA","dbshotgun":"0xEF951FBB","autoshotgun":"0x12E82D3D"},"assault_rifles":{"assaultrifle":"0xBFEFFF6D","assaultrifle_mk2":"0x394F415C","carbinerifle":"0x83BF0278","carbinerifle_mk2":"0xFAD1F1C9","advancedrifle":"0xAF113F99","specialcarbine":"0xC0A3098D","specialcarbine_mk2":"0x969C3D67","bullpuprifle":"0x7F229F94","bullpuprifle_mk2":"0x84D6FAFD","compactrifle":"0x624FE830"},"machine_guns":{"mg":"0x9D07F764","combatmg":"0x7FD62962","combatmg_mk2":"0xDBBD7280","gusenberg":"0x61012683"},"sniper_rifles":{"sniperrifle":"0x5FC3C11","heavysniper":"0xC472FE2","heavysniper_mk2":"0xA914799","marksmanrifle":"0xC734385A","marksmanrifle_mk2":"0x6A6C02E0"},"heavy_weapons":{"rpg":"0xB1CA77B1","grenadelauncher":"0xA284510B","grenadelauncher_smoke":"0x4DD2DC56","minigun":"0x42BF8A85","firework":"0x7F7497E5","railgun":"0x6D544C99","hominglauncher":"0x63AB0442","compactlauncher":"0x781FE4A","rayminigun":"0xB62D1F67"},"throwables":{"grenade":"0x93E220BD","bzgas":"0xA0973D5E","smokegrenade":"0xFDBC8A50","flare":"0x497FACC3","molotov":"0x24B17070","stickybomb":"0x2C3731D9","proxmine":"0xAB564B93","snowball":"0x787F0BB","pipebomb":"0xBA45E8B8","ball":"0x23C9F95C"},"misc":{"petrolcan":"0x34A67B97","fireextinguisher":"0x60EC506","parachute":"0xFBAB5776"}}')
local vehiclesCars = {0,1,2,3,4,5,6,7,8,9,10,11,12,17,18,19,20};

Citzen.CreateThread(function()
	while BR == nil do
		TriggerEvent('brt:getSharedObject', function(obj) BR = obj end)
		Citzen.Wait(0)
	end
	TriggerEvent('es:setMoneyDisplay', 0.0)
	BR.UI.HUD.SetDisplay(0.0)
end)


Citzen.CreateThread(function()
    local isPauseMenu = false
	while true do
		Citzen.Wait(1000)
		if IsPauseMenuActive() then -- ESC Key
			if not isPauseMenu then
				isPauseMenu = not isPauseMenu
				SendNUIMessage({ action = 'toggleUi', value = false })
			end
		else
			if isPauseMenu then
				isPauseMenu = not isPauseMenu
				SendNUIMessage({ action = 'toggleUi', value = true })
			end
		end
	end
end)

RegisterNetEvent('brt_hud:toggle')
AddEventHandler('brt_hud:toggle', function(show)
	SendNUIMessage({ action = 'toggleUi', value = show })
end)

local vehicleCruiser
local vehicleSignalIndicator = 'off'
local currSpeed = 0.0
local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
Citzen.CreateThread(function()
	while true do
		Citzen.Wait(100)
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player, false)
		local position = GetEntityCoords(player)
		local vehicleIsOn = GetIsVehicleEngineRunning(vehicle)
		local vehicleInfo
		local canSleep = true
		if IsPedInAnyVehicle(player, false) and vehicleIsOn then
			local vehicleClass = GetVehicleClass(vehicle)
			canSleep = false

			-- Vehicle Speed
			local vehicleSpeedSource = GetEntitySpeed(vehicle)
			local vehicleSpeed = math.ceil(vehicleSpeedSource * 3.6)

			-- Vehicle Gradient Speed
			local vehicleNailSpeed

			if vehicleSpeed > 350 then
				vehicleNailSpeed = math.ceil(  280 - math.ceil( math.ceil(350 * 205) / 350) )
			else
				vehicleNailSpeed = math.ceil(  280 - math.ceil( math.ceil(vehicleSpeed * 205) / 350) )
			end

			-- Vehicle Fuel and Gear
			local vehicleFuel
			vehicleFuel = GetVehicleFuelLevel(vehicle)

			local vehicleGear = GetVehicleCurrentGear(vehicle)

			if (vehicleSpeed == 0 and vehicleGear == 0) or (vehicleSpeed == 0 and vehicleGear == 1) then
				vehicleGear = 'N'
			elseif vehicleSpeed > 0 and vehicleGear == 0 then
				vehicleGear = 'R'
			end

			-- Vehicle Lights
			local vehicleVal,vehicleLights,vehicleHighlights  = GetVehicleLightsState(vehicle)
			local vehicleIsLightsOn
			if vehicleLights == 1 and vehicleHighlights == 0 then
				vehicleIsLightsOn = 'normal'
			elseif (vehicleLights == 1 and vehicleHighlights == 1) or (vehicleLights == 0 and vehicleHighlights == 1) then
				vehicleIsLightsOn = 'high'
			else
				vehicleIsLightsOn = 'off'
			end

			-- Vehicle Siren
			local vehicleSiren

			if IsVehicleSirenOn(vehicle) then
				vehicleSiren = true
			else
				vehicleSiren = false
			end


			vehicleInfo = {
				action = 'updateVehicle',

				status = true,
				speed = vehicleSpeed,
				nail = vehicleNailSpeed,
				gear = vehicleGear,
				fuel = vehicleFuel,
				lights = vehicleIsLightsOn,
				signals = vehicleSignalIndicator,
				cruiser = vehicleCruiser,
				type = vehicleClass,
				siren = vehicleSiren,

				config = {
					speedUnit = 'KMH',
					maxSpeed = 350
				}
			}

		else

			
			vehicleCruiser = false
			vehicleNailSpeed = 0
			vehicleSignalIndicator = 'off'


			vehicleInfo = {
				action = 'updateVehicle',

				status = false,
				nail = vehicleNailSpeed,
				cruiser = vehicleCruiser,
				signals = vehicleSignalIndicator,
				type = 0,
			}

		end

		SendNUIMessage(vehicleInfo)
		if canSleep then
			Citzen.Wait(1500)
		end
	end
end)


-- Player status
Citzen.CreateThread(function()
	while true do
		Citzen.Wait(1500)

		local playerStatus 
		local showPlayerStatus = 0
		playerStatus = { action = 'setStatus', status = {} }

		showPlayerStatus = (showPlayerStatus+1)
		playerStatus['isdead'] = false
		playerStatus['status'][showPlayerStatus] = {
			name = 'health',
			value = GetEntityHealth(PlayerPedId()) - 100
		}

		if IsEntityDead(PlayerPedId()) then
			playerStatus.isdead = true
		end

		showPlayerStatus = (showPlayerStatus+1)
		playerStatus['status'][showPlayerStatus] = {
			name = 'armor',
			value = GetPedArmour(PlayerPedId()),
		}

		showPlayerStatus = (showPlayerStatus+1)
		playerStatus['status'][showPlayerStatus] = {
			name = 'stamina',
			value = 100 - GetPlayerSprintStaminaRemaining(PlayerId()),
		}

		if showPlayerStatus > 0 then
			SendNUIMessage(playerStatus)
		end

		local playerStatus 
		local showPlayerStatus = 0
		playerStatus = { action = 'setStatus', status = {} }

		showPlayerStatus = (showPlayerStatus+1)
		TriggerEvent('brt_status:getStatus', 'hunger', function(status)
			playerStatus['status'][showPlayerStatus] = {
				name = 'hunger',
				value = math.floor(100-status.getPercent())
			}
		end)

		showPlayerStatus = (showPlayerStatus+1)
		TriggerEvent('brt_status:getStatus', 'thirst', function(status)
			playerStatus['status'][showPlayerStatus] = {
				name = 'thirst',
				value = math.floor(100-status.getPercent())
			}
		end)

		showPlayerStatus = (showPlayerStatus+1)
		TriggerEvent('brt_status:getStatus', 'drunk', function(status)
			playerStatus['status'][showPlayerStatus] = {
				name = 'drunk',
				value = math.floor(100-status.getPercent())
			}
		end)

		if showPlayerStatus > 0 then
			SendNUIMessage(playerStatus)
		end
	end
end)

-- Weapons
Citzen.CreateThread(function()
	while true do
		Citzen.Wait(100)

		local player = PlayerPedId()
		local status = {}
		local canSleep = true
		if IsPedArmed(player, 7) then
			canSleep = false
			local weapon = GetSelectedPedWeapon(player)
			local ammoTotal = GetAmmoInPedWeapon(player,weapon)
			local bool,ammoClip = GetAmmoInClip(player,weapon)
			local ammoRemaining = math.floor(ammoTotal - ammoClip)
			
			status['armed'] = true

			for key,value in pairs(AllWeapons) do

				for keyTwo,valueTwo in pairs(AllWeapons[key]) do
					if weapon == GetHashKey('weapon_'..keyTwo) then
						status['weapon'] = keyTwo


						if key == 'melee' then
							SendNUIMessage({ action = 'element', task = 'disable', value = 'weapon_bullets' })
							SendNUIMessage({ action = 'element', task = 'disable', value = 'bullets' })
						else
							if keyTwo == 'stungun' then
								SendNUIMessage({ action = 'element', task = 'disable', value = 'weapon_bullets' })
								SendNUIMessage({ action = 'element', task = 'disable', value = 'bullets' })
							else
								SendNUIMessage({ action = 'element', task = 'enable', value = 'weapon_bullets' })
								SendNUIMessage({ action = 'element', task = 'enable', value = 'bullets' })
							end
						end

					end
				end

			end

			SendNUIMessage({ action = 'setText', id = 'weapon_clip', value = ammoClip })
			SendNUIMessage({ action = 'setText', id = 'weapon_ammo', value = ammoRemaining })

		else
			status['armed'] = false	
		end

		SendNUIMessage({ action = 'updateWeapon', status = status })
		if canSleep then
			Citzen.Wait(1500)
		end
	end
end)

AddEventHandler("onKeyDown", function(key)
	if key == "b" then
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player, false)
		local vehicleClass = GetVehicleClass(vehicle)
		if GetPedInVehicleSeat(vehicle, -1) == player and (has_value(vehiclesCars, vehicleClass) == true) then
			local vehicleSpeedSource = GetEntitySpeed(vehicle)

			if vehicleCruiser == 'on' then
				vehicleCruiser = 'off'
				SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
				
			else
				vehicleCruiser = 'on'
				SetEntityMaxSpeed(vehicle, vehicleSpeedSource)
			end
		end
	end
end)

RegisterNetEvent('brt:playerLoaded')
AddEventHandler('brt:playerLoaded', function(xPlayer) 
	--Citzen.Wait(15000)
	SendNUIMessage({action = "setValue", key = "id", value = "ID: " .. GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())) .. " | " .. string.gsub(xPlayer.name, "_", " ")})
	SendNUIMessage({action = "setValue", key = "money", value = "Naghd: $"..xPlayer.money})
	SendNUIMessage({action = "setValue", key = "dirty_money", value = "PoolKasif: $"..xPlayer.dirty_money})
	SendNUIMessage({action = "setValue", key = "credit", value = "Credit: "..xPlayer.credit})
	if xPlayer.job.name ~= 'nojob' then
		SendNUIMessage({action = "setValue", key = "job", value = xPlayer.job.label.." | "..xPlayer.job.grade_label, icon = xPlayer.job.name})
	else
		SendNUIMessage({action = "setValue", key = "job", value = 'Bedone Shoghl', icon = xPlayer.job.name})
	end
	if xPlayer.gang.name ~= 'nogang' then
		local icon
		BR.TriggerServerCallback('gangs:getGangData', function(data)
			if data ~= nil then
				logo  = data.logo
				SendNUIMessage({action = "setValue", key = "gang", value = xPlayer.gang.name.." | "..xPlayer.gang.grade_label, icon2 = data.logo})
			else
				SendNUIMessage({action = "setValue", key = "gang", value = 'In Gang Disable Shode', icon2 = "https://uupload.ir/files/3zmq_default.png"})
			end
		end, xPlayer.gang.name)
	else
		SendNUIMessage({action = "setValue", key = "gang", value = 'Bedone Gang', icon2 = "https://uupload.ir/files/3zmq_default.png"})
	end
end)

RegisterCommand('reloadhud', function() 
	if BR == nil then return end
	local PlayerData = BR.GetPlayerData()
	SendNUIMessage({action = "setValue", key = "id", value = "ID: " .. GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())) .. " | " .. string.gsub(PlayerData.name, "_", " ")})
	SendNUIMessage({action = "setValue", key = "money", value = "Naghd: $"..PlayerData.money})
	SendNUIMessage({action = "setValue", key = "dirty_money", value = "PoolKasif: $"..PlayerData.dirty_money})
	SendNUIMessage({action = "setValue", key = "credit", value = "Credit: "..PlayerData.credit})
	if PlayerData.job.name ~= 'nojob' then
		SendNUIMessage({action = "setValue", key = "job", value = PlayerData.job.label.." | ".. PlayerData.job.grade_label, icon = PlayerData.job.name})
	else
		SendNUIMessage({action = "setValue", key = "job", value = 'Bedone Shoghl', icon = PlayerData.job.name})
	end
	if PlayerData.gang.name ~= 'nogang' then
		local icon
		BR.TriggerServerCallback('gangs:getGangData', function(data)
			if data ~= nil then
				logo  = data.logo
				SendNUIMessage({action = "setValue", key = "gang", value = PlayerData.gang.name.." | ".. PlayerData.gang.grade_label, icon2 = data.logo})
			else
				SendNUIMessage({action = "setValue", key = "gang", value = 'In Gang Disable Shode', icon2 = "https://uupload.ir/files/3zmq_default.png"})
			end
		end, PlayerData.gang.name)
	else
		SendNUIMessage({action = "setValue", key = "gang", value = 'Bedone Gang', icon2 = "https://uupload.ir/files/3zmq_default.png"})
	end
end, false)

RegisterNetEvent('nameUpdate')
AddEventHandler('nameUpdate', function(name)
	SendNUIMessage({action = "setValue", key = "id", value = "ID: " .. GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())) .. " | " .. string.gsub(name, "_", " ")})
end)

RegisterNetEvent('moneyUpdate')
AddEventHandler('moneyUpdate', function(money)
  	SendNUIMessage({action = "setValue", key = "money", value = "Naghd: $"..money})
end)

RegisterNetEvent('dirty_moneyUpdate')
AddEventHandler('dirty_moneyUpdate', function(money)
  	SendNUIMessage({action = "setValue", key = "dirty_money", value = "PoolKasif: $"..money})
end)

RegisterNetEvent('creditUpdate')
AddEventHandler('creditUpdate', function(credit)
  	SendNUIMessage({action = "setValue", key = "credit", value = "Credit: "..credit})
end)

RegisterNetEvent('brt:setJob')
AddEventHandler('brt:setJob', function(job)
	if job.name ~= 'nojob' then
		SendNUIMessage({action = "setValue", key = "job", value = job.label.." | "..job.grade_label, icon = job.name})
	else
		SendNUIMessage({action = "setValue", key = "job", value = 'Bedone Shoghl', icon = job.name})
	end
end)

RegisterNetEvent('brt:setGang')
AddEventHandler('brt:setGang', function(gang)
	if gang.name ~= 'nogang' then
		local icon
		BR.TriggerServerCallback('gangs:getGangData', function(data)
			if data ~= nil then
				logo  = data.logo
				SendNUIMessage({action = "setValue", key = "gang", value = gang.name.." | "..gang.grade_label, icon2 = data.logo})
			else
				SendNUIMessage({action = "setValue", key = "gang", value = 'In Gang Disable Shode', icon2 = "https://uupload.ir/files/3zmq_default.png"})
			end
		end, gang.name)
	else
		SendNUIMessage({action = "setValue", key = "gang", value = 'Bedone Gang', icon2 = "https://uupload.ir/files/3zmq_default.png"})
	end
end)

AddEventHandler('PlayerLoadedToGround', function()
	ExecuteCommand('reloadhud')
end)

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end