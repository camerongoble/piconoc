-- Nature of Code
-- Chapter 2: Forces
-- see: https://natureofcode.com/book/chapter-2-forces/

function _forces_init()
  _vectors_init()     -- similar world: got a ball, got a center, got an origin
  ball.mass=10-- different features: ball got mass.
  center.mass=100 -- center object has a bigger mass.
  wind = {   -- wind will be a force within the world
    -- note: wind has no position. it's everywhere! And doesn't need drawing.
    vel = create_random_vector(5),
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
    wf:scale_vector(1/e.mass)
    add_force(e, wf) -- this affects e.acc behind the scenes
    -- objects with mass but without acc would error here.
  end
)



function _forces_update()
  printh("wind: "..wind.vel.x..','..wind.vel.y)
  -- similar player control rules as before
  local rv = create_random_vector(5) -- nudge in some random direction

  -- apply player input to the *wind*
  if btnp(❎) then add_force(wind, rv)  --random force
  elseif btnp(⬆️) then add_force(wind,u)
  elseif btnp(⬇️) then add_force(wind,d)
  elseif btnp(⬅️) then add_force(wind,l)
  elseif btnp(➡️) then add_force(wind,r)
  end
  apply_wind(world)
end
