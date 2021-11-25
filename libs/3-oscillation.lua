-- Nature of Code
-- Chapter 3: Oscillation
-- see: https://natureofcode.com/book/chapter-3-oscillation/

-- requires 1-vectors.lua
-- and 2-forces.lua
-- but pico doesn't allow embedded #includes
-- so remember that for main.p8!

function polar_to_cos_sin(tau)
  local t = tau or 0
  local cosine = cos(tau)
  local sine = -sin(tau)  -- negative due to pico's coord system
  return cosine, sine
end

function polar_to_cartesian_vec(tau, radius)
  local t = tau or 0
  local r = radius or 1
  local c,s = polar_to_cos_sin(t)
  local x = c * r
  local y = s * r
  return create_vector(x, y)
end

function _pvo_rotate_to(self, tau)
  local c,s = polar_to_cos_sin(tau)
  self.points = {}
  for p in all(self.shape) do
    local xo, yo = p.x, p.y
    add(self.points, create_vector((xo*c)-(yo*s), (xo*s)+(yo*c)))
  end
end

function _pvo_rotate_by(self, tau)
  local t = tau or 0
  self.angle += t
  self:rotate_to(self.angle)
end

function _pvo_locate(self, x,y)
  self.origin = create_vector(x, y)
end

function _pvo_draw(self)
  -- start a fresh line
  local ox, oy = self.origin.x, self.origin.y
  line(self.points[1].x+oy, self.points[1].y+oy, self.points[1].x+ox, self.points[1].y+oy)
  for i = 2,#self.points do
    -- connect the rest of the dots
    line(self.points[i].x+ox, self.points[i].y+oy)
  end
  -- connect back to initial dot
  line(self.points[1].x+ox, self.points[1].y+oy)
end

apply_angular_velocity = system({"angle", "angle_vel"}, function(e)
  -- keeps anything with an angle spinning
  -- for demonstration animation
  e:rotate_by(e.angle_vel)
end)

apply_angular_acceleration = system({"angle", "angle_vel", "angle_acc"},
function(e)
  e.angle_vel += e.angle_acc
  e.angle_acc = 0             -- zero out at the beginning of each frame
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
    -- rotation in pico-8 turns (aka: tau):
    angle = 0,    --scalar for angle
    angle_vel = 0,  --scalar for angular velocity
    angle_acc = 0,  --scalar for angular acceleration
    scale = 1,
    origin = create_vector(0,0),
    add_angular_force = _pv_add_angular_force,
    rotate_by = _pvo_rotate_by,
    rotate_to = _pvo_rotate_to,
    locate = _pvo_locate,
    visible = true,
    draw = _pvo_draw
  }
  return obj
end

function _oscillation_init()
  local baton_shape = {create_vector(10,0), create_vector(-10,0)}
  baton = create_polyvector_object(baton_shape)
  baton:locate(64,64)
  add(world, baton)
  osc_to_demo = "angle"
end

function _oscillation_update()
  -- ⬅️➡️⬆️⬇️❎🅾️
  if osc_to_demo == "angle" then
    if (btnp(⬅️)) baton:add_angular_force(-.01)
    if (btnp(➡️)) baton:add_angular_force( .01)
  end
  apply_angular_acceleration(world)
  apply_angular_velocity(world)
end

function _oscillation_draw()
  draw_polyvectors(world)
  rectfill(0, 109, 128, 128, 0)
  local p = print(osc_to_demo, 0, 110, 7)
  local ps = ""
  local as = ((baton.angle * 100) \ 1) /100
  if osc_to_demo == "angle" then ps = ":".. as .. " a_v:".. baton.angle_vel .. " a_a:"..baton.angle_acc end
  print(ps, p+2, 110)
end

chapters["oscillation"]={
 init=_oscillation_init,
 update=_oscillation_update,
 draw=_oscillation_draw,
 hint="new osc.: ⬆️⬇️  intensity: ⬅️➡️\nrandom: ❎  zero: 🅾️"
}
