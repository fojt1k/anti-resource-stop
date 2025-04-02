
local function getClientResources()
    local resources = {}
    local resourceCount = GetNumResources()
    for i = 0, resourceCount - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName and GetResourceState(resourceName) == "started" then
            resources[resourceName] = true
        end
    end
    return resources
end

CreateThread(function()
    while true do
        Wait(math.random(10000, 15000))
        local resourceList = getClientResources()
        TriggerServerEvent("antiResourceStop:reportResources", resourceList)
    end
end)