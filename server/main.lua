ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_gonifumigadoras:getPayedForWork')
AddEventHandler('esx_gonifumigadoras:getPayedForWork', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addMoney(2000)
end)

RegisterServerEvent('esx_gonifumigadoras:planeCost')
AddEventHandler('esx_gonifumigadoras:planeCost', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeAccountMoney('bank', 5000)
end)

RegisterServerEvent('esx_gonifumigadoras:receivePlaneCost')
AddEventHandler('esx_gonifumigadoras:receivePlaneCost', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addAccountMoney('bank', 5000)
end)
