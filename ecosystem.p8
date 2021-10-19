pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- ecosystem
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
-- Can you control the object’s motion by
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
   ul=create_vector(-1,-1),
   dl=create_vector(-1,1),
   ur=create_vector(1,-1),
   dr=create_vector(1,1)
 }
 dir={"u", "d", "l", "r", "ul", "dl", "ur", "dr"}
 init_world()
end

function _update()
 update_world()
end

function _draw()
 cls()
 draw_world()
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
 spawn_fly(25)
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

-- draw an object with a position if visible
draw_position = system({"pos"},
function(e)
 if (e.visible) e:draw()
end)

update_selves = system({"update"},
function(e)
 e:update()
end
)

-- add object velocities to positions
resolve_position = system({"pos", "vel"},
function(e)
 e.pos:add_vector(e.vel)
 local b = e.boundary_behavior or "none"
 if b=="wrap" then -- pass through the edge
  if (e.pos.x >= sw) e.pos.x = 0
  if (e.pos.x <= 0) e.pos.x = sw
  if (e.pos.y >= sh) e.pos.y = 0
  if (e.pos.y <= 0) e.pos.y = sh
 elseif b=="bounce" then -- reflect back along a single axis
  if (e.pos.x >= sw or e.pos.x <= 0) e.vel.x *= -1
  if (e.pos.y >= sh or e.pos.y <= 0) e.vel.y *= -1
 end
end
)

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
-- animal: fly
-- behaviors:
-- flies are tiny.
-- flies make little sounds. **not yet implemented**
-- flies randomly hover around in all directions.
-- flies sometimes move fast, other times they linger.
-- flies bonk against the window infuriatingly.

function spawn_fly(n)
 for i = 1,n do
  local x,y = flr(rnd(sw)), flr(rnd(sh))
  local f = {
   visible = true,
   color = rnd({5,13}), --some shade of grayish
   pos = create_vector(x, y),
   vel = create_vector(0, 0),
   acc = create_vector(0,0),
   maxspeed = 1, --always in pixels per frame
   -- flies bonk against the window infuriatingly.
   boundary_behavior = "bounce",
   -- main loop functions
   draw = _draw_fly,
   update = _update_fly
  }
  add(world, f)
 end
end

function _draw_fly(self)
 -- flies are tiny.
 pset(self.pos.x, self.pos.y, self.color)
end

function _update_fly(self)
 -- flies randomly hover around in all directions.
 -- flies sometimes move fast, other times they linger.
  local d=rnd(dir)
  self.acc:add_vector(dir_vecs[d])
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
