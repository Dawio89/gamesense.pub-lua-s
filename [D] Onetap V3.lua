--Found this somewhere recently, its not finished but maybe someone will find some use for this
local vector = require "vector"
local surface = require "gamesense/surface"

local screenWidth, screenHeight = client.screen_size()
local screen = vector(screenWidth, screenHeight, nil)
local screenHalf = screen * 0.5
local menuOffset = vector(500, 500)
local verdanaBold30 = surface.create_font("Verdana Bold", 28, 1, 0x010)
local verdanaBold15 = surface.create_font("Arial Bold", 15, 2, 0x010)
local verdana15 = surface.create_font("Verdana", 15, 1, 0x010)

local menuToggle = ui.new_checkbox("LUA", "A", "Onetap v3 menu")
local menuBind = ui.new_hotkey("LUA", "A", "Onetap v3 menu", true, 0x2E)
local watermarkToggle = ui.new_checkbox("LUA", "A", "Onetap v3 watermark")

local posX = ui.new_slider("LUA", "A", "OTv3 pos X", 0, screen.x, screenHalf.x-290, false, "px", screen.x, nil)
local posY = ui.new_slider("LUA", "A", "OTv3 pos Y", 0, screen.y, screenHalf.y-235, false, "px", screen.y, nil)

local sliderStates = {}
local checkboxStates = {}

local width = 580
local height = 470

local setPosX = 0
local setPosY = 0

local isMouseDown = false
local initialMousePos = vector(0)
local mousePos = vector()

local date = nil
local tickrate = 0
local delay = 0
local ip = nil
local username = "fiiil" -- placeholder

local function isMouseWithinBounds()
    local mousePos = vector(ui.mouse_position())
    return mousePos.x >= ui.get(posX) and mousePos.x <= ui.get(posX) + width and
        mousePos.y >= ui.get(posY) and mousePos.y <= ui.get(posY) + height
end

local function isMouseWithinCheckbox(x, y)
    local mousePos = vector(ui.mouse_position())
    return mousePos.x >= x and mousePos.x <= x + 12 and
        mousePos.y >= y and mousePos.y <= y + 12
end

local function isMouseButtonDown()
    if client.key_state(0x01) then
        isMouseDown = true
        initialMousePos = ui.mouse_position()
    else
        isMouseDown = false
    end

    return client.key_state(0x01) or isMouseDown
end

local function updatePos()
    if isMouseButtonDown() and isMouseWithinBounds() then
        local mousePos = vector(ui.mouse_position())
        if not dragging then
            dragging = true
            mouseOffsetX = vector(ui.mouse_position()).x - ui.get(posX)
            mouseOffsetY = vector(ui.mouse_position()).y - ui.get(posY)
        end
        -- setPosX = mousePos.x - mouseOffsetX

        -- if setPosX ~= nil and setPosX >= screen.x then
        --     setPosX = screen.x
        -- elseif setPoxX <= 0 then
        --     setPosX = 0
        -- end

        -- setPosY = mousePos.y - mouseOffsetY

        -- if setPosY ~= nil and setPosY >= screen.y then
        --     setPosY = screen.y
        -- elseif setPoxY <= 0 then
        --     setPosY = 0
        -- end

        ui.set(posX, mousePos.x - mouseOffsetX)
        ui.set(posY, mousePos.y - mouseOffsetY)
    else
        dragging = false
    end
end

local function OTv3Checkbox(x, y, text)
    if not checkboxStates[x] then
        checkboxStates[x] = {}
    end

    if not checkboxStates[x][y] then
        checkboxStates[x][y] = {
            state = false,
            lastMouseState = false
        }
    end

    local checkbox = checkboxStates[x][y]

    local isMousePressed = isMouseButtonDown()
    local isCheckboxActive = isMouseWithinCheckbox(x, y)
    surface.draw_text(x + 20, y - 1, 214, 217, 224, 255, verdana15, text)

    if isCheckboxActive then
        surface.draw_filled_rect(x, y, 12, 12, 62, 66, 74, 255)
        surface.draw_outlined_rect(x, y, 12, 12, 55, 59, 66, 255)

        if not isMousePressed and checkbox.lastMouseState then
            checkbox.state = not checkbox.state
        end
    else
        surface.draw_filled_rect(x, y, 12, 12, 31, 33, 37, 255)
        surface.draw_outlined_rect(x, y, 12, 12, 55, 59, 66, 255)
    end

    if checkbox.state then
        surface.draw_filled_rect(x, y, 12, 12, 220, 165, 91, 255)
        surface.draw_outlined_rect(x, y, 12, 12, 55, 59, 66, 255)
    end

    checkbox.lastMouseState = isMousePressed
