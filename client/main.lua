ESX = nil
local CurrentActionData, CurrentAction, CurrentActionMsg, HasAlreadyEnteredMarker, LastStation = {}, nil, nil, false, nil
local inside_zone, in_team, addingWeapon = true, false, nil
local team_info = {}

RegisterFontFile('sharlock')
local fontId = RegisterFontId('sharlock')

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end

  while ESX.GetPlayerData().job == nil do
    Citizen.Wait(10)
  end

  ESX.PlayerData = ESX.GetPlayerData()
  -- TriggerEvent('iysood_warzone:death_recorded', 'red_team')
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('iysood_warzone:death_recorded')
AddEventHandler('iysood_warzone:death_recorded', function(team)
  local playerPed = PlayerPedId()
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  local formattedCoords = {x = Config.Zone[team].Pos.x, y = Config.Zone[team].Pos.y, z = Config.Zone[team].Pos.z + 2.0}

  RespawnPed(playerPed, formattedCoords, Config.Zone[team].Heading)
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  DoScreenFadeIn(800)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  -- WILL GET -->
  -- data.deathCause
  -- data.killedByPlayer

  if inside_zone and data.killedByPlayer then
    TriggerServerEvent('iysood_warzone:record_death', data.killedByPlayer)
  end
  -- TriggerEvent('iysood_warzone:revive')
end)

function RespawnPed(ped, coords, heading)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
end

AddEventHandler('iysood_warzone:hasEnteredMarker', function(station)
  print('hasEnteredMarker', station)

	if station == 'Enter' then
		CurrentAction     = 'menu_enter'
		CurrentActionMsg  = _U('open_enter_menu')
		CurrentActionData = {}
	elseif station == 'Exit' then
		CurrentAction     = 'menu_exit'
		CurrentActionMsg  = _U('open_exit_menu')
		CurrentActionData = {}
	elseif station == 'Reset' then
		CurrentAction     = 'menu_reset'
		CurrentActionMsg  = _U('open_reset_menu')
		CurrentActionData = {}
	elseif station == 'Action' then
		CurrentAction     = 'menu_action'
		CurrentActionMsg  = _U('open_action_menu')
		CurrentActionData = {}
	elseif station == 'Start' then
		CurrentAction     = 'menu_start'
		CurrentActionMsg  = _U('open_start_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('iysood_warzone:hasExitedMarker', function(station)
  print('hasExitedMarker', station)

	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Draw markers and more
CreateThread(function()
	while true do
		Wait(1)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local isInMarker, hasExited, letSleep = false, false, true
		local currentStation

		for k,v in pairs(Config.Zone) do
      local distance = #(playerCoords - v.Pos)

      if inside_zone and distance > Config.DrawDistance * 2 then
        inside_zone = false
        if addingWeapon ~= nil then
          RemoveWeaponFromPed(PlayerPedId(), addingWeapon)
          addingWeapon = nil
          ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
          end)
        end
      end

      if (k == 'Enter' or k == 'Exit') and distance < Config.DrawDistance or
      k == 'blue_team' and inside_zone or
      k == 'red_team' and inside_zone or
      k == 'Reset' and inside_zone or
      k == 'Action' and inside_zone or
      k == 'Start' and inside_zone then
        letSleep = false

        if k == 'blue_team' or k == 'red_team' then
          DrawMarker(Config.MarkerType[k], v.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize2.x, Config.MarkerSize2.y, Config.MarkerSize2.z, Config.MarkerColor2[k].r, Config.MarkerColor2[k].g, Config.MarkerColor2[k].b, 100, false, true, 2, true, false, false, false)
        else
          if v.title ~= nil then
            ESX.Game.Utils.DrawText3D({ x = v.Pos.x, y = v.Pos.y, z = v.Pos.z + 1.0 }, v.title)
          end
          DrawMarker(Config.MarkerType[k], v.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)

          if distance < Config.MarkerSize.x then
            isInMarker, currentStation = true, k
          end

        end

      end
		end

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation)) then
			if
				(LastStation) and
				(LastStation ~= currentStation)
			then
				TriggerEvent('iysood_warzone:hasExitedMarker', LastStation)
				hasExited = true
			end

			HasAlreadyEnteredMarker = true
			LastStation = currentStation

			TriggerEvent('iysood_warzone:hasEnteredMarker', currentStation)
		end

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('iysood_warzone:hasExitedMarker', LastStation)
		end

		if letSleep then
			Citizen.Wait(500)
		end

	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    local letSleep = true

    if CurrentAction then
      letSleep = false

      ESX.ShowHelpNotification(CurrentActionMsg)

      if IsControlJustReleased(0, 38) then
        if CurrentAction == 'menu_enter' then
          open_menu_enter()
        elseif CurrentAction == 'menu_exit' then
          open_menu_exit()
        elseif CurrentAction == 'menu_blue_team' then
          open_menu_blue_team()
        elseif CurrentAction == 'menu_red_team' then
          open_menu_red_team()
        elseif CurrentAction == 'menu_reset' then
          open_menu_reset()
        elseif CurrentAction == 'menu_action' then
          open_menu_action()
        elseif CurrentAction == 'menu_start' then
          open_menu_start()
        end
      end

    end

    if letSleep then
      Citizen.Wait(500)
    end
  end
end)

open_menu_enter = function()
  local ped = PlayerPedId()
  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(500)
  end

  ESX.Game.Teleport(ped, Config.Zone.Exit.Pos + 2.5, function()
    DoScreenFadeIn(800)
    inside_zone = true

    SetEntityHeading(ped, 0.0)
  end)
