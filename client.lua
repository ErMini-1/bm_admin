local freeze = false
local spectate = false
local selectedplayer
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
	WarMenu.CreateMenu('test', 'Admin Menu')
    WarMenu.CreateSubMenu('closeMenu', 'test', 'Are you sure?')
    WarMenu.CreateSubMenu('spectateList', 'test', 'Player List')
    WarMenu.CreateSubMenu('lookPlayer', 'spectateList', 'Player manage')

	while true do
        if WarMenu.IsMenuOpened('test') then
            if WarMenu.MenuButton('Player List', 'spectateList') then
            elseif WarMenu.MenuButton('Close', 'closeMenu') then
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('closeMenu') then
			if WarMenu.Button('Yes') then
				WarMenu.CloseMenu()
			elseif WarMenu.MenuButton('No', 'test') then
			end

			WarMenu.Display()
        elseif WarMenu.IsMenuOpened('spectateList') then
            for _,i in pairs(GetActivePlayers()) do
                if WarMenu.MenuButton((GetPlayerName(i).." ~o~ID: "..GetPlayerServerId(i).."~w~ "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~r~DEAD" or "~g~ALIVE")), 'lookPlayer') then
                    selectedplayer = i
                end
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('lookPlayer') then
            if WarMenu.Button("Freeze") then
                FreezePlayer(selectedplayer)
            elseif WarMenu.Button("Spectate") then
                SpectatePlayer(selectedplayer)
            elseif WarMenu.Button("Kill") then
                SetEntityHealth(GetPlayerPed(selectedplayer), 0)
            elseif WarMenu.Button("Heal") then
                SetEntityHealth(GetPlayerPed(selectedplayer), 200)
            elseif WarMenu.Button("Goto") then
                local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedplayer)))
                SetEntityCoords(PlayerPedId(), x,y,z)
            elseif WarMenu.Button("Bring") then
                ExecuteCommand('bring '..GetPlayerServerId(selectedplayer))
            elseif WarMenu.Button("Give car") then
                local target = GetPlayerPed(selectedplayer)
                local ModelName = KeyboardInput("Model", "", 100)
                if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
                    RequestModel(ModelName)
                    while not HasModelLoaded(ModelName) do
                        Citizen.Wait(0)
                    end
                    local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(target), GetEntityHeading(target)+90, true, true)
                end
            elseif WarMenu.Button("Revive") then
                ExecuteCommand('revive '..GetPlayerServerId(selectedplayer))
            elseif WarMenu.Button("Ban") then
                local DurationMenu = KeyboardInput("Duration", "", 100)
                local RazonMenu = KeyboardInput("Reason", "", 100)
                if DurationMenu and RazonMenu then
                    TriggerServerEvent('bm_admin:banUser', GetPlayerServerId(selectedplayer), DurationMenu, RazonMenu)
                end
            end

            WarMenu.Display()
        end

		Citizen.Wait(0)
	end
end)

RegisterNetEvent('bm_admin:openMenu')
AddEventHandler('bm_admin:openMenu', function()
    WarMenu.OpenMenu('test')
end)

SpectatePlayer = function(player)
    local playerPed = PlayerPedId()
    spectate = not spectate
    local targetPed = GetPlayerPed(player)

    if (spectate) then
        DoScreenFadeOut(500)
        while (IsScreenFadingOut()) do Citizen.Wait(0) end
        NetworkSetInSpectatorMode(false, 0)
        NetworkSetInSpectatorMode(true, targetPed)
        DoScreenFadeIn(500)
        print("spectate")
    else
        DoScreenFadeOut(500)
        while (IsScreenFadingOut()) do Citizen.Wait(0) end
        NetworkSetInSpectatorMode(false, 0)
        DoScreenFadeIn(500)
        print("stop")
    end
end

FreezePlayer = function(player)
    local targetPed = GetPlayerPed(player)
    freeze = not freeze
    if freeze then
        FreezeEntityPosition(targetPed, true)
    else
        FreezeEntityPosition(targetPed, false)
    end
end

KeyboardInput = function(TextEntry, ExampleText, MaxStringLength)
    AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        if IsDisabledControlPressed(0, 322) then return "" end
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
end