end

local function isMouseWithinSlider(x, y, width)
    local mousePos = vector(ui.mouse_position())
    return mousePos.x >= x and mousePos.x <= x + width and
        mousePos.y >= y and mousePos.y <= y + 12
end

local function OTv3Slider(x, y, text, value, minValue, maxValue, width)

    if not sliderStates[x] then
        sliderStates[x] = {}
    end

    if not sliderStates[x][y] then
        sliderStates[x][y] = {
            value = value,
            minValue = minValue,
            maxValue = maxValue,
            isDragging = false
        }
    end

    local slider = sliderStates[x][y]

    local isMousePressed = isMouseButtonDown()
    local isSliderActive = isMouseWithinSlider(x, y, width)
    surface.draw_text(x + 5, y - 18, 214, 217, 224, 255, verdana15, text)

    if isSliderActive then
        surface.draw_filled_rect(x, y, width, 8, 62, 66, 74, 255)
        surface.draw_outlined_rect(x, y, width, 8, 55, 59, 66, 255)

        if isMousePressed and not slider.isDragging then
            slider.isDragging = true
            dragging = false
        end

        if slider.isDragging then
            local mouseX = vector(ui.mouse_position()).x
            local normalizedValue = (mouseX - x) / width
            slider.value = math.max(minValue, math.min(maxValue, normalizedValue * (maxValue - minValue) + minValue))
        end
    else
        surface.draw_filled_rect(x, y, width, 8, 31, 33, 37, 255)
        surface.draw_outlined_rect(x, y, width, 8, 55, 59, 66, 255)
    end

    if slider.value then
        local sliderWidth = width * (slider.value - minValue) / (maxValue - minValue)
        surface.draw_filled_rect(x, y, sliderWidth, 8, 220, 165, 91, 255)
        surface.draw_outlined_rect(x, y, width, 8, 55, 59, 66, 255)
    end

    if not isMousePressed then
        slider.isDragging = false
    end
end


