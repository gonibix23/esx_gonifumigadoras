ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_gonifumigadoras:getPayedForWork')
AddEventHandler('esx_gonifumigadoras:getPayedForWork', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addMoney(Config.MoneyPay)
end)

RegisterServerEvent('esx_gonifumigadoras:planeCost')
AddEventHandler('esx_gonifumigadoras:planeCost', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getAccount('bank').money >= Config.AircraftCost then
		xPlayer.removeAccountMoney('bank', Config.AircraftCost)
	end
end)

RegisterServerEvent('esx_gonifumigadoras:receivePlaneCost')
AddEventHandler('esx_gonifumigadoras:receivePlaneCost', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addAccountMoney('bank', Config.AircraftCost)
end)

ESX.RegisterServerCallback('esx_gonifumigadoras:receiveJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xJob = xPlayer.getJob().name
    cb(xJob)
end)
