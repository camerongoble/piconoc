-- Nature of Code
-- Chapter 2: Forces
-- see: https://natureofcode.com/book/chapter-2-forces/

function _forces_init()
  _vectors_init()     -- similar world: got a ball, got a center, got an origin
  ball.mass=10-- different features: ball got mass.
  ball.friction=.01 -- ball got friction too
  --in fact, let's make a ton of balls with random masses and friction
  for i=1,20 do
    local b = _create_ball()
    b.mass = rnd(20)
    b.friction = .01
    b.pos.y=64 -- tower of piza drop
    -- wind affects mass, so expect small differences
    add(world, b)
  end
  wind = {   -- wind will be a force within the world
    -- note: wind has no position. it's everywhere! And doesn't need drawing.
    vel = create_random_vector(1/30),  -- one pixel per second per second
    -- wind uses vel to impart its force onto things
    -- this is so we can use apply_force() to change the
    -- direction and power of the wind
    acc = create_vector(0,0)
  }
  add(world, wind)
  gravity = { -- like wind, a force in the world
    -- gravity has no position
    vel =  create_vector(0, 1/30), -- down, one pixel per second
    acc = create_vector(0,0)
  }
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

apply_gravity = system({"mass", "acc"},
  -- gravity looks exactly like wind in the world-wide case
  -- it is a force that always pushes down
  -- but unlike wind (and real world physics), it doesn't react to mass
  -- this is so objects will always fall at the same rate
  -- regardless of their mass!
  -- (and so we don't have to simulate and equal/opposite
  -- force on a "planet" object to balance everything)
  function(e)
    local gf = gravity.vel:copy_vector()
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
  apply_gravity(world)
  apply_friction(world)
end

function _forces_draw()
  local flag = {pos = create_vector(100,100)}
  -- Not an autonomous agent, just an indicator of wind speed
  -- so, not added to world or part of any special update routines
  circfill(flag.pos.x, flag.pos.y, 2, 12)
  local w = wind.vel:copy_vector()
  print(w.x..","..w.y, flag.pos.x-24, flag.pos.y+4, 12)
  w:set_magnitude(8)       -- nice, long flag to wave
  w:add_vector(flag.pos)  -- position for waving tip to end up
  line(flag.pos.x, flag.pos.y, w.x, w.y)
end
