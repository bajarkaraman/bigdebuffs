local _, addon = ...
addon.RedirectManager = {}

local redirectConfigs = {}

function addon.RedirectManager:RegisterRedirectAddon(addonName, config)
    redirectConfigs[addonName] = config
end

function addon.RedirectManager:GetRedirectFrame(frame, redirectAddonName)
    if redirectConfigs[redirectAddonName] then
        return redirectConfigs[redirectAddonName].GetRedirectFrame(frame)
    end
    return nil
end

function addon.RedirectManager:InitializeRedirectAddons()
    for addonName, _ in pairs(redirectConfigs) do
        if _G[addonName] and redirectConfigs[addonName].Init then
            redirectConfigs[addonName].Init()
        end
    end
end