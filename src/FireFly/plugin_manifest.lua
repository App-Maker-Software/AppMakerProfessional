--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

manifest =
{
    --
    -- General Information
    --
    name = "Firefly",
    authorId = "com.appmakerios",
    version = "1.0.0",
    dependencies = {},
    supportedTargets = {
        "iOS",
        "iOSSim",
    },
    supportedRuntimes = {
        "mainApp",
    },

    --
    -- Implementation
    --
    implementation = {
        --
        -- Entry point to installing the plugin at runtime
        --
        functionEntryPoint = "firefly_main()",

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
        -- Adding Swift Packages
        --
        swiftPackages = {
            {
                active = flags.DEV,
                name = "Firefly",
                productName = "Firefly",
                path = "../Firefly",
            },
            {
                active = not flags.DEV,
                name = "Firefly",
                productName = "Firefly",
                revision = "92cfc3682b0a4a0d444e64fe843bb10e548d2db4",
                url = "https://github.com/joehinkle11/Firefly.git",
            },
        },
    },
}
