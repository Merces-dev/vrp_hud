-----------------------------------------------------------------------------------------------------------------------------------------
-- Este arquivo foi disponibilizado pelo KSRP/KS Network.
-- Discord: https://discord.gg/DpaX3B
-- Sinta-se livre pra fazer as alteraçoes necessárias pro seu servidor.
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_hud",cRP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local hour = 0
local voice = "Normal"
local minute = 0
local month = ""
local hunger = 100
local thirst = 100
local dayMonth = 0
local varDay = ""
local showHud = true
local showMovie = false
local sBuffer = {}
local vBuffer = {}
local seatbelt = false
local ExNoCarro = false
local timedown = 0
local celular = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALCULATETIMEDISPLAY
-----------------------------------------------------------------------------------------------------------------------------------------
function calculateTimeDisplay()
	hour = GetClockHours()
	month = GetClockMonth()
	minute = GetClockMinutes()
	dayMonth = GetClockDayOfMonth()

	if hour <= 9 then
		hour = "0"..hour
	end

	if minute <= 9 then
		minute = "0"..minute
	end

	if month == 0 then
		month = "Janeiro"
	elseif month == 1 then
		month = "Fevereiro"
	elseif month == 2 then
		month = "Março"
	elseif month == 3 then
		month = "Abril"
	elseif month == 4 then
		month = "Maio"
	elseif month == 5 then
		month = "Junho"
	elseif month == 6 then
		month = "Julho"
	elseif month == 7 then
		month = "Agosto"
	elseif month == 8 then
		month = "Setembro"
	elseif month == 9 then
		month = "Outubro"
	elseif month == 10 then
		month = "Novembro"
	elseif month == 11 then
		month = "Dezembro"
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CELULAR
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("status:celular",function(status)
	celular = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOKOVOIP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip",function(status)
	voice = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADHUD
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if showHud then
			if IsPauseMenuActive() or IsScreenFadedOut() then
				SendNUIMessage({ active = false, movie = false })
			else
				timeDistance = 200
				local ped = PlayerPedId()
				local health = GetEntityHealth(ped)-100
				local armour = GetPedArmour(ped)*1.3

				local x,y,z = table.unpack(GetEntityCoords(ped))
				local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))

				calculateTimeDisplay()

				local stamina = 100-GetPlayerSprintStaminaRemaining(PlayerId())

				if IsPedInAnyVehicle(ped) then
					local vehicle = GetVehiclePedIsIn(ped)

					local fuel = GetVehicleFuelLevel(vehicle)
					local speed = GetEntitySpeed(vehicle)*3.6
					SendNUIMessage({ active = showHud, celular = celular, movie = showMovie, vehicle = true, health = health, stamina = stamina, armour = armour, hunger = hunger, thirst = thirst, day = dayMonth, month = month, hour = hour, minute = minute, street = street, speed = parseInt(speed), fuel = parseInt(fuel), seatbelt = seatbelt })
				else
					SendNUIMessage({ active = showHud, celular = celular, movie = showMovie, vehicle = false, health = health, stamina = stamina, armour = armour, hunger = hunger, thirst = thirst, day = dayMonth, month = month, hour = hour, minute = minute, street = street })
				end
			end
		else
			if hunger <= 20 or thirst <= 20 then
				showHud = true
				timeDistance = 200
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function(source,args)
	showHud = not showHud
	SendNUIMessage({ active = showHud, movie = showMovie })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("movie",function(source,args)
	showMovie = not showMovie
	SendNUIMessage({ active = showHud, movie = showMovie })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADHEALTHREDUCE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local health = GetEntityHealth(ped)

		if health > 101 then
			if hunger >= 10 and hunger <= 20 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-1)
			elseif hunger <= 9 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-2)
			end

			if thirst >= 10 and thirst <= 20 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-1)
			elseif thirst <= 9 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-2)
			end
		end

		Citizen.Wait(5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if seatbelt then
				DisableControlAction(0,75)
			end

			timeDistance = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not seatbelt and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				timedown = 10
			end

			if IsControlJustReleased(1,47) then
				if seatbelt then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					seatbelt = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					seatbelt = true
				end
			end
		elseif ExNoCarro then
			ExNoCarro = false
			seatbelt = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end

		Citizen.Wait(timeDistance)
	end
end)
------
Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local kswait = 1000
		if IsPedInAnyVehicle(ped) then
			if not IsRadarEnabled() then
				DisplayRadar(true)
			end
		else
			if not IsEntityPlayingAnim(ped,"cellphone@","cellphone_text_in",3) then
				DisplayRadar(false)
				seatbelt = false
			end
		end
		if IsRadarEnabled() then
			SetRadarZoom(1000)
		end
		Citizen.Wait(kswait)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMEDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 0 and GetEntityHealth(ped) > 101 then
			timedown = timedown - 1
			if timedown <= 1 then
				TriggerServerEvent("vrp_inventory:Cancel")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RAGDOLL
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 1 and GetEntityHealth(ped) > 101 then
			if not IsEntityPlayingAnim(ped,"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a",3) then
				vRP.playAnim(false,{"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a"},true)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISABLE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local TimeDistance = 500
		if timedown > 0 then
			TimeDistance = 4
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,57,true)
			DisableControlAction(0,105,true)
			DisableControlAction(0,167,true)
			DisableControlAction(0,20,true)
			DisableControlAction(0,29,true)
		end
		Citizen.Wait(TimeDistance)
	end
end)