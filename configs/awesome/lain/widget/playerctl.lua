local helpers     = require("lain.helpers")
local wibox       = require("wibox")

-- Playerctl widget
-- lain.widget.playerctl

-- ================== WIP ========================

local function factory(args)
    args           = args or {}

    local playerctl  = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 8
    local settings = args.settings or function() end

    playerctl.last = {}

    function playerctl.update()
        helpers.async("playerctl metadata", function(metadata)
            local l,s = string.match(mixer, "xesam:artist")
            if playerctl.last.title ~= title or playerctl.last.artist ~= artist then


                widget = playerctl.widget
                settings()
            end
        end)
    end

    helpers.newtimer("sysload", timeout, playerctl.update)

    return playerctl
end

return factory
