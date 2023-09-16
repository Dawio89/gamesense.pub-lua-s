-- local variables for API functions. any changes to the line below will be lost on re-generation
local client_screen_size, client_set_event_callback, client_userid_to_entindex, entity_get_local_player, entity_get_player_name, entity_get_prop, globals_curtime, globals_realtime, math_floor, math_min, math_sin, renderer_gradient, renderer_measure_text, renderer_text, table_remove, ipairs, table_insert, ui_get, ui_new_checkbox, ui_new_color_picker, ui_new_label, ui_new_slider, ui_set_callback, ui_set_visible = client.screen_size, client.set_event_callback, client.userid_to_entindex, entity.get_local_player, entity.get_player_name, entity.get_prop, globals.curtime, globals.realtime, math.floor, math.min, math.sin, renderer.gradient, renderer.measure_text, renderer.text, table.remove, ipairs, table.insert, ui.get, ui.new_checkbox, ui.new_color_picker, ui.new_label, ui.new_slider, ui.set_callback, ui.set_visible

--pasted from : https://gamesense.pub/forums/viewtopic.php?id=38289

local images = require "gamesense/images"

local tab, container = "LUA", "B"

local gui = {
    main = ui_new_checkbox(tab, container, "activate killfeed"),
    text1 = ui_new_label(tab, container, "accent"),
    accent = ui_new_color_picker(tab, container, "\n", 227, 181, 255, 155),
    text2 = ui_new_label(tab, container, "ct color"),
    ct_color = ui_new_color_picker(tab, container, "\n\n\n", 204, 204, 255, 155),
    text3 = ui_new_label(tab, container, "t color"),
    t_color = ui_new_color_picker(tab, container, "\n\n\n\n", 255, 204, 204, 155),
    box_scale = ui_new_slider(tab, container, "box scale", 0, 100, 100, true, "%", 1, nil),
    max_logs = ui_new_slider(tab, container, "max logs", 4, 20, 0, true, "", 1, {[4] = "∞"}),
    max_time = ui_new_slider(tab, container, "max time", 0, 30, 0, true, "s", 1, {[0] = "∞"})
}

local cl_drawhud_force_deathnotices = cvar.cl_drawhud_force_deathnotices

local function set_visible()

    local main = ui_get(gui.main)

    ui_set_visible(gui.accent, false)
    ui_set_visible(gui.ct_color, main)
    ui_set_visible(gui.t_color, main)
    ui_set_visible(gui.text1, false)
    ui_set_visible(gui.text2, main)
    ui_set_visible(gui.text3, main)
    ui_set_visible(gui.box_scale, false)
    ui_set_visible(gui.max_logs, main)
    ui_set_visible(gui.max_time, main)

    cl_drawhud_force_deathnotices:set_int(main and -1 or 0)

end

set_visible()

ui_set_callback(gui.main, set_visible)

local data = {
    logs = {}
}

local hud_scaling = cvar.hud_scaling
local safezonex = cvar.safezonex
local safezoney = cvar.safezoney

client_set_event_callback("player_death", function(e)

    local me = entity_get_local_player()
    local attacker = client_userid_to_entindex(e.attacker)
    local target = client_userid_to_entindex(e.userid)

    if attacker ~= me and target ~= me then
        return
    end

    table_insert(data.logs, {
        attacker = entity_get_player_name(attacker),
        target = entity_get_player_name(target),
        hs = e.headshot,
        assister = entity_get_player_name(client_userid_to_entindex(e.assister)),
        penetrated = e.penetrated,
        noscope = e.noscope,
        weapon = "weapon_" .. e.weapon,
        time = globals_curtime(),
        teams = {
            entity_get_prop(target, "m_iTeamNum"),
            entity_get_prop(attacker, "m_iTeamNum")
        }
    })

end)

