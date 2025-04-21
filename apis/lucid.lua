local lucid = _ENV -- The Lucid API is an exclusive API for the LucidCFW.

local boottime = os.clock() -- Get the boot time in seconds since the computer started.

lucid.validBootModes = { -- Every valid boot mode.
    "craftos",
    "lucid"
}

function lucid.getBootTime() -- Returns the boot time in seconds.
    return boottime
end

function lucid.setBootOverride(mode) -- Sets the boot override mode.
    if not settings or not lucid.validBootModes[mode] then return false end
    
    settings.set("lucidcfw.bootoverride", mode)
    settings.save()

    if settings.get("lucidcfw.bootoverride") ~= mode then return false end
end

function lucid.pause(message) -- Waits for a key press.
    print(message or "Press any key to continue...")
    os.pullEvent("key_up")
end

function lucid.popsound() -- Plays a "Pop!" sound.
    local sp = peripheral.find("speaker")
    
    if sp then
        if sp.playSound("minecraft:block.sniffer_egg.plop") then
            return true
        else
            return false
        end
    else
        return false
    end
end

return lucid -- Return the Lucid API.