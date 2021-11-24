-- Nature of Code
-- Chapter 3: Oscillation
-- see: https://natureofcode.com/book/chapter-3-oscillation/

-- requires 1-vectors.lua
-- and 2-forces.lua
-- but pico doesn't allow embedded #includes
-- so remember that for main.p8!



function _oscillation_init()
  local baton_shape = {create_vector(10,0), create_vector(-10,0)}
  baton = create_vector_object(baton_shape)
  baton:locate(64,64)
  osc_to_demo = "angle"
end

function _oscillation_update()
  -- ⬆️⬇️❎🅾️
  if osc_to_demo == "angle" then
    if (btnp(⬅️)) baton:rotate_by(-.01)
    if (btnp(➡️)) baton:rotate_by(.01)
  end
end

function _oscillation_draw()
  baton:draw()
  rectfill(0, 109, 128, 128, 0)
  local p = print(osc_to_demo, 0, 110, 7)
  local ps = ""
  if osc_to_demo == "angle" then ps = ": "..baton.angle end
  print(ps, p+2, 110)
end

chapters["oscillation"]={
 init=_oscillation_init,
 update=_oscillation_update,
 draw=_oscillation_draw,
 hint="new osc.: ⬆️⬇️  intensity: ⬅️➡️\nrandom: ❎  zero: 🅾️"
}

function create_vector_object(table_of_vectors)
  -- a polygonal object that can move and freely rotate
  -- like a ship in "asteroids"
  local obj = {
    -- mutable points that actually get drawn:
    shape = table_of_vectors or {},
    points = table_of_vectors or {},
    -- rotation in pico-8 turns (aka: tau):
    angle = 0,
    scale = 1,
    origin = create_vector(0,0),
    rotate_by = _vo_rotate_by,
    rotate_to = _vo_rotate_to,
    locate = _vo_locate,
    visible = true,
    draw = _vo_draw
  }
  return obj
end

function _vo_rotate_by(self, tau)
  local t = tau or 0
  self.angle += t
  self.angle = self.angle
  self:rotate_to(self.angle)
end

function _vo_rotate_to(self, tau)
  local c = cos(tau)
  local s = -sin(tau)
  self.points = {}
  for p in all(self.shape) do
    local xo, yo = p.x, p.y
    add(self.points, create_vector((xo*c)-(yo*s), (xo*s)+(yo*c)))
  end
end

function _vo_locate(self, x,y)
  self.origin = create_vector(x, y)
end

function _vo_draw(self)
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
