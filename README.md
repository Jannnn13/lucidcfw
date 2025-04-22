# LucidCFW

LucidCFW is a custom BIOS and system for [CC:Tweaked](https://github.com/cc-tweaked/CC-Tweaked), designed to enhance and extend the functionality of the default CraftOS environment. It includes a modified BIOS, custom programs, and APIs, while maintaining compatibility with the original CraftOS.

---

## **Features**
- Custom BIOS (`lucid.lua`) based on the CC:Tweaked BIOS.
- Modified programs and APIs for extended functionality.
- Fully customizable and open-source.

---

## **Installation**

### **Requirements**
- [CC:Tweaked](https://github.com/cc-tweaked/CC-Tweaked) installed in your Minecraft world.
- HTTP API enabled in ComputerCraft.
- A disk drive with the required files (optional for custom programs/APIs).

### **Steps**
1. **Enable HTTP API**:
   Ensure the HTTP API is enabled in your `ComputerCraft` configuration file.

2. **Run the Installer**:
   Copy the `install.lua` script to your computer and execute it:
   ```bash
   wget run https://raw.githubusercontent.com/Jannnn13/lucidcfw/refs/heads/main/install.lua
   ```

3. **Follow the Prompts**:
   - The installer will download the required files, patch them, and set up the LucidCFW environment.
   - Confirm the installation when prompted.

4. **Restart the Computer**:
   After the installation is complete, press `Enter` to restart the computer and boot into LucidCFW.

---

## **File Structure**
After installation, the following file structure will be created:
```
/lucid
├── bios
│   ├── lucid.lua       # Custom BIOS
│   ├── unbios.lua      # Custom BIOS Loader
├── rom
|   ├── Some stuff...   # Default BIOS
├── apis # Lucid APIs
├── programs # Lucid Programs
/startup.lua            # Startup script for LucidCFW
```

---

## **Customization**
You can modify the following files to customize LucidCFW:
- `/lucid/bios/lucid.lua`: The main BIOS file.
- `/lucid/rom/programs`: Add or modify programs.
- `/lucid/rom/apis`: Add or modify APIs.

---

## **Troubleshooting**

### **Common Issues**
1. **HTTP API Disabled**:
   - Ensure `http.enabled=true` is set in the `ComputerCraft` configuration file.

2. **"File not found" Errors**:
   - Check your internet connection.
   - Ensure the URLs in the installer script are correct.

3. **"Too long without yielding" Errors**:
   - This may occur if the system is overloaded. Restart the computer and try again.

---

## **Credits**
- **[CC:Tweaked Team](https://github.com/cc-tweaked/CC-Tweaked)**: Original CraftOS and BIOS.
- **[MCJack123](https://gist.github.com/MCJack123)**: Author of `unbios.lua`.
- **[Jannnn13](https://github.com/Jannnn13)** and **[Miko0187](https://github.com/Miko0187)**: Authors of LucidCFW.

---

## **License**
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

<img src="https://raw.githubusercontent.com/Jannnn13/Jannnn13/output/snake.svg" alt="Snake animation" />
