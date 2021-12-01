-- Nature of Code
-- Chapter 3: Oscillation
-- see: https://natureofcode.com/book/chapter-3-oscillation/

-- requires 1-vectors.lua
-- and 2-forces.lua
-- but pico doesn't allow embedded #includes
-- so remember that for main.p8!

function rescale(sample, sample_start, sample_end, range_start, range_end)
  -- maps a sample number from a given range to a proportional number in a new range
  -- useful for scaling non-unit-size functions into screen-sized results
  local s = sample
  local ss = sample_start or 0
  local se = sample_end or 1
  local rs = range_start or 0
  local re = range_end or 1
  local m = (re - rs) / (se - ss)
  return rs + m * (s - ss)
end


function angle_to_cos_sin(tau)
  local t = tau or 0
  local cosine = cos(tau)
  local sine = -sin(tau)  -- negative due to pico's coord system
  return cosine, sine
end

function polar_to_cartesian_vec(tau, radius)
  local t = tau or 0
  local r = radius or 1
  local c,s = angle_to_cos_sin(t)
  local x = c * r
  local y = s * r
  return create_vector(x, y)
end

function _pvo_rotate_to(self, tau)
  tau = tau % 1 or 0
  local c,s = angle_to_cos_sin(tau)
  self.points = {}
  for p in all(self.shape) do
    local xo, yo = p.x, p.y
    add(self.points, create_vector((xo*c)-(yo*s), (xo*s)+(yo*c)))
  end
  self.angle = tau
end

function _pvo_rotate_by(self, tau)
  local t = tau or 0
  self:rotate_to(self.angle + tau)
end

function _pvo_locate(self, x,y)
  self.origin = create_vector(x, y)
end

function _pvo_translate(self,x,y)
  self.origin.x += x
  self.origin.y += y
end


function _pvo_draw(self)
  -- start a fresh line
  local ox, oy = self.origin.x, self.origin.y
  if self.pos then
    ox += self.pos.x
    oy += self.pos.y
  end

  line(self.points[1].x+ox, self.points[1].y+oy, self.points[1].x+ox, self.points[1].y+oy)
  for i = 2,#self.points do
    -- connect the rest of the dots
    line(self.points[i].x+ox, self.points[i].y+oy)
  end
  -- connect back to initial dot
  line(self.points[1].x+ox, self.points[1].y+oy)
end

resolve_angular_velocity = system({"angle", "angle_vel"}, function(e)
  -- keeps anything with an angle spinning
  -- for demonstration animation
  e:rotate_by(e.angle_vel)
end)

resolve_angular_acceleration = system({"angle", "angle_vel", "angle_acc"},
function(e)
  e.angle_vel += e.angle_acc
  e.angle_acc = 0             -- zero out at the beginning of each frame
end
)

flyby_rotate = system({"angle", "pos"}, function(e)
  local a = rescale(e.pos.x, 1, 128, 0 ,1)
  e.angle = a
  end
)

function _pv_add_angular_force(self, f_scalar)
  f = f_scalar or 0
  self.angle_acc += f
end

draw_polyvectors = system({"angle", "draw"}, function(e)
  if (e.visible) e:draw()
end
)

function create_polyvector_object(table_of_vectors)
  -- a polygonal object that can move and freely rotate
  -- like a ship in "asteroids"
  local obj = {
    -- mutable points that actually get drawn:
    shape = table_of_vectors or {},
    points = table_of_vectors or {},
    visible = true,
    draw = _pvo_draw
  }
  return obj
end

function bestow_angular_physics(table)
  local t = table or {}
  -- rotation in pico-8 turns (aka: tau):
  t.angle = 0    --scalar for angle
  t.angle_vel = 0  --scalar for angular velocity
  t.angle_acc = 0  --scalar for angular acceleration
  t.scale = 1
  t.origin = create_vector(0,0)
  t.add_angular_force = _pv_add_angular_force
  t.rotate_by = _pvo_rotate_by
  t.rotate_to = _pvo_rotate_to
  t.offset = _pvo_offset
  t.translate = _pvo_translate
  return t
end

function init_angle()
  osc_to_demo = "angle"
  local baton_shape = {create_vector(10,0), create_vector(-10,0)}
  baton = create_polyvector_object(baton_shape)
  baton = bestow_movement(baton)
  baton = bestow_angular_physics(baton)
  baton.vel = create_vector(rnd(2)-1, rnd(2)-1)
  baton.visible = true
  world = {}
  add(world, baton)
end

function init_posxspin()
  osc_to_demo = "pos.x spin"
  world = {}
  -- make a central planet with gravity:
  local planet = bestow_movement()
  planet = bestow_linear_physics(planet, {mass = 10, radius = 2, friction = 0, newtonian = true})
  planet.visible = true
  planet.color = 7
  planet.stationary = true
  add(world, planet)
  -- add a gaggle of satellites that spin around:
  for i = 1,10 do
    local baton_shape = {create_vector(5,0), create_vector(-5,0)}
    baton = create_polyvector_object(baton_shape)
    baton = bestow_movement(baton)
    baton = bestow_linear_physics(baton, {mass = 1, radius = 1, friction = 0, newtonian = true}) -- this is different from the baton in angle state
    baton = bestow_angular_physics(baton)
    baton.vel = create_vector(rnd(2)-1, rnd(2)-1)
    baton.visible = true
    add(world, baton)
  end
end




function _oscillation_init()
  init_posxspin()
  newtonian_gravity = {
      g = .04,
      nudge = .01
    }
end

function _oscillation_update()
  -- ⬅️➡️⬆️⬇️❎🅾️
  if osc_to_demo == "angle" then
    if (btnp(⬅️)) baton:add_angular_force(-.01)
    if (btnp(➡️)) baton:add_angular_force( .01)
    if (btnp(🅾️)) baton:rotate_to(0) baton.angle_vel = 0
    if (btnp(❎)) baton:rotate_to(0) baton.angle_vel = (rnd(2) -1)/100
    if (btnp(⬆️)) init_posxspin()
  elseif osc_to_demo == "pos.x spin" then
    flyby_rotate(world)
    if (btnp(⬇️)) init_angle()
  end

  gravity_objects = {}
  apply_newtonian_gravity(world)
  resolve_newtonian_gravity()
  resolve_velocity(world)
  resolve_position(world)
  resolve_angular_acceleration(world)
  resolve_angular_velocity(world)
end

function _oscillation_draw()
  draw_polyvectors(world)
  rectfill(0, 109, 128, 128, 0)
  local p = print(osc_to_demo, 0, 110, 7)
  local ps = ""
  if (osc_to_demo == "angle") then
    local as = ((baton.angle * 100) \ 1) /100
    ps = ":".. as .. " angle vel:".. baton.angle_vel
  end
  print(ps, p+2, 110)
end

chapters["oscillation"]={
 init=_oscillation_init,
 update=_oscillation_update,
 draw=_oscillation_draw,
 hint="new osc.: ⬆️⬇️  intensity: ⬅️➡️\nrandom: ❎  zero: 🅾️"
}
