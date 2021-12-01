-- Nature of Code
-- Chapter 2: Forces
-- see: https://natureofcode.com/book/chapter-2-forces/

-- requires 1-vectors.lua
-- but pico doesn't allow embedded #includes
-- so remember that for main.p8!

function bestow_linear_physics(table, attr_table)
  -- attr_table: {mass = scal, radius = scal, friction = scal, newtonian = bool}
  t = table or {}
  a = attr_table or {}
  t.mass = a.mass or 0  -- mass increases left to right
  t.radius = a.radius or 1  -- mass and size are the same, for now,
  -- but some forces like drag are affected by size seperate from mass
  t.friction = a.friction or 0 --  material smoothness
  t.newtonian = a.newtonian or false -- turn on newtonian physics engine for mutual gravity and such
  return t
end



function _forces_init()
  _vectors_init()     -- similar world: got a ball, got a center, got an origin
  del(world, ball) -- don't need it tho.
  del(world, center)
  -- for this, let's make a set of balls
  for i=1,5 do
    local b = _create_ball()
    b = bestow_linear_physics(b)
    b.color = 8
    b.mass = b.pos.x / 24  -- for this demo, make small to large across the screen
    b.radius = b.mass
    add(world, b)
  end
  universal_wind = {   -- wind will be a force that affects the world
    force = create_vector(0,0),  -- one pixel per second per second
    nudge = .1
  }
  universal_gravity = { -- like wind, a universal force in the world
    -- gravity has no position and attracts massive objects downward
    -- could change vector for another direction
    nudge = create_vector(0, 1/120), -- acc pixels per frame, 1/30 works out to +1 pixel per second per second
    force =  create_vector(0, 0),  -- initially zero
  }
  universal_friction = {
    coefficient = 0,
    nudge = .01
  }
  -- for drag, simulate a liquid for the balls to drop in "h" high
  liquid_drag = {
    height = 129, -- height on screen
    rho = .1, -- density of the liquid
    nudge = .02
  }
  newtonian_gravity = {
    g = .04,
    nudge = .01
  }
  force_to_demo = "wind"
end

-- apply wind force to each object in the world, accounting for mass
-- objects without mass are not affected
-- objects with mass are affected proportionally
apply_universal_wind = system({"mass", "acc"},
  -- objects with mass and that can be accelerated will be affected.
  -- objects with mass but no acc (like center) will not!
  -- note to self: always make sure the components match
  -- the variables that the system affects
  -- or you will error mysteriously!
  function(e)
    local wf = universal_wind.force:copy_vector()
    wf:scale_vector(1/e.mass)  -- proportional effect
    add_force(e, wf) -- this affects e.acc behind the scenes
    -- objects with mass but without acc would error here.
  end
)

apply_universal_gravity = system({"mass", "acc"},
  -- gravity looks exactly like wind in the world-wide case
  -- it is a force that always pushes down
  -- but unlike wind (and real world physics), it doesn't react to mass
  -- this is so objects will always fall at the same rate
  -- regardless of their mass!
  -- (and so we don't have to simulate and equal/opposite
  -- force on a "planet" object to balance everything)
  function(e)
    local gf = universal_gravity.force:copy_vector()
    -- copied in case we want to do calcs on it later
    add_force(e, gf) -- this affects e.acc behind the scenes
    -- objects with mass but without acc would error here.
  end
)

apply_newtonian_gravity = system({"mass", "acc", "newtonian"},
  -- newtonian gravity applies equal and opposite force between objects
  -- based on their relative masses
  -- the values here will probably need a lot of tweaking
  -- and be at weird scales
  -- just like the universe.
  -- so authentic!
  function(e)
    -- this ECS-style function calls on all individual objects,
    -- but doesn't help us communicate between objects.
    -- So we'll do this in two parts:
    -- Here, build a list of all newtonian objects affected by gravity
    -- later in _update, go through the list
    -- and apply gravity with the whole list in mind
    -- So, initialize the list if needed
    --if not gravity_objects then gravity_objects = {} end
    if e.newtonian == true then add(gravity_objects, e)  end
  end
)

