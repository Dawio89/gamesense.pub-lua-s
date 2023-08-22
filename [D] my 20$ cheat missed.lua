local http = require('gamesense/http')
local WEBHOOK_URL = ''
local hitgroup_names = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}
local urn = "Dawio89"
local shots = {}

local function aim_fire(e)
  shots[e.id] = e;
end

client.set_event_callback('aim_fire', aim_fire)

local function aim_hit(e)
  shots[e.id] = nil
end

client.set_event_callback('aim_hit', aim_hit)

local function aim_miss(e)
  local shot = shots[e.id];
  shots[e.id] = nil;

  local group = hitgroup_names[e.hitgroup + 1] or '?'
  local body = {
    content = string.format(
      "**["..urn.."]** Missed %s | [hc] %d | [bt] %d | [hg] %s | [dmg] %d | missed due to: %s",
      entity.get_player_name(e.target), math.floor(e.hit_chance + 0.5), shot.backtrack, group, shot.damage, e.reason
    )
  }
  http.post(WEBHOOK_URL, { body = json.stringify(body), headers = { ['Content-Length'] = #json.stringify(body), ['Content-Type'] = 'application/json' } }, function() end)
end

client.set_event_callback('aim_miss', aim_miss)
