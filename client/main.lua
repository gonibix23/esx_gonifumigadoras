ESX = nil
local PlayerData = {}
local work = false
local aircraftSpawned = false
local aircraft = nil
local waypoint = true
local waypointPosition = {x = nil, y = nil, z = nil}
local headingArrow = 0
local farmedZone = 0
local smoking = false
local times = 0
local fumigatorJob = nil

local aircraftBlip = AddBlipForCoord(Config.Zones.takeAircraft.x, Config.Zones.takeAircraft.y)
SetBlipSprite(aircraftBlip, 582)
SetBlipDisplay(aircraftBlip, 6)
SetBlipScale(aircraftBlip, 1.0)
SetBlipColour(aircraftBlip, 57)
SetBlipAsShortRange(aircraftBlip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Trabajo de fumigador")
EndTextCommandSetBlipName(aircraftBlip)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

CreateThread(function()
	while true do
		Citizen.Wait(1000)
		ESX.TriggerServerCallback('esx_gonifumigadoras:receiveJob', function(xJob)
			fumigatorJob = xJob
		end)
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(0)
		if fumigatorJob == "fumigador" then
			DrawMarker(33, Config.Zones.takeAircraft.x, Config.Zones.takeAircraft.y, Config.Zones.takeAircraft.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 255, 0, 80, false, true, 2, nil, nil, false)
			DrawMarker(23, Config.Zones.takeAircraft.x, Config.Zones.takeAircraft.y, Config.Zones.takeAircraft.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 2.0, 0, 255, 0, 80, false, true, 2, nil, nil, false)
			DrawMarker(33, Config.Zones.leaveAircraft.x, Config.Zones.leaveAircraft.y, Config.Zones.leaveAircraft.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 0, 0, 80, false, true, 2, nil, nil, false)
			DrawMarker(23, Config.Zones.leaveAircraft.x, Config.Zones.leaveAircraft.y, Config.Zones.leaveAircraft.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 2.0, 255, 0, 0, 80, false, true, 2, nil, nil, false)
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(50)
		if smoking == true and times < 200 then
			local dict = "core"
			local particleName = "veh_respray_smoke"
			RequestNamedPtfxAsset(dict)
			UseParticleFxAssetNextCall(dict)
			StartParticleFxNonLoopedAtCoord(particleName, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z-1, 0.0, 0.0, 0.0, 5.0, false, false, false)
			StartParticleFxNonLoopedAtCoord(particleName, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z-1, 0.0, 0.0, 0.0, 5.0, false, false, false)
			StartParticleFxNonLoopedAtCoord(particleName, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z-1, 0.0, 0.0, 0.0, 5.0, false, false, false)
			times = times + 1
		end
		if times == 200 then
			RemoveParticleFxInRange(GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, 10000)
			smoking = false
			times = 0
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(0)
		if fumigatorJob == "fumigador" then
			generateWaypoint()
			playerTakingJob()
			startingJob()
			arrivedJobPoint()
			leavingJob()
			getPayed()
			makeArrowHeadPoint()
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(0)
		destroyPlane()
	end
end)

function generateWaypoint()
	if waypoint == true then
		local randomZone = math.random(1, 6)
		if lastNum ~= randomZone then
			if randomZone == 1 then
				waypointPosition.x = Config.FarmZones.a.x
				waypointPosition.y = Config.FarmZones.a.y
				waypointPosition.z = Config.FarmZones.a.z
			end
			if randomZone == 2 then
				waypointPosition.x = Config.FarmZones.b.x
				waypointPosition.y = Config.FarmZones.b.y
				waypointPosition.z = Config.FarmZones.b.z
			end
			if randomZone == 3 then
				waypointPosition.x = Config.FarmZones.c.x
				waypointPosition.y = Config.FarmZones.c.y
				waypointPosition.z = Config.FarmZones.c.z
			end
			if randomZone == 4 then
				waypointPosition.x = Config.FarmZones.d.x
				waypointPosition.y = Config.FarmZones.d.y
				waypointPosition.z = Config.FarmZones.d.z
			end
			if randomZone == 5 then
				waypointPosition.x = Config.FarmZones.e.x
				waypointPosition.y = Config.FarmZones.e.y
				waypointPosition.z = Config.FarmZones.e.z
			end
			if randomZone == 6 then
				waypointPosition.x = Config.FarmZones.f.x
				waypointPosition.y = Config.FarmZones.f.y
				waypointPosition.z = Config.FarmZones.f.z
			end
			lastNum = randomZone
			waypoint = false
		end
	end
end

function playerTakingJob()
	if aircraftSpawned == false then
		if IsPedInAnyVehicle(PlayerPedId(-1), true) == false then
			if GetDistanceBetweenCoords(Config.Zones.takeAircraft.x, Config.Zones.takeAircraft.y, Config.Zones.takeAircraft.z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, true) < 2 then
				ESX.ShowHelpNotification('~b~Presiona ~INPUT_CONTEXT~ para empezar a trabajar de~b~ ~w~Fumigador~w~')
				if IsControlJustPressed(0, 54) then
					local aircraftHash = GetHashKey('Cuban800')
					RequestModel(aircraftHash)
					while not HasModelLoaded(aircraftHash) do
						RequestModel(aircraftHash)
						Citizen.Wait(0)
					end
					aircraft = CreateVehicle(aircraftHash, Config.Zones.aircraftSpawn.x, Config.Zones.aircraftSpawn.y, Config.Zones.aircraftSpawn.z, 100.0, true, false)
					TaskWarpPedIntoVehicle(PlayerPedId(-1), aircraft, -1)
					SetEntityAsMissionEntity(aircraft, true, true)
					aircraftSpawned = true
					ESX.ShowHelpNotification('~b~Se te han cobrado~b~ ~r~5000$~r~ ~b~de fianza~b~')
					ESX.ShowNotification('~b~No te bajes del vehiculo si no quieres perder el trabajo~b~')
					ESX.ShowNotification('~b~Vete a la posición marcada para fumigar~b~')
					TriggerServerEvent('esx_gonifumigadoras:planeCost')
					farmedZone = 0
				end
			end
		end
	end
end

function startingJob()
	if aircraftSpawned == true then
		DrawMarker(2, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z+1, 0.0, 0.0, 0.0, headingArrow-90, -90.0, 90.0, 1.0, 2.0, 2.0, 255, 0, 0, 80, false, false, 2, false, nil, false)
		if farmedZone < 5 then
			DrawMarker(6, waypointPosition.x+0.1, waypointPosition.y+0.1, waypointPosition.z+0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0, 1.0, 50.0, 255, 255, 0, 80, false, true, 2, nil, nil, false)
		end
	end
end

function leavingJob()
	if aircraftSpawned == true then
			if GetDistanceBetweenCoords(Config.Zones.leaveAircraft.x, Config.Zones.leaveAircraft.y, Config.Zones.leaveAircraft.z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, true) < 4 then
				ESX.ShowHelpNotification('~b~Presiona ~INPUT_CONTEXT~ para dejar de trabajar de~b~ ~w~Fumigador~w~')
				if IsControlJustPressed(0, 54) then
					DeleteVehicle(aircraft)
					aircraftSpawned = false
					ESX.ShowNotification('~b~Has dejado de trabajar de ~w~Fumigador~w~')
					ESX.ShowHelpNotification('~b~Has cobrado~b~ ~g~5000$~g~ ~b~de la fianza~b~')
					TriggerServerEvent('esx_gonifumigadoras:receivePlaneCost')
					waypoint = true
				end
			end
	end
end

function destroyPlane()
	if aircraftSpawned == true then
		if IsPedInVehicle(PlayerPedId(-1), aircraft, true) == false then
			Citizen.Wait(10000)
			if IsPedInVehicle(PlayerPedId(-1), aircraft, true) == false and aircraftSpawned == true then
				Citizen.Wait(10000)
				DeleteVehicle(aircraft)
				if aircraftSpawned == true then
				ESX.ShowHelpNotification('~r~Has fallado en tu trabajo vuelve a intentarlo~r~')
				end
				aircraftSpawned = false
				farmedZone = 0
				waypoint = true
			end
		end
	end
end

function arrivedJobPoint()
	if aircraftSpawned == true then
		if GetDistanceBetweenCoords(waypointPosition.x+0.1, waypointPosition.y+0.1, waypointPosition.z+0.1, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, true) < 30 and farmedZone < 5 then
			farmedZone = farmedZone + 1
			ESX.ShowHelpNotification('~g~Has fumigado una zona, ¡Bien hecho! ~g~'..farmedZone..'~g~/5~g~' )
			smoking = true
			if farmedZone < 5 then
				waypoint = true
			end
			Citizen.Wait(1000)
		end
	end
end

function getPayed()
	if farmedZone == 5 then
		ESX.ShowNotification('~g~Has fumigado 5 zonas, ¡Bien hecho! Vuelve al hangar para cobrar~g~')
		waypointPosition.x = Config.Zones.getPayedZone.x
		waypointPosition.y = Config.Zones.getPayedZone.y
		DrawMarker(33, Config.Zones.getPayedZone.x, Config.Zones.getPayedZone.y, Config.Zones.getPayedZone.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 0, 255, 80, false, true, 2, nil, nil, false)
		DrawMarker(23, Config.Zones.getPayedZone.x, Config.Zones.getPayedZone.y, Config.Zones.getPayedZone.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 2.0, 0, 0, 255, 80, false, true, 2, nil, nil, false)
		if GetDistanceBetweenCoords(Config.Zones.getPayedZone.x, Config.Zones.getPayedZone.y, Config.Zones.getPayedZone.z, GetEntityCoords(PlayerPedId(-1)).x, GetEntityCoords(PlayerPedId(-1)).y, GetEntityCoords(PlayerPedId(-1)).z, true) < 4 then
			ESX.ShowHelpNotification('~b~Presiona ~INPUT_CONTEXT~ para cobrar~b~')
			if IsControlJustPressed(0, 54) then
				farmedZone = 0
				waypoint = true
				TriggerServerEvent('esx_gonifumigadoras:getPayedForWork')
				ESX.ShowHelpNotification('~b~Has cobrado~b~ ~g~2000$~g~ ~b~por trabajar~b~')
			end
		end
	end
end

function makeArrowHeadPoint()
	local p1 = GetEntityCoords(PlayerPedId(-1), true)
    local dx = waypointPosition.x - p1.x
    local dy = waypointPosition.y - p1.y
    headingArrow = GetHeadingFromVector_2d(dx, dy)
end