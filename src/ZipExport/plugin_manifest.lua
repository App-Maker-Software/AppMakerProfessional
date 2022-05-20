--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

manifest =
{
    --
    -- General Information
    --
    name = "ZipExport",
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
        functionEntryPoint = "zipexport_main()",

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
                name = "Zip",
                productName = "Zip",
                url = "https://github.com/marmelroy/Zip.git",
                minorVersion = "2.1",
            },
        },
    },
}