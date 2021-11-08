-- Nature of Code
-- Chapter 2: Forces
-- see: https://natureofcode.com/book/chapter-2-forces/

function _forces_init()
  _vectors_init()     -- similar world: got a ball, got a center, got an origin
  del(world, ball)
  del(world, center)
  -- for this, let's make a ton of balls with random masses and friction
  for i=1,20 do
    local b = _create_ball()
    b.color = 8
    b.mass = b.pos.x / 5  -- mass increases left to right
    b.radius = b.mass / 4 -- scale the circle representation
    -- b.friction = rnd(.02) -- random material smoothness
    b.drag = 1
    b.pos.y=4 -- tower of piza drop
    --b.vel=create_random_vector(1)
    -- wind affects mass, so expect small differences
    add(world, b)
  end
  wind = {   -- wind will be a force that affects the world
    -- note: wind has no position. it's everywhere! And doesn't need drawing.
    vel = create_vector(0,0),  -- one pixel per second per second
    -- wind uses vel to impart its force onto things
    -- this is so we can use apply_force() to change the
    -- direction and power of the wind
    acc = create_vector(0,0)
  }
  -- Add it to the world so it automagically updates
  add(world, wind)
  universal_gravity = { -- like wind, a universal force in the world
    -- gravity has no position and attracts massive objects downward
    -- could change vector for another direction
    vel =  create_vector(0, 1/30), -- down, one pixel per second
    acc = create_vector(0,0)
  }
  -- for drag, simulate a liquid for the balls to drop in "h" high
  liquid_h = 64

end

-- apply wind force to each object in the world, accounting for mass
-- objects without mass are not affected
-- objects with mass are affected proportionally
apply_wind = system({"mass", "acc"},
  -- objects with mass and that can be accelerated will be affected.
  -- objects with mass but no acc (like center) will not!
  -- note to self: always make sure the components match
  -- the variables that the system affects
  -- or you will error mysteriously!
  function(e)
    local wf = wind.vel:copy_vector()
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
    local gf = universal_gravity.vel:copy_vector()
    add_force(e, gf) -- this affects e.acc behind the scenes
    -- objects with mass but without acc would error here.
  end
)

apply_friction = system({"friction", "acc", "vel"},
  -- friction occurs when a collision happens
  -- it is a force the operates in the direction opposite of motion
  -- to dampen movement
  function(e)
    local mu =  e.friction
    local normal = 1
    -- normal is usually calculated along with gravity
    -- as being perpendicular to motion
    local frictionMag = mu*normal
    local friction = e.vel:copy_vector()
    friction:set_magnitude(frictionMag)
    friction:scale_vector(-1)
    add_force(e, friction)
  end
)

apply_drag = system({"drag", "acc", "vel"},
-- drag is like friction, but it depends on surface area & velocity
  function(e)
    if e.pos.y >= liquid_h then  -- drag only if the entity is below the surface
      local rho = .1 -- density of the liquid
      local vel_mag = e.vel:magnitude()
      local area = e.radius or 1 -- surface area of the object (to be elaborated on later)
      local cod = e.drag
      local vel = e.vel:copy_vector()
      local drag_mag = -.5 * rho * vel_mag * vel_mag * area * cod
      vel:set_magnitude(drag_mag)
      vel:limit(vel_mag)
      add_force(e, vel)
    end
  end
)

function _forces_update()
  -- similar player control rules as before
  local rv = create_random_vector(.1) -- nudge in some random direction
  -- local tiny forces, since wind is constant
  local u,d,l,r = create_vector(0,-.1), create_vector(0,.1), create_vector(-.1,0), create_vector(.1,0)
  -- apply player input to the *wind*
  if btnp(❎) then add_force(wind, rv)  --random force
  elseif btnp(🅾️) then wind.vel:scale_vector(0) -- stop the wind
  elseif btnp(⬆️) then add_force(wind,u)
  elseif btnp(⬇️) then add_force(wind,d)
  elseif btnp(⬅️) then add_force(wind,l)
  elseif btnp(➡️) then add_force(wind,r)
  end
  apply_wind(world)
  apply_universal_gravity(world)
  apply_friction(world)
  apply_drag(world)
end

function _forces_draw()
  -- liquid surface
  rectfill(0,liquid_h, 128, 120 , 12)
  -- flagpole, if there is wind
  if wind.vel:magnitude() >0 then
    local flag = {pos = create_vector(100,10)}
    -- Not an autonomous agent, just an indicator of wind speed
    -- so, not added to world or part of any special update routines
    circfill(flag.pos.x, flag.pos.y, 2, 12)
    local w = wind.vel:copy_vector()
    print(w.x..","..w.y, flag.pos.x-24, flag.pos.y+4, 12)
    w:set_magnitude(8)       -- nice, long flag to wave
    w:add_vector(flag.pos)  -- position for waving tip to end up
    line(flag.pos.x, flag.pos.y, w.x, w.y)
  end
end
