local clientResources = {}
local expectedResources = {}

local function hasClientSide(resourceName)
    local clientScript = GetResourceMetadata(resourceName, "client_script", 0)
    local sharedScript = GetResourceMetadata(resourceName, "shared_script", 0)
    return clientScript ~= nil or sharedScript ~= nil
end

local function updateExpectedResources()
    expectedResources = {}
    local resourceCount = GetNumResources()
    for i = 0, resourceCount - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName and GetResourceState(resourceName) == "started" and hasClientSide(resourceName) then
            expectedResources[resourceName] = true
        end
    end
end

CreateThread(function()
    updateExpectedResources()
    while true do
        Wait(60000)
        updateExpectedResources()
    end
end)

RegisterNetEvent("antiResourceStop:reportResources")
AddEventHandler("antiResourceStop:reportResources", function(clientResourceList)
    local src = source
    if not src then return end
    
    clientResources[src] = clientResourceList or {}
    
    local missingResources = {}
    for resourceName, _ in pairs(expectedResources) do
        if not clientResources[src][resourceName] then
            table.insert(missingResources, resourceName)
        end
    end
    
    if #missingResources > 0 then
        local missingList = table.concat(missingResources, ", ")
        print("Hráč " .. src .. " má zastavené resource: " .. missingList)
        -- DropPlayer(src, "Resource Stopped: " .. missingList)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    clientResources[src] = nil
end)
