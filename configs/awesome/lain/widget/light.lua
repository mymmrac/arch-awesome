local helpers = require("lain.helpers")
local wibox   = require("wibox")
local string  = string

-- Light widget
-- lain.widget.light

local function factory(args)
    args           = args or {}
    local light     = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 25
    local settings = args.settings or function() end

    light.cmd          = args.cmd or "light"

    local format_cmd = string.format("%s -G", light.cmd)

    light.last = 0

    function light.update()
        helpers.async(format_cmd, function(brightness)
            local br = math.ceil(tonumber(brightness))
            if light.last ~= br then
                brightness_now = br
                widget = light.widget
                settings()
                light.last = brightness_now
            end
        end)
    end

    helpers.newtimer(string.format("light-%s", light.cmd), timeout, light.update)

    return light
end

return factory