end

open_menu_exit = function()
  local ped = PlayerPedId()

  if addingWeapon ~= nil then
    RemoveWeaponFromPed(PlayerPedId(), addingWeapon)
    addingWeapon = nil
  end

  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
    TriggerEvent('skinchanger:loadSkin', skin)
  end)

  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(500)
  end

  ESX.Game.Teleport(ped, Config.Zone.Enter.Pos + 2.5, function()
    DoScreenFadeIn(800)
    inside_zone = false

    SetEntityHeading(ped, 230.0)
  end)
end

open_menu_blue_team = function()
  ESX.ShowNotification('menu_blue_team')
end

open_menu_red_team = function()
  ESX.ShowNotification('menu_red_team')
end

open_menu_reset = function()
  ESX.ShowNotification('menu_reset')
end

open_menu_action = function()
  local elements = {
    { label = _U('logout'), value = 'logout' },
    { label = _U('choose_anim'), value = 'choose_anim' },
    { label = _U('red_team'), value = 'red_team' },
    { label = _U('blue_team'), value = 'blue_team' },
  }

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'open_menu_action', {
		title    = _U('menu_action'),
		align    = 'bottom-right',
		elements = elements
  }, function(data, menu)
    menu.close()

    if data.current.value == 'logout' then
      RemoveWeaponFromPed(PlayerPedId(), addingWeapon)
      addingWeapon = nil

      ESX.TriggerServerCallback('iysood_warzone:register_team', function(data)
        in_team = false
        team_info = {}

        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
          TriggerEvent('skinchanger:loadSkin', skin)
        end)

      end, data.current.value, false)

    elseif data.current.value == 'choose_anim' then
      ESX.ShowNotification('choose_anim')
    elseif data.current.value == 'red_team' or data.current.value == 'blue_team' then

      ESX.TriggerServerCallback('iysood_warzone:register_team', function(result)
        if result ~= nil then
          in_team = true

          setUniform(PlayerPedId(), data.current.value)
          local toAddWeapon = math.random(0, #Config.Weapons)
          addingWeapon = GetHashKey(Config.Weapons[toAddWeapon])
          GiveWeaponToPed(PlayerPedId(), addingWeapon, 500, false, true)
          ESX.ShowNotification(_U('your_weapon', ESX.GetWeaponLabel(Config.Weapons[toAddWeapon]), toAddWeapon, #Config.Weapons))
        end
      end, data.current.value, true)

    end

  end, function(data, menu)
    menu.close()
  end)
end

open_menu_start = function()
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'open_menu_action', {
		title    = _U('start_war'),
		align    = 'bottom-right',
		elements = {
      { label = _U('return') },
      { label = _U('yes'), value = true},
    }
  }, function(data, menu)
    menu.close()

    if data.current.value then
      if not in_team then
        ESX.ShowNotification(_U('must_in_team'))
      else
        start_war_action()
      end
    end

  end, function(data, menu)
    menu.close()
  end)
end

start_war_action = function()

end

cleanPlayer = function(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

setUniform = function(playerPed, uniform)
  print(playerPed, uniform)
	TriggerEvent('skinchanger:getSkin', function(skin)
		cleanPlayer(playerPed)
		local uniformObject

		if skin.sex == 0 then
			uniformObject = Config.Uniforms[uniform].male
		else
			uniformObject = Config.Uniforms[uniform].female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		else
			ESX.ShowNotification(_U('no_outfit'))
		end
	end)
end

RegisterNetEvent('iysood_warzone:update_data')
AddEventHandler('iysood_warzone:update_data', function(fetch_data)
  local playerServId = GetPlayerServerId(PlayerId())
  local prepared_data = {
    kill = fetch_data[playerServId].kill,
    death = fetch_data[playerServId].death,
  }

  local first_count, first_name = 0, ''
  local second_count, second_name = 0, ''
  local third_count, third_name = 0, ''
  local total_players = 0

  for k,v in pairs(fetch_data) do
    total_players = total_players + 1
    if v.kill > first_count then
      first_count = v.kill
      first_name = v.name
    elseif v.kill > second_count then
      second_count = v.kill
      second_name = v.name
    elseif v.kill > third_count then
      third_count = v.kill
      third_name = v.name
    end
  end

  team_info = {
    first = '['.. third_count ..'] '.. first_name,
    second = '['.. third_count ..'] '.. second_name,
    third = '['.. third_count ..'] '.. third_name,
    kill = fetch_data[playerServId].kill,
    death = fetch_data[playerServId].death,
    total = total_players,
  }
end)

drawingText = function(text, x, y)
  SetTextFont(fontId)
  SetTextScale(0.0, 0.35)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)

  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(text)
  DrawText(x, y)
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    local letSleep = true

    if team_info.kill ~= nil then
      letSleep = false
      drawingText(_U('lang_first', team_info.first), 0.9, 0.6)
      drawingText(_U('lang_second', team_info.second), 0.9, 0.63)
      drawingText(_U('lang_third', team_info.third), 0.9, 0.66)
      drawingText(_U('lang_level'), 0.9, 0.69)
      drawingText(_U('lang_kill', team_info.kill), 0.9, 0.72)
      drawingText(_U('lang_death', team_info.death), 0.9, 0.75)
      drawingText(_U('lang_total', team_info.total), 0.9, 0.78)
    end

    if letSleep then
      Citizen.Wait(500)
    end
  end
end)
