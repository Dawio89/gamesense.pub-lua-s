--omg crash no way
--lua tab -> A -> Nazi crosshair

local vector = require 'vector';

local screenWidth, screenHeight = client.screen_size()
local screen = vector(screenWidth, screenHeight, nil)
local Middle = vector(screen.x * .5, screen.y * .5, nil)
local rotation = 0

local crosshairEnable = ui.new_checkbox("Lua", "A", "Nazi crosshair")
local crosshairColor = ui.new_color_picker("Lua", "A", "Nazi crosshair color", 200, 200, 200, 255)
local crosshairRainbow = ui.new_checkbox("Lua", "A", "Nazi crosshair rainbow")

local function BOG_TO_GRD(BOG)
    return (180 / math.pi) * BOG
end

local function GRD_TO_BOG(GRD)
    return (math.pi / 180) * GRD
end

local function SwastikaCrosshair()
    pLocal = entity.get_local_player()
    if not pLocal then return end

    if ui.get(crosshairEnable) then
        local crosshairColorRed, crosshairColorGreen, crosshairColorBlue = ui.get(crosshairColor)

            if rotation < 90 then 
                rotation = rotation + 1
            end
            if rotation > 89 then
                rotation = 0
            end

        local a = math.floor(screen.y / 2 / 30)
        local gamma = math.atan(a / a)
        
        for i = 0, 3 do
            local p = {}
            table.insert(p, a * math.sin(GRD_TO_BOG(rotation + (i * 90))))
            table.insert(p, a * math.cos(GRD_TO_BOG(rotation + (i * 90))))
            table.insert(p, (a / math.cos(gamma)) * math.sin(GRD_TO_BOG(rotation + (i * 90) + BOG_TO_GRD(gamma))))
            table.insert(p, (a / math.cos(gamma)) * math.cos(GRD_TO_BOG(rotation + (i * 90) + BOG_TO_GRD(gamma))))
            if not ui.get(crosshairRainbow) then
                renderer.line(Middle.x, Middle.y, Middle.x + p[1], Middle.y - p[2], crosshairColorRed, crosshairColorGreen, crosshairColorBlue, 255)
                renderer.line(Middle.x + p[1], Middle.y - p[2], Middle.x + p[3], Middle.y - p[4], crosshairColorRed, crosshairColorGreen, crosshairColorBlue, 255)
            else
                r = math.floor(math.sin(globals.realtime() * 2) * 127 + 128)
                g = math.floor(math.sin(globals.realtime() * 2 + 2) * 127 + 128)
                b = math.floor(math.sin(globals.realtime() * 2 + 4) * 127 + 128)
                renderer.line(Middle.x, Middle.y, Middle.x + p[1], Middle.y - p[2], r, g, b, 255)
                renderer.line(Middle.x + p[1], Middle.y - p[2], Middle.x + p[3], Middle.y - p[4], r, g, b, 255)
            end
        end
    end
end



client.set_event_callback("paint",
    SwastikaCrosshair
)