client_set_event_callback("paint", function()

    if not ui_get(gui.main) then
        return
    end

    local me = entity_get_local_player()
    local x, y = client_screen_size()
    local scale = 0.6
    local max_logs = ui_get(gui.max_logs)
    local max_time = ui_get(gui.max_time)
    local r, g, b, a = ui_get(gui.accent)

    local safezone = {
        x = safezonex:get_float(),
        y = safezoney:get_float()
    }

    local padding = {
        x = -20,
        y = 40
    }

    local xoffset = 20

    local headshot_image = images.get_panorama_image("hud/deathnotice/icon_headshot.svg")
    local wallbang_image = images.get_panorama_image("hud/deathnotice/penetrate.svg")
    local noscope_image = images.get_panorama_image("hud/deathnotice/noscope.svg")
    local suicide_image = images.get_panorama_image("hud/deathnotice/icon_suicide.svg")
   
    for i, shot in ipairs(data.logs) do

        local alpha = math_min((globals_curtime() - shot.time)/(max_time / 5),1)

        if max_time == 0 then
            alpha = math_min((globals_curtime() - shot.time)*2,1)
        end

        xoffset = xoffset + 18 * alpha * ui_get(gui.box_scale) / 50 + 20

        local attacker_string = shot.attacker .. ((shot.assister == "unknown") and "" or (" + " .. shot.assister))
        local attacker_size = renderer_measure_text("r+", attacker_string)
        local size = attacker_size + 8

        if shot.hs then
            local w, h = headshot_image:measure()
            size = size + w*scale
        end

        if shot.penetrated > 0 then
            local w, h = wallbang_image:measure()
            size = size + w*scale
        end

        if shot.noscope then
            local w, h = noscope_image:measure()
            size = size + w * scale 
        end

        if shot.target == shot.attacker then
            local w, h = suicide_image:measure()
            size = size + w*scale
        else
            local weapon_icon = images.get_weapon_icon(shot.weapon)
            local w, h = weapon_icon:measure()
            size = size + w*scale + 8
        end

        local target_size = renderer_measure_text("r+", shot.target)

        size = size + target_size + 8

        lr = math_floor(math_sin(globals_realtime() * 2) * 127 + 128)
        lg = math_floor(math_sin(globals_realtime() * 2 + 2) * 127 + 128)
        lb = math_floor(math_sin(globals_realtime() * 2 + 4) * 127 + 128)
        rr = 255 - lr 
        rg = 255 - lg
        rb = 255 - lb

        renderer_gradient(x/2 + (x/2 * safezone.x) + padding.x - (size * alpha * ui_get(gui.box_scale)/100)-30, y/2 * (1 - safezone.y) + padding.y - 2 + xoffset, size * alpha * ui_get(gui.box_scale)/50, 36, lr, lg, lb, a, rr, rg, rb, a, true)
        renderer_gradient(x/2 + (x/2 * safezone.x) + padding.x - (size * alpha * ui_get(gui.box_scale)/100)-27, y/2 * (1 - safezone.y) + padding.y - 2 + xoffset + 3, size * alpha * ui_get(gui.box_scale)/50 - 9, 30, 0, 0, 0, 75, 0, 0, 0, 75, true)

        local offset = 10

        local r, g, b, a = 200, 200, 200, 255

        if shot.teams[1] == 3 then -- ct
            r, g, b, a = ui_get(gui.ct_color)
        elseif shot.teams[1] == 2 then
            r, g, b, a = ui_get(gui.t_color)
        end

        renderer_text(x/2 + (x/2 * safezone.x+20) + padding.x - offset, y/2 * (1 - safezone.y) + padding.y + xoffset, r, g, b, a * alpha, "r+", 0, shot.target)

        offset = offset + 2

        if shot.hs then
            local w, h = headshot_image:measure()
            headshot_image:draw(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - w*scale, y/2 * (1 - safezone.y) + padding.y + xoffset +5, w*scale, h*scale , 255, 255, 255, 255 * alpha, true)
            offset = offset + w*scale
        end

        if shot.penetrated > 0 then
            local w, h = wallbang_image:measure()
            wallbang_image:draw(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - w*scale, y/2 * (1 - safezone.y) + padding.y + xoffset +5, w*scale, h*scale , 255, 255, 255, 255 * alpha, true)
            offset = offset + w*scale
        end

        if shot.noscope then
            local w, h = noscope_image:measure()
            noscope_image:draw(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - w*scale, y/2 * (1 - safezone.y) + padding.y + xoffset +5, w*scale, h*scale , 255, 255, 255, 255 * alpha, true)
            offset = offset + w*scale
        end

        if shot.target == shot.attacker then
            local w, h = suicide_image:measure()
            suicide_image:draw(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - w*scale, y/2 * (1 - safezone.y) + padding.y + xoffset +5, w*scale, h*scale , 255, 255, 255, 255 * alpha, true)
            offset = offset + w*scale + 2
        else

            local weapon_icon = images.get_weapon_icon(shot.weapon)
            local w, h = weapon_icon:measure()
            weapon_icon:draw(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - w*scale, y/2 * (1 - safezone.y) + padding.y + xoffset +5, w*scale, h*scale , 255, 255, 255, 255 * alpha, true)
            offset = offset + w*scale + 4
        end

        if shot.teams[2] == 3 then -- ct
            r, g, b, a = ui_get(gui.ct_color)
        elseif shot.teams[2] == 2 then
            r, g, b, a = ui_get(gui.t_color)
        end

        renderer_text(x/2 + (x/2 * safezone.x+5) + padding.x - offset - target_size - 15 , y/2 * (1 - safezone.y) + padding.y + xoffset, r, g, b, a * alpha, "r+", 0, attacker_string)

        if max_logs ~= 4 and #data.logs > max_logs then
            table_remove(data.logs, i)
        end

        if max_time ~= 0 and shot.time + max_time - globals_curtime() <= 0 then
            table_remove(data.logs, i)
        end
    end
end)

client_set_event_callback("round_start", function()
    data.logs = {}
end)