local function OTv3Menu()
    --if ui.get(menuToggle) and ui.get(menuBind) then

        updatePos()

        menuPositionX = ui.get(posX)
        menuPositionY = ui.get(posY)

        surface.draw_filled_rect(menuPositionX, menuPositionY, 580, 470, 44, 48, 55, 255) -- background

        surface.draw_outlined_rect(menuPositionX, menuPositionY, 580, 470, 31, 33, 37, 255) -- frame1
        surface.draw_outlined_rect(menuPositionX+1, menuPositionY+1, 578, 468, 72, 75, 82, 255) -- frame2

        surface.draw_filled_rect(menuPositionX+1, menuPositionY, 578, 8, 220, 165, 91, 255) -- top orange line
        renderer.gradient(menuPositionX+1, menuPositionY, 578, 20, 220, 165, 91, 100, 220, 165, 91, 1, false) -- top orange line fade

        surface.draw_line(menuPositionX+85, menuPositionY+55, menuPositionX+85, menuPositionY+20, 55, 59, 66, 255) -- otc line
        surface.draw_line(menuPositionX+15, menuPositionY+70, menuPositionX+565, menuPositionY+70, 55, 59, 66, 255) --top line

        surface.draw_filled_rect(menuPositionX+18, menuPositionY+80, 543, 50, 31, 33, 37, 255) -- weapons
        surface.draw_outlined_rect(menuPositionX+19, menuPositionY+81, 541, 48, 37, 39, 44, 255) -- inline weapons

        surface.draw_outlined_rect(menuPositionX+19, menuPositionY+145, 260, 87, 55, 59, 66, 255) -- general box
        surface.draw_line(menuPositionX+19, menuPositionY+145, menuPositionX+278, menuPositionY+145, 220, 165, 91, 255) -- general box orange line

        surface.draw_outlined_rect(menuPositionX+19, menuPositionY+252, 260, 74, 55, 59, 66, 255) -- trigger box
        surface.draw_line(menuPositionX+19, menuPositionY+252, menuPositionX+278, menuPositionY+252, 220, 165, 91, 255) -- trigger box orange line

        surface.draw_outlined_rect(menuPositionX+19, menuPositionY+346, 260, 87, 55, 59, 66, 255) -- backtrack box
        surface.draw_line(menuPositionX+19, menuPositionY+346, menuPositionX+278, menuPositionY+346, 220, 165, 91, 255) -- backtrack box orange line

        surface.draw_outlined_rect(menuPositionX+300, menuPositionY+145, 260, 288, 55, 59, 66, 255) -- default config box
        surface.draw_line(menuPositionX+300, menuPositionY+145, menuPositionX+559, menuPositionY+145, 220, 165, 91, 255) -- default config box orange line

        surface.draw_line(menuPositionX+15, menuPositionY+445, menuPositionX+565, menuPositionY+445, 55, 59, 66, 255) -- bottom line


        surface.draw_filled_rect(menuPositionX+100, menuPositionY+26, 90, 26, 31, 33, 37, 255) -- legit tab


        ---- texts ----
        --renderer.text(menuPositionX+25, menuPositionY+22, 214, 217, 224, 255, "+", 0, "otc3")
        surface.draw_text(menuPositionX+21, menuPositionY+24, 214, 217, 224, 255, verdanaBold30, "otc3")

        surface.draw_text(menuPositionX+130, menuPositionY+32, 214, 217, 224, 255, verdanaBold15, "Legit")
        surface.draw_text(menuPositionX+225, menuPositionY+32, 214, 217, 224, 255, verdanaBold15, "Rage")
        surface.draw_text(menuPositionX+320, menuPositionY+32, 214, 217, 224, 255, verdanaBold15, "Anti-Aim")
        surface.draw_text(menuPositionX+415, menuPositionY+32, 214, 217, 224, 255, verdanaBold15, "Visual")
        surface.draw_text(menuPositionX+510, menuPositionY+32, 214, 217, 224, 255, verdanaBold15, "Misc")

        surface.draw_filled_rect(menuPositionX+125, menuPositionY+135, 60, 15, 44, 48, 55, 255) -- general box
        surface.draw_text(menuPositionX+130, menuPositionY+137, 214, 217, 224, 255, verdana15, "General")

        surface.draw_filled_rect(menuPositionX+117, menuPositionY+242, 77, 15, 44, 48, 55, 255) -- trigger box
        surface.draw_text(menuPositionX+122, menuPositionY+244, 214, 217, 224, 255, verdana15, "Triggerbot")

        surface.draw_filled_rect(menuPositionX+111, menuPositionY+336, 90, 15, 44, 48, 55, 255) -- backtrack box
        surface.draw_text(menuPositionX+116, menuPositionY+338, 214, 217, 224, 255, verdana15, "Backtracking")

        surface.draw_filled_rect(menuPositionX+385, menuPositionY+135, 97, 15, 44, 48, 55, 255) -- default config box
        surface.draw_text(menuPositionX+390, menuPositionY+137, 214, 217, 224, 255, verdana15, "Default config")

        ---- buttons ----

        OTv3Checkbox(menuPositionX+30, menuPositionY+170, "Enabled") -- general button
        OTv3Slider(menuPositionX+45, menuPositionY+210, "Reaction time", 1, 0, 100, 210)

        OTv3Checkbox(menuPositionX+30, menuPositionY+278, "Enabled") -- triggerbot buttons
        OTv3Checkbox(menuPositionX+30, menuPositionY+302, "Magnet") -- triggerbot buttons

        OTv3Checkbox(menuPositionX+30, menuPositionY+372, "Enabled") -- backtracking buttons
        OTv3Slider(menuPositionX+45, menuPositionY+412, "Maximum time", 1, 0, 100, 210)

        surface.draw_text(menuPositionX+20, menuPositionY+450, 214, 217, 224, 255, verdana15, "fiiil") -- username placeholder
    --end

    if ui.get(watermarkToggle) then
        local hours, minutes, seconds = client.system_time()
        local date = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        local delay = math.floor(client.latency()*1000+.5)
        local tickrate = 1/globals.tickinterval()
        local ip = "0.0.0.0"
        local margin, padding = 20, 5

        local watermarkText = "otc3 | "..username.." | "..ip.." | delay: "..delay.."ms | "..tickrate.."tick | "..date
        
        local textWidth, textHeight = renderer.measure_text("b", watermarkText)

        surface.draw_filled_rect(screen.x-textWidth-margin-padding, margin-padding, textWidth+padding*2, textHeight+padding*2, 25, 25, 25, 150)
        surface.draw_filled_rect(screen.x-textWidth-margin-padding, margin-padding, textWidth+padding*2, 3, 220, 165, 91, 255)
        renderer.text(screenWidth-textWidth-margin, margin, 255,255,255,255, "b", 0, watermarkText)
    end
end



client.set_event_callback("paint",
    OTv3Menu
)