function resolve_newtonian_gravity()
  for obj1 in all(gravity_objects) do   -- each object
    for obj2 in all(gravity_objects) do -- applies to all the other objects
      if obj1 != obj2 then                -- except itself
        local g = newtonian_gravity.g or .03     -- gravitational constant, see _forces_init()
        local m1 = obj1.mass
        local m2 = obj2.mass
        local p1 = obj1.pos:copy_vector()
        local p2 = obj2.pos:copy_vector()
        local r_hat = p1:copy_vector()
        r_hat:sub_vector(p2)
        r_hat:scale_vector(-1)
        local r2 = r_hat:magnitude() * r_hat:magnitude()
        if r2 >= 4 then  -- apply gravity if they're not *too* close
          -- otherwise, you get huge accelerations at micro-distances
          -- maybe this is why quantum gravity doesn't work?
          r_hat:normalize()
          local g_mag = (g * m1 * m2) / r2
          r_hat:scale_vector(g_mag) -- says newton
          add_force(obj1, r_hat) -- action
        end
        -- the "equal and opposite" comes around when obj2 becomes obj1
      end
    end
  end
end


apply_friction = system({"friction", "acc", "vel"},
  -- friction occurs when a collision happens
  -- it is a force the operates in the direction opposite of motion
  -- to dampen movement
  function(e)
    local mu =  universal_friction.coefficient + e.friction
    --objects can be made of different materials
    local normal = 1
    -- normal is usually calculated along with gravity
    -- as being perpendicular to motion
    -- but we're not doing that for this demo
    local frictionMag = mu*normal
    local friction = e.vel:copy_vector()
    friction:set_magnitude(frictionMag)
    friction:scale_vector(-1)
    add_force(e, friction)
  end
)

apply_drag = system({"radius", "acc", "vel"},
-- drag is like friction, but it depends on surface area & velocity
  function(e)
    if e.pos.y >= liquid_drag.height then  -- drag only if the entity is below the surface
      local rho = liquid_drag.rho -- density of the liquid
      local vel_mag = e.vel:magnitude()
      local area = e.radius or 1 -- surface area of the object (to be elaborated on later)
      local cod = e.drag or 1    -- coefficient of drag or liquid (or custom to the object)
      local vel = e.vel:copy_vector()
      local drag_mag = -.5 * rho * vel_mag * vel_mag * area * cod
      vel:set_magnitude(drag_mag)
      vel:limit(vel_mag)
      add_force(e, vel)
    end
  end
)

pisa_drop = system({"pos","vel","acc"}, function(e)
  -- resets all objects to a constant height
  -- to illustrate world_gravity and drag
  e.pos.y = 16
  e.vel = create_vector(0,0)
  e.acc = create_vector(0,0)
end)
randomize_balls = system({"pos", "vel", "acc"},
function(e)
  local rx = rnd(32) + 32
  local ry = rnd(32) + 32
  e.pos = create_vector(rx,ry)
  e.vel = create_random_vector(.5)
  e.newtonian = true
end)

