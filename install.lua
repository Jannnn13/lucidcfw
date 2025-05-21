--[[
    LucidCFW - Custom BIOS and System for CC:Tweaked
    https://github.com/Jannnn13/LucidCFW

    Includes:
    CC: Tweaked Bios (MIT)
        URL: https://github.com/cc-tweaked/CC-Tweaked
        Author: CC:Tweaked Team

    unbios.lua
        URL: https://gist.github.com/MCJack123/42bc69d3757226c966da752df80437dc#file-unbios-lua
        Author: MCJack123

    Note: The dependencies are NOT included in this repository,
    it just downloads them from the original sources and modifies them.

    Author: Jannnn13 (https://github.com/Jannnn13) and Miko0187 (https://github.com/Miko0187)
    License: MIT License
]]

if not http then
    error("This script requires the HTTP API to be enabled.")
end

if not shell then
    error("This script requires the Shell API to be enabled.")
end

if not fs then
    error("This script requires the Filesystem API to be enabled.")
end

local lucidversion = 1.1
local cfwroot = "/lucid"
local unbiosPath = cfwroot .. "/bios/unbios.lua"
local biosPath = cfwroot .. "/bios/lucid.lua"
local cfwRom = cfwroot .. "/rom"
local programsPath = cfwRom .. "/programs"
local unbiosUrl = "https://gist.githubusercontent.com/MCJack123/42bc69d3757226c966da752df80437dc/raw/887547d8283fbfe6693c6586566c16b79d47a6ae/unbios.lua"
local biosUrl = "https://raw.githubusercontent.com/cc-tweaked/CC-Tweaked/mc-1.20.x/projects/core/src/main/resources/data/computercraft/lua/bios.lua"

local ApiUrl = {
    ui = "https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/apis/UI.lua",
    lucid = "https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/apis/lucid.lua",
    tcp = "https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/apis/tcp.lua",
    crypto = "https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/apis/crypto.lua"
}

local ProgramUrl = {
    craftos = "https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/programs/craftos.lua",
    btcct = "https://raw.githubusercontent.com/Jannnn13/btcct/refs/heads/main/btcct.lua"
}

local startupText = [[
if os.version():find("Lucid") then
    shell.setPath(".:/lucid/rom/programs:/lucid/rom/programs/http:/lucid/rom/programs/advanced:/lucid/rom/programs/rednet:/lucid/rom/programs/fun:/lucid/rom/programs/fun/advanced:/lucid/rom/programs/pocket:/lucid/rom/programs/turtle")
    
    shell.run("/lucid/rom/programs/btcct.lua")
    return
end

term.clear()
term.setCursorPos(1, 1)

local option = settings.get("lucidcfw.bootoverride")
if option == "craftos" then
    settings.set("lucidcfw.bootoverride", "lucid")
    settings.save()
    shell.run("/rom/programs/shell.lua")
    os.shutdown()
elseif option == "lucid" then
    if not fs.exists("/lucid/bios/unbios.lua") or not fs.exists("/lucid/bios/lucid.lua") then
        print("LucidCFW is corrupted. Rebooting to CraftOS...")
        sleep(2)
        settings.set("lucidcfw.bootoverride", "craftos")
        settings.save()
        os.reboot()
    end

    shell.run("/lucid/bios/unbios.lua")
else
    settings.set("lucidcfw.bootoverride", "lucid")
    settings.save()
    os.reboot()
end
]]

print("LucidCFW Installer v" .. lucidversion)
print("Lucid will be installed to: " .. cfwroot)
print()
print("[Y/N] Do you want to continue?")
local answer = read()

if answer:lower() ~= "y" then
    print("Installation cancelled.")
    os.exit()
end

-- Remove old files
if fs.exists(cfwroot) then
    print("Removing old files...")
    fs.delete(cfwroot)
end

print("Creating directories...")
fs.makeDir(cfwroot)
fs.makeDir(cfwroot .. "/bios")
fs.makeDir(cfwroot .. "/apis")

local function downloadFile(url, path)
    local response = http.get(url)
    if response then
        local dir = fs.getDir(path)
        if not fs.exists(dir) then
            fs.makeDir(dir)
        end

        local file = fs.open(path, "wb")
        if not file then
            error("Failed to open file for writing: " .. path)
        end

        file.write(response.readAll())
        file.close()
        response.close()
    else
        error("Failed to download: " .. url .. ". Please check your internet connection.")
    end
end

local function copyRecursive(source, target)
    if fs.isDir(source) then
        fs.makeDir(target)
        local files = fs.list(source)
        for _, file in ipairs(files) do
            copyRecursive(fs.combine(source, file), fs.combine(target, file))
        end
    else
        local sourceFile = fs.open(source, "rb")
        if sourceFile then
            local targetFile = fs.open(target, "wb")
            if targetFile then
                targetFile.write(sourceFile.readAll())
                targetFile.close()
                print("Copied file: " .. source .. " to " .. target)
            else
                error("Failed to open target file for writing: " .. target)
            end
            sourceFile.close()
        else
            error("Failed to open source file for reading: " .. source)
        end
    end
end

local function editLine(filePath, lineNumber, newText)
    local file = fs.open(filePath, "r")
    if not file then
        error("Failed to open file for reading: " .. filePath)
    end
    local lines = {}
    for line in file.readLine do
        table.insert(lines, line)
    end
    file.close()
    if lineNumber < 1 or lineNumber > #lines then
        error("Line number out of range: " .. lineNumber)
    end
    lines[lineNumber] = newText
    file = fs.open(filePath, "w")
    if not file then
        error("Failed to open file for writing: " .. filePath)
    end
    for _, line in ipairs(lines) do
        file.writeLine(line)
    end
    file.close()
end

local function replaceAll(filePath, replace, with)
    if not fs.exists(filePath) then
        error("File not found: " .. filePath)
    end
    if fs.isDir(filePath) then return end

    local file = fs.open(filePath, "r")
    if not file then
        error("Failed to open file " .. filePath)
    end
    local content = file.readAll()
    file.close()

    local modified = content:gsub(replace, with)

    file = fs.open(filePath, "w")
    if not file then
        error("Failed to open file" .. filePath)
    end
    file.write(modified)
    file.close()
end

local function applyPatches(filePath)
    replaceAll(filePath, "bios.lua", "lucid/bios/lucid.lua")
end

local function patchBios(biosPath)
    local file = fs.open(biosPath, "r")
    local content = file.readAll()
    file.close()

    local modified = content:gsub("return \"CraftOS 1.9\"", "return \"Lucid v" .. lucidversion .. "\"")
    local modified = modified:gsub("-- Load APIs", "-- Load APIs\nload_apis(\"lucid/apis\")")
    local modified = modified:gsub("rom/", "lucid/rom/")

    local override = fs.open(biosPath, "w")
    override.write(modified)
    override.close()
end

local function patchPrograms()
    editLine("/lucid/rom/programs/lua.lua", 29, "-- rather than from /lucid/rom/programs. This makes it more friendly to use and closer")
    editLine("/lucid/rom/programs/shell.lua", 22, "    program has two aliases: `ls` and `dir`. When you write `ls /lucid/rom`, that's")
    editLine("/lucid/rom/programs/shell.lua", 23, "    expanded to `list /lucid/rom`.")
    editLine("/lucid/rom/programs/shell.lua", 30, "    shell now looks in `/lucid/rom/programs`, where `list.lua` can be found!")
    editLine("/lucid/rom/programs/shell.lua", 55, "local sPath = parentShell and parentShell.path() or \".:/lucid/rom/programs\"")
    editLine("/lucid/rom/programs/shell.lua", 70, "    local env = setmetatable(createShellEnv(\"/lucid/rom/programs\"), { __index = _ENV })")
    editLine("/lucid/rom/programs/shell.lua", 307, "-- `/lucid/rom/programs` and `/lucid/rom/programs/turtle` folder, making the path")
    editLine("/lucid/rom/programs/shell.lua", 308, "-- `.:/lucid/rom/programs:/lucid/rom/programs/turtle`.")
    editLine("/lucid/rom/programs/shell.lua", 313, "    return sPath:gsub(\"/rom\", \"/lucid/rom\")")
    editLine("/lucid/rom/programs/shell.lua", 743, "        shell.run(\"/lucid/rom/startup.lua\")")
    editLine("/lucid/rom/programs/advanced/multishell.lua", 303, "--     local id = multishell.launch({}, \"/lucid/rom/programs/fun/hello.lua\")")
    editLine("/lucid/rom/programs/advanced/multishell.lua", 329, "}, \"/lucid/rom/programs/shell.lua\")")

    editLine("/lucid/rom/programs/reboot.lua", 11, "")

    local startup = fs.open("/lucid/rom/startup.lua", "r")
    local startupc = startup.readAll()
    startup.close()

    local mstartup = startupc:gsub("rom/", "lucid/rom/")
    local startup = fs.open("/lucid/rom/startup.lua", "w+")

    startup.write(mstartup)
    startup.close()
end

local function downloadApis()
    for name, url in pairs(ApiUrl) do
        print("Downloading API: " .. name)
        downloadFile(url, cfwroot .. "/apis/" .. name .. ".lua")
    end
end

local function downloadPrograms()
    for name, url in pairs(ProgramUrl) do
        print("Downloading program: " .. name)
        downloadFile(url, cfwRom .. "/programs/" .. name .. ".lua")
    end
end

local romPath = "/rom"
if fs.exists(romPath) then
    print("Copying CraftOS ROM to /lucid...")
    copyRecursive(romPath, cfwRom)
else
    error("CraftOS ROM not found at: " .. romPath)
end

if fs.exists(unbiosPath) then
    print("Deleting existing unbios.lua...")
    fs.delete(unbiosPath)
end

print("Downloading BIOS...")
downloadFile(biosUrl, biosPath)

print("Downloading Unbios...")
downloadFile(unbiosUrl, unbiosPath)

print("Patching BIOS...")
patchBios(biosPath)

print("Patching Unbios...")
applyPatches(unbiosPath)

print("Patching programs")
patchPrograms()

print("Installing APIs")
downloadApis()

print("Installing programs")
downloadPrograms()

print("Writing startup script...")
local startupFile = fs.open("/startup.lua", "w+")
startupFile.write(startupText)
startupFile.close()

term.setTextColor(colors.green)
print("LucidCFW installation complete. Press enter to restart...")
read()
os.reboot()
