--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

local appMakerCoreVersion = "0.9.3"

local function getXCFrameworkURL(filename)
    local repoOwner = "App-Maker-Software"
    local repoName = "AppMakerProfessional"
    return "https://github.com/".. repoOwner .. "/" .. repoName .. "/releases/download/" .. appMakerCoreVersion .. "/" .. filename
end

function ternary( cond , T , F )
    if cond then return T else return F end
end

local appMakerCoreImplementation = {
    --
    -- Entry point to installing the plugin at runtime
    --
    functionEntryPoint = "register_builtin_compile_time_customizations()",
    functionEntryPointModuleToImport = "AppMakerCore",

    --
    -- Adding Swift Packages
    --
    swiftPackages = {
        {
            active = flags.DEV and (not flags.STAGING),
            name = "AppMakerPrivate",
            productName = "AppMakerCore",
            path = "../AppMakerPrivate",
        },
        {
            active = flags.APPSTORE,
            name = "AppMakerPrivate",
            productName = "AppMakerAppStoreCore",
            path = "../AppMakerPrivate",
        },
    },

    --
    -- Linking XC frameworks
    --
    xcFrameworks = {
        {
            active = flags.PROD and (not flags.STAGING) and (not flags.APPSTORE),
            url = getXCFrameworkURL("AppMakerCore.xcframework.zip"),
        },
        {
            active = flags.STAGING,
            path = "../../ReleaseAssets/AppMakerCore.xcframework",
        },
    },
}
    

local appMakerCompanionCoreImplementation = {
    --
    -- Entry point to installing the plugin at runtime
    --
    functionEntryPoint = "register_builtin_compile_time_customizations()",
    functionEntryPointModuleToImport = "AppMakerCompanionCore",

    --
    -- Adding Swift Packages
    --
    swiftPackages = {
        {
            active = (flags.DEV and (not flags.STAGING)) or flags.APPSTORE,
            name = "AppMakerPrivate",
            productName = "AppMakerCompanionCore",
            path = "../AppMakerPrivate",
        },
    },

    --
    -- Linking XC frameworks
    --
    xcFrameworks = {
        {
            active = flags.PROD and (not flags.STAGING) and (not flags.APPSTORE),
            url = getXCFrameworkURL("AppMakerCompanionCore.xcframework.zip"),
        },
        {
            active = flags.STAGING,
            path = "../../ReleaseAssets/AppMakerCompanionCore.xcframework",
        },
    },
}

manifest =
{
    --
    -- General Information
    --
    name = "Core",
    authorId = "com.appmakerios",
    version = appMakerCoreVersion,
    dependencies = {},
    supportedTargets = {
        "iOS",
        "iOSSim",
    },
    supportedRuntimes = ternary(flags.COMPANION, {"companionIOSApp"}, {"mainApp"}),

    --
    -- Implementation
    --
    implementation = ternary(flags.COMPANION, appMakerCompanionCoreImplementation, appMakerCoreImplementation),
}
