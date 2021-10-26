-- Nature of Code
-- Chapter 2: Forces
-- see: https://natureofcode.com/book/chapter-2-forces/

function _forces_init()
  _vectors_init()     -- similar world: got a ball, got a center, got an origin
  ball.mass=10-- different features: ball got mass.
  wind = {   -- wind will be a force within the world
    -- note: wind has no position. it's everywhere! And doesn't need drawing.
    vel = create_random_vector(1/30),  -- one pixel per second per second
    acc = create_vector(0,0)
  }
  add(world, wind)


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
