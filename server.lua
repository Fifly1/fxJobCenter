local QBCore = exports['qb-core']:GetCoreObject()
local availableJobs = {}
local jobCenters = {}

function getAvailableJobsAndCenters()
    for _, job in ipairs(Config.Jobs.NonWhitelist) do
        availableJobs[job.jobName] = true
    end
    for _, coords in ipairs(Config.Locations) do
        local jobCenterData = {
            coords = coords
        }
        table.insert(jobCenters, jobCenterData)
    end
end

function isJobCenter(jobCenterCoords)
    for _, jobCenterData in ipairs(jobCenters) do
        local coords = jobCenterData.coords
        if jobCenterCoords == coords then
            return true
        end
    end
    return false
end

function isCooldownActive(license, job)
    local result = MySQL.Sync.fetchAll('SELECT UNIX_TIMESTAMP(applied_at) as applied_at FROM fx_jobcenter WHERE license = ? AND job = ? ORDER BY id DESC LIMIT 1', {license, job})
    if result[1] then
        local lastAppliedAt = tonumber(result[1].applied_at)
        return (os.time() - lastAppliedAt) < (Config.whitelistCooldown * 60 * 60)
    else
        return false
    end
end

function isOnCooldownFunction(playerId)
    local src = playerId
    local cooldownTime = Config.whitelistCooldown * 60 * 60

    local lastApplicationTime = nil
    MySQL.Async.fetchScalar('SELECT applied_at FROM fx_jobcenter WHERE license = @license ORDER BY applied_at DESC LIMIT 1', {
        ["@license"] = GetPlayerIdentifier(src, 'license')
    }, function(result)
        if result then
            lastApplicationTime = tonumber(result)
        end
    end)

    if lastApplicationTime == nil then
        return false
    end

    local currentTime = os.time()
    local timeElapsed = currentTime - lastApplicationTime

    if timeElapsed < cooldownTime then
        return true
    else
        return false
    end
end

RegisterNetEvent('fx_jobcenter:server:ApplyJob', function(job, jobCenterCoords)
    getAvailableJobsAndCenters()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    if not isJobCenter or #(pedCoords - jobCenterCoords) >= 20.0 or not availableJobs[job] then
        return false
    end
    local JobInfo = QBCore.Shared.Jobs[job]
    Player.Functions.SetJob(job, 0)
    if Config.useFxNotify then
        TriggerClientEvent('fx_notify:Notify', src, "success", Lang:t('info.blip_text'), Lang:t('info.new_job', { job = JobInfo.label }), 3000)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.new_job', { job = JobInfo.label }))
    end
end)

RegisterNetEvent('fx_jobcenter:server:DiscordWebhook', function(jobName, newJob, name, job, phone, questionAnswers)
    local src = source
    local JobInfo = QBCore.Shared.Jobs[jobName]
    local webhookURL

    for _, v in ipairs(Config.Jobs.Whitelist) do
        if v.jobName == jobName then
            webhookURL = v.webhook
            break
        end
    end

    if not webhookURL then
        print("Webhook URL not found for job: " .. jobName)
        return
    end

    local license, discord
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end

    if discord == nil then
        discord = "discord:0"
    end

    local cooldownTime = Config.whitelistCooldown * 60 * 60

    local query = "SELECT UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(MAX(applied_at)) as time_passed FROM fx_jobcenter WHERE license = ? AND job = ? AND applied_at > (NOW() - INTERVAL 24 HOUR)"
    MySQL.Async.fetchScalar(query, {license, newJob}, function(timePassed)
        if timePassed and timePassed < cooldownTime then
            local remainingTime = cooldownTime - timePassed
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            local seconds = remainingTime % 60
            local remainingTimeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

            if Config.useFxNotify then
                TriggerClientEvent('fx_notify:Notify', src, "error", Lang:t('info.blip_text'), Lang:t('info.cooldown', { time = remainingTimeString }), 3000)
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('info.cooldown', { time = remainingTimeString }))
            end
        else
            local title = 'FX Job Center | ' .. newJob
            discordWebhook(webhookURL, title, name, job, phone, questionAnswers, license, discord)

            local updateQuery = "UPDATE fx_jobcenter SET name = ?, job = ?, applied_at = NOW() WHERE license = ? AND job = ?"
            MySQL.Async.execute(updateQuery, {name, newJob, license, newJob}, function(rowsChanged)
                if rowsChanged > 0 then
                    if Config.useFxNotify then
                        TriggerClientEvent('fx_notify:Notify', src, "success", Lang:t('info.blip_text'), Lang:t('info.new_job_app', { job = JobInfo.label }), 3000)
                    else
                        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.new_job_app', { job = JobInfo.label }))
                    end
                else
                    local insertQuery = "INSERT INTO fx_jobcenter (license, name, job, applied_at) VALUES (?, ?, ?, NOW())"
                    MySQL.Async.execute(insertQuery, {license, name, newJob}, function(rowsChanged)
                        if Config.useFxNotify then
                            TriggerClientEvent('fx_notify:Notify', src, "success", Lang:t('info.blip_text'), Lang:t('info.new_job_app', { job = JobInfo.label }), 3000)
                        else
                            TriggerClientEvent('QBCore:Notify', src, Lang:t('info.new_job_app', { job = JobInfo.label }))
                        end
                    end)
                end
            end)
        end
    end)
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

function discordWebhook(webhookURL, title, name, job, phone, questionAnswers, license, discord)
    local embedBase = function()
        return {
            {
                ["color"] = 7087550,
                ["title"] = title,
                ["fields"] = {
                    {
                        ["name"] = "Name:",
                        ["value"] = name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Current Job:",
                        ["value"] = job,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Phone Number:",
                        ["value"] = phone,
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = license .. " " .. discord,
                },
            }
        }
    end

    local function sendWebhook(fields, first)
        local embed = embedBase()
        embed[1].fields = fields
        if not first then
            embed[1].title = ""
        end
        PerformHttpRequest(webhookURL, function(err, text, headers)
            Citizen.Wait(1000)
        end, 'POST', json.encode({username = title, embeds = embed}), { ['Content-Type'] = 'application/json' })
    end

    local chunk = ""
    local currentFields = embedBase()[1].fields
    local first = true
    for _, qa in ipairs(questionAnswers) do
        local qaString = "**" .. qa.question .. "**\n" .. qa.answer .. "\n\n"
        if #chunk + #qaString > 1000 then
            table.insert(currentFields, { ["name"] = "", ["value"] = chunk, ["inline"] = false })
            sendWebhook(currentFields, first)
            Citizen.Wait(1000)
            currentFields = embedBase()[1].fields
            chunk = qaString
            first = false
        else
            chunk = chunk .. qaString
        end
    end

    if chunk ~= "" then
        table.insert(currentFields, { ["name"] = "", ["value"] = chunk, ["inline"] = false })
        sendWebhook(currentFields, first)
    end
end
