pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- piconoc
-- by cameron goble
-- a life-like system of autonomous
-- agent behaviors for pico-8

-- entity component systems (ecs)
-- handles processing large
-- collections of object agents
-- such as particles, flocks, etc
#include libs/ecs.lua

-- behavior code based on daniel
-- schiffman's "nature of code"
#include libs/1-vectors.lua

-- note: piconoc uses state machines
-- called "chapters" to
-- experiment with different
-- combinations of behaviors

-- note: piconoc uses object model of data/method
-- as much as possible
-- therefore vectors have "methods" for
-- adding, subtracting, etc
-- and modify their own data
-- e.g.   pos:add(vel)
-- changes the value of pos relative to vel
-- remember to use copy_vector() to perform non-destructive operations

function _init()
 -- screen dimensions, player control buttons, whatever else defines pico-8
 sw,sh = 128,115 -- save room for hints at bottom
 u,d,l,r = create_vector(0,-1), create_vector(0,1), create_vector(-1,0), create_vector(1,0)

 -- start with a clean, basic ecs world
 init_world()

 -- set up state machine with various name, init and update functions
 chapters = {}
 chapters["vectors"]={init=_vectors_init, update=_vectors_update, hint="apply forces: ⬆️⬇️⬅️➡️\nnudge rnd: ❎  nudge center: 🅾️"}
 state = "vectors"

 -- debug levels correspond to chapters in "nature of code"
 -- levels show debug info for topics in each chapter
 -- the game can be in one state while debugging processes from another
 -- very handy for seeing how topics interact across chapters
 -- see keey in chapters table above for possible values
 debug_level = "vectors"

 -- now start the whole thing off!
 chapters[state].init()
end

function _update()
 -- accelaration starts at zero for each frame
 reset_acceleration(world)
 -- do whatever's needed for the state we're in
 -- (includes player controls for each state)
 chapters[state].update()
 -- do all physics on the world
 resolve_velocity(world)
 resolve_position(world)
end

function _draw()
 cls()
 draw_position(world)
 if debug_level then
  if debug_level == "vectors" then
   debug_velocity(world)
   debug_to_target(world)
   debug_acceleration(world)
  end
 end
 draw_hint()
end

function draw_hint()
 rectfill(0, 116, 128, 128, 0)
 print(chapters[state].hint, 0, 117, 7)
end

-->8
-- ecs functions and systems

function init_world()
 world = {}
 -- common objects: reference points on the screen
 origin = {pos = create_vector(0,0)}
 center = {pos = create_vector(sw/2, sh/2)}
 add(world, origin)
 add(world, center)
 -- other objects added by various state_inits
end
-->8
-- object/agent systems

-- draw an object with a position if visible
draw_position = system({"pos"},
function(e)
 local col = e.color or 12
 local r = e.radius or 2
 if (e.visible) circfill(e.pos.x, e.pos.y, r, col)
end)

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

--explicitly highlighted function to set all acc to 0
--if we didn't do this, acc would compound every frame
reset_acceleration = system({"acc"},
function(e)
 e.acc:scale_vector(0)
end
)

-->8
-- visual debugging functions

-- draw velocities
debug_velocity = system({"pos", "vel"},
function(e)
 local col = 7
 local scale = 5
 local c = e.vel:copy_vector()
 c:scale_vector(5)
 line(e.pos.x, e.pos.y, e.pos.x + c.x, e.pos.y + c.y,col)
 local report = "vel: ["..e.vel.x..","..e.vel.y.."]"
 printh(report)
end
)

-- draw accelerations
debug_acceleration = system({"pos", "vel", "acc"},
function(e)
 local col = 15
 local scale = 5
 local c = e.acc:copy_vector()
 if c:magnitude() != 0 then
  c:scale_vector(5)
  line(e.pos.x, e.pos.y, e.pos.x + c.x, e.pos.y + c.y,col)
  local report = "acc: ["..e.acc.x..","..e.acc.y.."]"
  printh(report)
 end
end
)

-- draw the direction an object must take to reach another object's position
debug_to_target = system({"pos", "vel", "target"},
function(e)
 local col = 6
 local tp = e.target.pos
 local tv = to_target(e, e.target)
 print(tv:magnitude(), tp.x + 4, tp.y + 4, col)
 tv:normalize()
 tv:scale_vector(10)
 line(e.pos.x, e.pos.y, e.pos.x+tv.x, e.pos.y+tv.y, col)
 -- absolute line end positions based on target calcs
 -- cconfirms this is a good solution
 circfill(e.pos.x, e.pos.y, 2, 11)
 circfill(tp.x, tp.y, 2, 8)
end
)



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
