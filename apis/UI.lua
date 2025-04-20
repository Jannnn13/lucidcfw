local UI = _ENV

UI.components = {}
UI.monitor = nil
UI.monitorWidth = 0
UI.monitorHeight = 0

function UI.clear()
    UI.components = {}
end

function UI.setMonitor(m)
    if not m then return false end

    UI.monitor = m
    if m then
        UI.monitorWidth, UI.monitorHeight = m.getSize()
    end

    return true
end

function UI.add(comp)
    table.insert(UI.components, comp)
end

function UI.layout()
    local yCounter = 1

    for _, comp in ipairs(UI.components) do
        comp.width = comp.width or #comp.text or 10
        comp.height = comp.height or 1

        local hAlign = comp.align or "left"
        if hAlign == "center" then
            comp.x = math.floor((UI.monitorWidth - comp.width) / 2) + 1
        elseif hAlign == "right" then
            comp.x = UI.monitorWidth - comp.width + 1
        else
            comp.x = comp.x or 1
        end

        local vAlign = comp.valign or "top"
        if vAlign == "center" then
            comp.y = math.floor((UI.monitorHeight - comp.height) / 2) + yCounter
        elseif vAlign == "bottom" then
            comp.y = UI.monitorHeight - comp.height + yCounter
        else
            comp.y = comp.y or yCounter
        end

        yCounter = yCounter + 1
    end
end

function UI.drawAll()
    if not UI.setMonitor(peripheral.find("monitor")) then return end

    UI.monitor.setBackgroundColor(colors.black)
    UI.monitor.setTextColor(colors.white)
    UI.monitor.clear()

    UI.monitorWidth, UI.monitorHeight = UI.monitor.getSize()
    UI.layout()

    for _, comp in ipairs(UI.components) do
        if comp.draw then
            comp:draw(UI.monitor)
        end
    end
end

function UI.handleClick(x, y)
    for _, comp in ipairs(UI.components) do
        if comp.type == "button" and comp.onClick then
            if x >= comp.x and x < comp.x + comp.width and y == comp.y then
                comp.onClick()
            end
        end
    end
end

-- Component: Text
function UI.Text(text, opts)
    opts = opts or {}
    return {
        type = "text",
        text = text,
        align = opts.align or "left",
        valign = opts.valign or "top",
        color = opts.color or colors.white,
        draw = function(self, mon)
            mon.setCursorPos(self.x, self.y)
            mon.setTextColor(self.color)
            mon.write(self.text)
            mon.setTextColor(colors.white)
        end
    }
end

-- Component: Button
function UI.Button(text, opts)
    opts = opts or {}
    local width = opts.width or (#text + 4)
    return {
        type = "button",
        text = text,
        align = opts.align or "left",
        valign = opts.valign or "top",
        width = width,
        bg = opts.bg or colors.gray,
        color = opts.color or colors.black,
        onClick = opts.onClick,
        draw = function(self, mon)
            mon.setCursorPos(self.x, self.y)
            mon.setBackgroundColor(self.bg)
            mon.setTextColor(self.color)
            local padding = math.floor((self.width - #self.text) / 2)
            mon.write(string.rep(" ", padding) .. self.text .. string.rep(" ", self.width - padding - #self.text))
            mon.setTextColor(colors.white)
        end
    }
end

return UI
