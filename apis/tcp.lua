local net = _ENV

local sockets = {}
local listeners = {}

function net.getID()
    return os.getComputerID()
end

function net.listen(port, handler)
    listeners[port] = handler
end

function net.send(ip, port, data)
    local modem = peripheral.find("modem")
    modem.transmit(port, port, {
        src = net.getID(),
        dst = ip,
        port = port,
        type = "DATA",
        data = data
    })
end

function net._startListener()
    local modem = peripheral.find("modem")
    for port in pairs(listeners) do
        modem.open(port)
    end

    while true do
        local event, _, ch, _, msg = os.pullEvent("modem_message")
        if type(msg) == "table" and msg.dst == net.getID() and listeners[ch] then
            listeners[ch](msg)
        end
    end
end

-- optional: TCP-like Socket
function net.createSocket(ip, port)
    return {
        ip = ip,
        port = port,
        send = function(self, msg)
            net.send(self.ip, self.port, msg)
        end
    }
end

return net
