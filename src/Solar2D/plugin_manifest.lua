--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

local solar2dVersionNumber = 3673
local solar2dVersionPublishedYear = 2022

-- users can override the solar2d version to use by passing in `solar2DVersion`
if type(solar2DVersion) == "string" then
    local one = ""
    local two = ""
    local part = 1
    local badInput = true
    for i = 1, #solar2DVersion do
        local c = solar2DVersion:sub(i,i)
        if c == "." then
            if part == 2 then
                badInput = true
                break
            else
                part = 2
            end
        elseif tonumber(c) == nil then
            badInput = true
            break
        else
            if part == 1 then
                one = one .. c
            else
                badInput = false
                two = two .. c
            end
        end
    end
    if not badInput then
        solar2dVersionPublishedYear = one
        solar2dVersionNumber = two
    end
end

local function getCoronaCardsFrameworkUrl()
    return "https://github.com/coronalabs/corona/releases/download/"
        .. tostring(solar2dVersionNumber)
        .. "/CoronaCards-iOS-"
        .. tostring(solar2dVersionPublishedYear)
        .. "."
        .. tostring(solar2dVersionNumber)
        .. ".zip"
end

manifest =
{
    --
    -- General Information
    --
    name = "Solar2D",
    authorId = "com.appmakerios",
    version = "1.0.0",
    dependencies = {},
    supportedTargets = {
        "iOS",
    },
    supportedRuntimes = {
        "mainApp",
        "companionIOSApp",
    },

    --
    -- Implementation
    --
    implementation = {
        --
        -- Entry point to installing the plugin at runtime
        --
        functionEntryPoint = "solar2d_main()",

        --
        -- If an import is needed to call the function entry point,
        -- you can add the module here. i.e. "Example" would produce:
        --
        --      import Example
        --      example_main()
        --
        -- functionEntryPointModuleToImport = "Example",

        --
        -- Adding local source files
        --
        sources = {
            {
                -- Source paths are relative to the plugin_manifest.lua file
                path = "./Sources"
            }
        },

        --
        -- Linking frameworks
        --
        frameworks = {
            -- CoronaCards framework
            {
                url = getCoronaCardsFrameworkUrl(),
                link = true,
                embed = false,
            },
        },

        --
        -- Linking SDKs
        --
        sdks = {
            -- todo: this framework might be needed for some Solar2D plugins.
            -- {
            --      name = "AdSupport.framework",
            -- },
            {
                name = "AudioToolbox.framework",
            },
            {
                name = "AVFoundation.framework",
            },
            {
                name = "CFNetwork.framework",
            },
            {
                name = "CoreGraphics.framework",
            },
            {
                name = "CoreLocation.framework",
            },
            {
                name = "CoreMedia.framework",
            },
            {
                name = "CoreMotion.framework",
            },
            {
                name = "CoreVideo.framework",
            },
            {
                name = "Foundation.framework",
            },
            {
                name = "GameController.framework",
            },
            {
                name = "GLKit.framework",
            },
            {
                name = "ImageIO.framework",
            },
            {
                name = "MediaPlayer.framework",
            },
            {
                name = "MobileCoreServices.framework",
            },
            {
                name = "OpenAL.framework",
            },
            {
                name = "OpenGLES.framework",
            },
            {
                name = "QuartzCore.framework",
            },
            {
                name = "Security.framework",
            },
            {
                name = "SystemConfiguration.framework",
            },
            {
                name = "UIKit.framework",
            },
        },

        --
        -- If you wish to add #import <Example/Example.h> to the bridging header.
        --
        bridgingHeaderImport = "\"CoronaCards/CoronaCards.h\"",
    },
}
