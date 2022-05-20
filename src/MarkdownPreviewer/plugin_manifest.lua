--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

manifest =
{
    --
    -- General Information
    --
    name = "MarkdownPreviewer",
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
        functionEntryPoint = "markdownpreviewer_main()",

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
                name = "MarkdownUI",
                productName = "MarkdownUI",
                -- url = "https://github.com/gonzalezreal/MarkdownUI.git",
                -- minorVersion = "1.0.0",
                url = "https://github.com/joehinkle11/MarkdownUI.git", -- this version includes support for unknown schemes
                branch = "main",
            },
        },
    },
}