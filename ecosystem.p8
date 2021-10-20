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
 dir={"u", "d", "l", "r", "stationary", "ul", "dl", "ur", "dr"}
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
 spawn_frog(10)
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
 if (e.visible) e:draw()
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
 local s = e.sfx.boundary or {}
 if b=="wrap" then -- pass through the edge
  if (e.pos.x >= sw-1) then e.pos.x = 1 play_psfx(s) end
  if (e.pos.x <= 1) then e.pos.x = sw-1 play_psfx(s) end
  if (e.pos.y >= sh-1) then e.pos.y = 1 play_psfx(s) end
  if (e.pos.y <= 1) then e.pos.y = sh-1 play_psfx(s) end
 elseif b=="bounce" then -- reflect back along the relevant axis
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
 elseif b=="bonk" then -- no passage, just stop right there
  if (e.pos.x >= sw-1) or (e.pos.x <= 1) or (e.pos.y >= sh-1) or (e.pos.y <= 1) then
   play_psfx(s)
   e.pos.x = mid(1,e.pos.x,sw-1)
   e.pos.y = mid(1,e.pos.y,sh-1)
  end
 end
end
)

play_psfx = function(s)
 local patch = s.patch or 0
 local prob = s.probability or 0
 if rnd(prob)<=1 then
  sfx(patch)
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
-- animals

-- spawn_fly(n) to add n flies to the world
#include animals/housefly.lua

--spawn_frog(n) to add n frogs to the world
#include animals/frog.lua

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
0007000001430014200132002430024300234003440054400844011230036401a2300042019220004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
