ESX = nil
local teams_data = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('iysood_warzone:register_team', function(source, cb, team, state)
  local xPlayer = ESX.GetPlayerFromId(source)
  local foundit

  if state then
    teams_data[xPlayer.source] = { kill = 0, death = 0, name = xPlayer.getName(), team = team }
  else
    teams_data[xPlayer.source] = nil
  end

  cb(teams_data[xPlayer.source])
end)

-- -- AddEventHandler('esx:onPlayerDeath', function(data)
RegisterServerEvent('iysood_warzone:record_death')
AddEventHandler('iysood_warzone:record_death', function(killedBy)
	local _source = source

  if teams_data[_source] ~= nil then
    local killerBy = killedBy
    teams_data[_source].death = teams_data[_source].death + 1
    teams_data[killerBy].kill = teams_data[killerBy].kill + 1

    TriggerClientEvent('iysood_warzone:death_recorded', _source, teams_data[_source].team)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    for k,v in pairs(teams_data) do
      TriggerClientEvent('iysood_warzone:update_data', k, teams_data)
    end

  end
end)
