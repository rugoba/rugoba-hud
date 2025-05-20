local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local stress = 0
local hunger = 0
local thirst = 0
local startHud = false
local inVeh = false


DisplayRadar(false)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    PlayerData = QBCore.Functions.GetPlayerData()
    startHud = true
    Wait(3000)
    SetEntityHealth(PlayerPedId(), 200)
    TriggerEvent('hud:client:LoadMap')
end)
 
RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    startHud = false
    PlayerData = {}
end) 

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) 
    stress = newStress
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) 
    hunger = newHunger
    thirst = newThirst
end)


RegisterNetEvent('hud:client:LoadMap', function()
    Wait(50)
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end
   
    RequestStreamedTextureDict('squaremap', false)
    if not HasStreamedTextureDictLoaded('squaremap') then
        Wait(150)
    end
    SetMinimapClipType(0)
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    -- icons within map
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    Wait(50)
    SetBigmapActive(false, false)

    Wait(1200)
end)

CreateThread(function()
    while true do
        Wait(500)
        local menuPause = IsPauseMenuActive()
      
        if not menuPause then
                if startHud then
                    local player = PlayerPedId()
                    local talking = NetworkIsPlayerTalking(PlayerId())
                    local armorBar = GetPedArmour(player)
                    local healthBar = GetEntityHealth(player) - 100
                    local voice = 0
                    local pedVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                    local food
                    local water
                   
                
    
                    food = hunger
                    water = thirst
                           
                    if pedVehicle ~= 0 and GetIsVehicleEngineRunning(pedVehicle) then
                        inVeh = true
                        DisplayRadar(true)
                    else
                       inVeh = false
                       DisplayRadar(false)
                    end
                   
                    if LocalPlayer.state['proximity'] then
                        voice = LocalPlayer.state['proximity'].distance 
                    end
               
                    SendNUIMessage({
                        action = 'hudtick',
                        show = true,
                        health = healthBar,
                        armor = armorBar,
                        isTalking = talking,
                        hunger = math.ceil(food),
                        thirst =  math.ceil(water),
                        voice = voice,
                        inVeh = inVeh,
              
                    })
                
                else
                    SendNUIMessage({   action = 'hudtick', show = false })
                end
            else
               SendNUIMessage({   action = 'hudtick', show = false })
            end
        Wait(500)
    end
end)


local Round = math.floor

RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        local cash = Round(amount)
        QBCore.Functions.Notify("Gotovina: "..cash, 'success')
    else
        local bank = Round(amount)
        QBCore.Functions.Notify("Banka: "..bank, 'success')
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    cashAmount = PlayerData.money['cash']
    bankAmount = PlayerData.money['bank']

    if type == 'cash' then
        if isMinus then
            QBCore.Functions.Notify("cash:  - "..amount, 'error')
         else
            QBCore.Functions.Notify("cash:  + "..amount, 'success')
        end
    else
        if isMinus then
            QBCore.Functions.Notify("bank:  - "..amount, 'error')
         else
            QBCore.Functions.Notify("bank:  + "..amount, 'success')
        end
    end
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    startHud = true
    TriggerEvent('hud:client:LoadMap')
end)


-- Stress Gain

if not Config.DisableStress then
    CreateThread(function() -- Shooting
        while true do
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` then
                    if IsPedShooting(ped) and not Config.WhitelistedWeaponStress[weapon] then
                        if math.random() < Config.StressChance then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                else
                    Wait(1000)
                end
            end
            Wait(0)
        end
    end)
end

-- Stress Screen Effects

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(Config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            local BlurIntensity = GetBlurIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= Config.MinimumStress then
            local BlurIntensity = GetBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)




