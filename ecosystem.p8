pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- piconoc ecosystem
-- by cameron goble
-- an implementation of "nature of code"
-- by daniel schiffman which
-- simulates life-like behaviors in
-- emergent ways

-- see piconoc.p8 for descriptions and
-- commentary on custom functions

-- *** the challenge: ***
-- Imagine a population of computational
-- creatures swimming around a digital pond,
-- interacting with each other according to
-- various rules.
-- Develop a set of rules for simulating
-- the real-world behavior of a creature,
-- such as a nervous fly, swimming fish,
-- hopping bunny, slithering snake, etc.
-- Can you control the object's motion by
-- only manipulating the acceleration? Try
-- to give the creature a personality
-- through its behavior (rather than
-- through its visual design).

-->8
-- main loop

#include libs/ecs.lua
#include libs/1-vectors.lua
#include libs/2-forces.lua
-- Challenge 2: Incorporate the concept of forces
-- into your ecosystem. Try introducing other
-- elements into the environment (food, a predator)
-- for the creature to interact with. Does the
-- creature experience attraction or repulsion to
-- things in its world? Can you think more
-- abstractly and design forces based on the
-- creature’s desires or goals?
#include libs/debug.lua

function _init()
 sw, sh = 128,128
 dir_vecs={
   u=create_vector(0,-1),
   d=create_vector(0,1),
   l=create_vector(-1,0),
   r=create_vector(1,0),
   stationary=create_vector(0,0),
   ul=create_vector(-1,-1),
   dl=create_vector(-1,1),
   ur=create_vector(1,-1),
   dr=create_vector(1,1)
 }
 -- a table of directions rotating in sync with pico-8's anticlockwise trig functions:
 -- makes % math easier when changing directions
 dir={"r", "ur", "u", "ul", "l", "dl", "d", "dr"}
 captions = {txt_lines={}, color = 7}
 init_world()
end

function _update()
 update_world()
end

function _draw()
 cls()
 draw_world()
 draw_captions()
end

-->8
-- ecs functions and systems

function init_world()
 world = {}
 origin = {pos = create_vector(0,0)}
 center = {pos = create_vector(sw/2, sh/2)}
 add(world, origin)
 add(world, center)
 -- populate world with critters
 spawn_fly(10)
 spawn_frog(1)
end


function add_caption(txt)
 -- here adds a line of text for display during an event
 -- more default functionality could go here, like
 -- default time-to-live or colors.
 add(captions.txt_lines, txt)
end

function draw_captions()
 local n = #captions.txt_lines
 local fh = 6 --font height
 local y = 128 - (n*fh)
 for i = 1,n do
  print(captions.txt_lines[i], 1, y, captions.color)
  y += fh
 end
end


function update_world()
 reset_acceleration(world)
 update_selves(world)
 qualia_cache = cache_qualia(world)
 enact_qualia(world, qualia_cache)
 resolve_velocity(world)
 resolve_position(world)
end

function draw_world()
 draw_position(world)
end



-->8
-- ecs update and draw systems

-- draw each critter according to its particulars
draw_position = system({"pos"},
function(e)
 if (e.visible) then
  if e.draw then
   e:draw()
  else
   pset(e.pos.x, e.pos.y, 11)
  end
 end
end
)

-- Allows for particular update conditions per critter
update_selves = system({"update"},
function(e)
 e:update()
end
)

-- add object velocities to positions
-- adjust for screen boundary encounters
-- note: creatures have different behaviors against the boundary
resolve_position = system({"pos", "vel"},
function(e)
 e.pos:add_vector(e.vel)
 local b = e.boundary_behavior or "none"
 if type(b) == "string" then
  if b=="wrap" then
   _wrap(e)
  elseif b=="bounce" then
   _bounce(e)
  elseif b=="bonk" then
   _bonk(e)
  end
 elseif type(b) == "function" then
  b(e)
 end
end
)

