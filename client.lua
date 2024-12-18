local notifiedVehicles = {}

local function GetFlatTires(vehicle)
    local flatTires = 0
    for i = 0, 5 do
        if IsVehicleTyreBurst(vehicle, i, false) then
            flatTires = flatTires + 1
        end
    end
    return flatTires
end

local function GetVehicleType(vehicle)
    local hash = GetEntityModel(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass == 2 then return 'Sports'
    elseif vehicleClass == 9 then return 'SUV'
    elseif vehicleClass == 10 then return 'Offroad'
    elseif vehicleClass == 0 then return 'Compact'
    elseif vehicleClass == 1 then return 'Sedan'
    else return 'Other'
    end
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            local flatTires = GetFlatTires(vehicle)
            if flatTires > 0 then
                if not notifiedVehicles[vehicle] then
                    local vehicleType = GetVehicleType(vehicle)
                    lib.notify({
                        title = 'Problém s pneumatikami',
                        description = string.format("Máte píchnuté pneumatiky: %d", flatTires),
                        type = 'error' -- Změňte typ podle potřeby ('success', 'error', 'info', atd.)
                    })                    
                    notifiedVehicles[vehicle] = true
                end

                if GetEntitySpeed(vehicle) > 1.0 then 
                    local vehicleType = GetVehicleType(vehicle)
                    local multiplier = Config.VehicleTypeMultiplier[vehicleType] or 1.0
                    local shakeIntensity = (Config.Sensitivity[flatTires] or 0.1) * multiplier

                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', shakeIntensity)
                end
            else
                notifiedVehicles[vehicle] = nil 
            end
        end

        Wait(500) 
    end
end)

