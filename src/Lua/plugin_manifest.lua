--
-- For more information on plugin_manifest.lua, see:
-- https://docs.appmakerios.com/#/plugin-manifest
--

manifest =
{
    --
    -- General Information
    --
    name = "Lua",
    authorId = "com.appmakerios",
    version = "1.0.0",
    dependencies = {},
    supportedTargets = {
        "iOS",
        "iOSSim",
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
        functionEntryPoint = "luaplugin_main()",

        --
        -- Adding local source files
        --
        sources = {
            {
                -- Source paths are relative to the plugin_manifest.lua file
                path = "./Sources"
            }
        },
        swiftPackages = {
            {
                name = "LuaSwiftBindings",
                productName = "LuaSwiftBindings",
                revision = "60a5ad37c0ddd7a3521be0f6b1ab5b2387e7f802", -- Lua 5.4.4 with suffixed exported symbols to avoid collisions with CoronaCard's embedded Lua interpreter.
                url = "https://github.com/App-Maker-Software/LuaSwiftBindings.git",
            },
        },
    },
}
