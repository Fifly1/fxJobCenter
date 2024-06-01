local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local closestJobCenter = nil
local inJobCenterPage = false
local inRangeJobCenter = false
local pedsSpawned = false
local blips = {}

local function getClosestJobCenter()
    local distance = #(playerCoords - Config.Locations[1].coords)
    local closest = 1
    for i = 1, #Config.Locations do
        local hall = Config.Locations[i]
        local dist = #(playerCoords - hall.coords)
        if dist < distance then
            distance = dist
            closest = i
        end
    end
    return closest
end

local function setJobCenterPageState(bool, message)
    if message then
        local action = "openJobCenter"
        if action then
            TriggerScreenblurFadeIn(1000)
        else
            TriggerScreenblurFadeOut(1000)
        end
        SendNUIMessage({
            action = action,
            whitelistJobs = Config.Jobs.Whitelist,
            nonWhitelistJobs = Config.Jobs.NonWhitelist,
            useImages = Config.useImages,
            closeWhitelistApplications = Config.closeWhitelistApplications
        })
    end
    SetNuiFocus(bool, bool)
    inJobCenterPage = bool
    if not Config.UseTarget or bool then return end
    inRangeJobCenter = false
end

local function createBlip(options)
    if not options.coords or type(options.coords) ~= 'table' and type(options.coords) ~= 'vector3' then return error(('createBlip() expected coords in a vector3 or table but received %s'):format(options.coords)) end
    local blip = AddBlipForCoord(options.coords.x, options.coords.y, options.coords.z)
    SetBlipSprite(blip, options.sprite or 1)
    SetBlipDisplay(blip, options.display or 4)
    SetBlipScale(blip, options.scale or 1.0)
    SetBlipColour(blip, options.colour or 1)
    SetBlipAsShortRange(blip, options.shortRange or false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(options.title or 'No Title Given')
    EndTextCommandSetBlipName(blip)
    return blip
end

local function deleteBlips()
    if not next(blips) then return end
    for i = 1, #blips do
        local blip = blips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function initBlips()
    for i = 1, #Config.Locations do
        local hall = Config.Locations[i]
        if hall.showBlip then
            blips[#blips + 1] = createBlip({
                coords = hall.coords,
                sprite = hall.blipData.sprite,
                display = hall.blipData.display,
                scale = hall.blipData.scale,
                colour = hall.blipData.colour,
                shortRange = true,
                title = hall.blipData.title
            })
        end
    end
end

local function spawnPeds()
    if not Config.Locations or not next(Config.Locations) or pedsSpawned then return end
    for i = 1, #Config.Locations do
        local current = Config.Locations[i]
        current.ped = type(current.ped) == 'string' and joaat(current.ped) or current.ped
        RequestModel(current.ped)
        while not HasModelLoaded(current.ped) do
            Wait(0)
        end
        local ped = CreatePed(0, current.ped, current.coords.x, current.coords.y, current.coords.z, current.npcHeading, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, true, true)
        current.pedHandle = ped
        if Config.UseTarget then
            local opts = {
                label = Lang:t('info.target_label'),
                icon = 'fa-solid fa-building',
                action = function()
                    inRangeJobCenter = true
                    setJobCenterPageState(true, true)
                end
            }
            exports['qb-target']:AddTargetEntity(ped, {
                options = { opts },
                distance = 2.0
            })
        else
            local options = current.zoneOptions
            if options then
                local zone = BoxZone:Create(current.coords.xyz, options.length, options.width, {
                    name = "zone_jobcenter_" .. ped,
                    heading = current.npcHeading,
                    debugPoly = false,
                    minZ = current.coords.z - 3.0,
                    maxZ = current.coords.z + 2.0
                })
                zone:onPlayerInOut(function(inside)
                    if isLoggedIn and closestJobCenter then
                        if inside then
                            inRangeJobCenter = true
                            if Config.useFxTextUI then
                                exports['fx_textui']:DrawText(Lang:t('info.job_center_menu'))
                            else
                                exports['qb-core']:DrawText(Lang:t('info.job_center_menu'))
                            end
                        else
                            if Config.useFxTextUI then
                                exports['fx_textui']:HideText()
                            else
                                exports['qb-core']:HideText()
                            end
                            inRangeJobCenter = false
                        end
                    end
                end)
            end
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not Config.Locations or not next(Config.Locations) or not pedsSpawned then return end
    for i = 1, #Config.Locations do
        local current = Config.Locations[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
    pedsSpawned = false
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
    deletePeds()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deleteBlips()
    deletePeds()
end)

RegisterNUICallback('close', function(_, cb)
    setJobCenterPageState(false, false)
    TriggerScreenblurFadeOut(1000)
    if not Config.UseTarget and inRangeJobCenter then 
        if Config.useFxTextUI then
            exports['fx_textui']:DrawText(Lang:t('info.job_center_menu'))
        else
            exports['qb-core']:DrawText(Lang:t('info.job_center_menu')) 
        end
    end
    cb('ok')
end)

RegisterNUICallback('applyJob', function(job, cb)
    if inRangeJobCenter then
        TriggerServerEvent('fx_jobcenter:server:ApplyJob', job, Config.Locations[closestJobCenter].coords)
    else
        if Config.useFxNotify then
            exports['fx_notify']:fx_notify("error", Lang:t('info.blip_text'), Lang:t('info.not_in_range'), 3000)
        else
            QBCore.Functions.Notify(Lang:t('info.not_in_range'), 'error')
        end
    end
    cb('ok')
end)

RegisterNUICallback('discord', function(data)
    local applyingJob = data.applyingJob
    local qAnswers = data.qAnswers
    local jobName = data.job
    if inRangeJobCenter then
        local name = PlayerData.charinfo.firstname.. " " .. PlayerData.charinfo.lastname
        local phone = PlayerData.charinfo.phone
        local job = PlayerData.job.label
        local questionAnswers = qAnswers
        local newJob = applyingJob
        TriggerServerEvent('fx_jobcenter:server:DiscordWebhook', jobName, newJob, name, job, phone, questionAnswers)
    else
        if Config.useFxNotify then
            exports['fx_notify']:fx_notify("error", Lang:t('info.blip_text'), Lang:t('info.not_in_range'), 3000)
        else
            QBCore.Functions.Notify(Lang:t('info.not_in_range'), 'error')
        end
    end
end)

CreateThread(function()
    while true do
        if isLoggedIn then
            playerPed = PlayerPedId()
            playerCoords = GetEntityCoords(playerPed)
            closestJobCenter = getClosestJobCenter()
        end
        Wait(1000)
    end
end)

CreateThread(function()
    initBlips()
    spawnPeds()
    if not Config.UseTarget then
        while true do
            local sleep = 1000
            if isLoggedIn and closestJobCenter then
                if inRangeJobCenter then
                    if not inJobCenterPage then
                        sleep = 0
                        if IsControlJustPressed(0, 38) then
                            setJobCenterPageState(true, true)
                            if Config.useFxTextUI then
                                Wait(500)
                                exports['fx_textui']:HideText()
                            else
                                exports['qb-core']:KeyPressed()
                                Wait(500)
                                exports['qb-core']:HideText()
                            end
                            sleep = 1000
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end
end)