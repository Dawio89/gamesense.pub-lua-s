-- are you dealing with constant mental issues and low attention span? no problem
local gif = require("gamesense/gif_decoder")

local subwaySerfers = ui.new_checkbox("Lua", "A", "Subway Serfers")
local subwayGif = gif.load_gif(readfile("lua/subway.gif") or error("Couldn't find subway.gif")) -- https://media.tenor.com/1wZ88hrB5SwAAAAd/subway-surfer.gif
local startTime = globals.realtime()

client.set_event_callback("paint_ui", function()
    if ui.get(subwaySerfers) then
        subwayGif:draw(globals.realtime()-startTime, subwayGif.width, subwayGif.height-200, subwayGif.width*2, subwayGif.height*2, 255, 255, 255, 255)
    end
end)
