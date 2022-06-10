--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

manifest =
{
    --
    -- General Information
    --
    name = "GitProviders",
    authorId = "com.appmakerios",
    version = "1.0.1",
    dependencies = {},
    supportedTargets = {
        "iOS",
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
        functionEntryPoint = "gitproviders_main()",
        
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
                name = "GitProviders",
                productName = "GitProviders",
                url = "https://github.com/App-Maker-Software/GitProviders.git",
                minorVersion = "1.0.1",
            },
        },
    },
}
