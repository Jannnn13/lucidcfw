local setting = "lucidcfw.bootoverride"

if not settings then
    printError("Cannot access the settings API.")
    return
end

if not settings.get(setting) == "craftos" then
    settings.set(setting, "craftos")
    settings.save()
end

if not settings.get(setting) == "craftos" then
    printError("Cannot access the settings API.")
    return
else
    os.reboot()
end