function _bounce(e)
 -- reflect perfectly back along the relevant axis
  local s = e.sfx.boundary or {}
 if (e.pos.x >= sw-1 or e.pos.x <= 1) then
  e.vel.x *= -1
  e.pos.x = mid(1,e.pos.x,sw-1)
  play_psfx(s)
 end
 if (e.pos.y >= sh-1 or e.pos.y <= 1) then
  e.vel.y *= -1
  e.pos.y = mid(1,e.pos.y,sh-1)
  play_psfx(s)
 end
end

function _wrap(e)
 -- pass through the edge
  local s = e.sfx.boundary or {}
 if (e.pos.x >= sw-1) then e.pos.x = 1 play_psfx(s) end
 if (e.pos.x <= 1) then e.pos.x = sw-1 play_psfx(s) end
 if (e.pos.y >= sh-1) then e.pos.y = 1 play_psfx(s) end
 if (e.pos.y <= 1) then e.pos.y = sh-1 play_psfx(s) end
end

function _bonk(e)
 -- no passage, just stop right there
  local s = e.sfx.boundary or {}
 if (e.pos.x >= sw-1) or (e.pos.x <= 1) or (e.pos.y >= sh-1) or (e.pos.y <= 1) then
  play_psfx(s)
  e.pos.x = mid(1,e.pos.x,sw-1)
  e.pos.y = mid(1,e.pos.y,sh-1)
 end
end

-- add object accelerations to velocities
resolve_velocity = system({"vel", "acc"},
function(e)
 e.vel:add_vector(e.acc)
 if e.maxspeed then e.vel:limit(e.maxspeed) end
end
)

reset_acceleration = system({"acc"},
function(e)
 e.acc:scale_vector(0)
end
)

-->8
-- animal definitions and behavior

-- spawn_fly(n) to add n flies to the world
#include animals/housefly.lua

--spawn_frog(n) to add n frogs to the world
#include animals/frog.lua

-- objects attract and repel based on their qualia
-- this function builds a table of objects of unique qualia types
-- then objects can act all at once
-- without having to do tons of repeated lookups per object
cache_qualia = function(tbl)
 local cache = {}
 for v in all(tbl) do
   local qk = v.qualia
   if qk ~= nil then
    if not(cache[qk]) then
     cache[qk]={}
    end
    add(cache[qk], v)
   end
 end
 return(cache)
end

enact_qualia = function(w, qc)
 for v in all(world) do
  if v.attracted_to then
   for a in all(v.attracted_to) do
    if qc[a] ~= nil then
     for q in all(qc[q]) do
      local f = qualia_force(v.pos, q.pos)
      add_force(v, f)
     end
    end
   end
  end
  if v.repelled_by then
   for r in all(v.repelled_by) do
    if qc[r] ~= nil then
     for q in all(qc[r]) do
       local f = qualia_force(v.pos, q.pos)
       f:scale_vector(-1)
       add_force(v, f)
     end
    end
   end
  end
 end
end

qualia_force = function(pos1, pos2)
 local g = 500 -- made-up repulsion factor
 local p1 = pos1:copy_vector()
 local p2 = pos2:copy_vector()
 local r_hat = p1:copy_vector()
 r_hat:sub_vector(p2)
 local d = r_hat:magnitude()
 r_hat:scale_vector(-1)
 local r2 = r_hat:magnitude() * r_hat:magnitude()
 if d >= 2 and d <= 32 then  -- apply force if they're not *too* close
   -- otherwise, you get huge accelerations at micro-distances
   -- or *too* far, otherwise they run from nothing.
   r_hat:normalize()
   local g_mag = g / r2
   r_hat:scale_vector(g_mag)
   return(r_hat) -- action
 else
   return(create_vector(0,0))
 end
end



-- play an animal's sfx with a given probability
-- this is actually a great function for ECS to handle,
-- at least in the idle case
play_psfx = function(s)
 local patch = s.patch or 0
 local prob = s.probability or 0
 if rnd(prob)<=1 then
  sfx(patch)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001d300060002b3000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e330294102d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000001430014200132002410024300231003440054100844011230036401a2300042019220004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
