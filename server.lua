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
        if resourceName and GetResourceState(resourceName) == "started" then
            if hasClientSide(resourceName) then
                expectedResources[resourceName] = true
            end
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
    clientResources[src] = clientResourceList
    
    for resourceName, _ in pairs(expectedResources) do
        if not clientResourceList[resourceName] then
            print("Hráč " .. src .. " má zastavený resource: " .. resourceName)
            -- DropPlayer(src, "Detekováno zastavení resource: " .. resourceName)
        end
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    clientResources[src] = nil
end)