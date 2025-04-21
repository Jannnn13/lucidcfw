if not lucid then
    printError("This system is not running LucidCFW.")
    return
end

if lucid.setBootOverride("craftos") then
    print("Rebooting to CraftOS...")
    sleep(1)
    os.reboot()
else
    printError("Cant set boot override to CraftOS.")
    return
end