function _force_controls()
  local controls = {}
  controls["wind"] = function()
    local rv = create_random_vector(universal_wind.nudge) -- gust in some random direction
    local wind_mag = universal_wind.force:magnitude()
    -- apply player input to the wind
    if btnp(❎) then universal_wind.force = rv  --random velocity
    elseif btnp(🅾️) then universal_wind.force:scale_vector(0) -- stop the wind
    elseif btnp(⬆️) then
      if universal_wind.force:magnitude() == 0 then universal_wind.force = rv end
      universal_wind.force:scale_vector(1+universal_wind.nudge)
    elseif btnp(⬇️) then
      if universal_wind.force:magnitude() == 0 then universal_wind.force = rv end
      universal_wind.force:scale_vector(1-universal_wind.nudge)
    elseif btnp(⬅️) then
      universal_wind.force:scale_vector(0)
      randomize_balls(world)
      force_to_demo = "mutual gravitation"
    elseif btnp(➡️) then
      universal_wind.force:scale_vector(0)
      force_to_demo = "friction"
      universal_friction.coefficient = universal_friction.nudge * 3
    end
  end
  controls["friction"] = function()
    -- apply player input to the *friction*
    if btnp(❎) then   --give moveable objects a nudge
      local nudge = system({"pos","vel","acc"}, function(e)
        local f = create_random_vector(3)
        add_force(e,f)
      end
      )
      nudge(world)
    elseif btnp(🅾️) then universal_friction.coefficient = 0 -- frictionless
    elseif btnp(⬆️) then universal_friction.coefficient += universal_friction.nudge
    elseif btnp(⬇️) then universal_friction.coefficient -= universal_friction.nudge
    elseif btnp(⬅️) then
      universal_friction.coefficient = 0
      force_to_demo = "wind"
    elseif btnp(➡️) then
      universal_friction.coefficient = 0
      force_to_demo = "world gravity"
    end
    -- no "negative" friction:
    universal_friction.coefficient = max(universal_friction.coefficient, 0)
  end
  controls["world gravity"] = function()
    -- apply player input to the *universal gravity*
    if btnp(❎) then   --reset the balls to new pisa drop positions
      pisa_drop(world)
    elseif btnp(🅾️) then universal_gravity.force = create_vector(0,0) -- zero gravity
    elseif btnp(⬆️) then
        universal_gravity.force:add_vector(universal_gravity.nudge)
    elseif btnp(⬇️) then
        universal_gravity.force:sub_vector(universal_gravity.nudge)
    elseif btnp(⬅️) then
      universal_gravity.force = create_vector(0,0)
      force_to_demo = "friction"
    elseif btnp(➡️) then
      universal_gravity.force = create_vector(0, 1/30)
      liquid_drag.height = 64
      pisa_drop(world)
      force_to_demo = "drag"
    end
  end

  controls["drag"] = function()
    -- apply player input to the *liquid drag*
    if btnp(❎) then liquid_drag.height = 64 pisa_drop(world)
    elseif btnp(🅾️) then liquid_drag.height = 129
    elseif btnp(⬆️) then liquid_drag.rho += liquid_drag.nudge
    elseif btnp(⬇️) then liquid_drag.rho -= liquid_drag.nudge
    elseif btnp(⬅️) then
      universal_gravity.force = create_vector(0, 0)
      liquid_drag.height = 129
      force_to_demo = "world gravity"
    elseif btnp(➡️) then
      universal_gravity.force = create_vector(0, 0)
      liquid_drag.height = 129
      randomize_balls(world)
      force_to_demo = "mutual gravitation"
    end
  end
  controls["mutual gravitation"] = function()
    -- apply player input to the *liquid drag*
    local un_newtonize = system({"pos", "vel", "acc"},
          function(e)
            e.newtonian = false
          end)
    if btnp(❎) then randomize_balls(world)
    elseif btnp(🅾️) then newtonian_gravity.g=0
    elseif btnp(⬆️) then newtonian_gravity.g += newtonian_gravity.nudge
    elseif btnp(⬇️) then newtonian_gravity.g -= newtonian_gravity.nudge
    elseif btnp(⬅️) then
      un_newtonize(world)
      universal_gravity.force = create_vector(0, 1/30)
      liquid_drag.height = 64
      pisa_drop(world)
      force_to_demo = "drag"
    elseif btnp(➡️) then
      un_newtonize(world)
      force_to_demo = "wind"
    end
  end
  controls[force_to_demo]()
end

function _forces_update()
  -- Any combination of forces can be active at the same time
  -- the player can switch between controls to adjust or zero out forces
  _force_controls()
  apply_universal_wind(world)
  apply_friction(world)
  apply_drag(world)
  apply_universal_gravity(world)
  gravity_objects = {}
  apply_newtonian_gravity(world)
  resolve_newtonian_gravity()
end

function _forces_draw()
  -- liquid surface
  if liquid_drag.height < 129 then rectfill(0,liquid_drag.height, 128, 120 , 12) end
  -- flagpole, if there is wind
  if universal_wind.force:magnitude() >0 then
    local flag = {pos = create_vector(100,10)}
    -- Not an autonomous agent, just an indicator of wind speed
    -- so, not added to world or part of any special update routines
    circfill(flag.pos.x, flag.pos.y, 2, 12)
    local w = universal_wind.force:copy_vector()
    print(w.x..","..w.y, flag.pos.x-24, flag.pos.y+4, 12)
    w:set_magnitude(8)       -- nice, long flag to wave
    w:add_vector(flag.pos)  -- position for waving tip to end up
    line(flag.pos.x, flag.pos.y, w.x, w.y)
  end
  rectfill(0, 109, 128, 128, 0)
  local p = print(force_to_demo, 0, 110, 7)
  local ps = ""
  if force_to_demo == "friction" then ps = ": "..universal_friction.coefficient
  elseif force_to_demo =="world gravity" then ps = " (px/s^2): "..universal_gravity.force.y
  elseif force_to_demo == "drag" then ps =": "..liquid_drag.rho
  elseif force_to_demo == "mutual gravitation" then ps= ": "..newtonian_gravity.g
  end
  print(ps, p+2, 110)
end
