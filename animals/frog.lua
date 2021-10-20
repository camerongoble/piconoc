-- animal: frog
-- features:
-- frogs are a little larger than flies.
-- frogs make occasional ribbity soundss.
-- frogs occasionally hop in a forward-ish direction.
-- frogs mostly sit still.
-- frogs will go out of their way for a fly.
-- frogs tend to go slowly, if at all
-- frogs bounce against the boundaries.

function spawn_frog(n)
 for i = 1,n do
  local x,y = flr(rnd(sw)), flr(rnd(sh))
  -- default fly
  -- adjust these parameters to make custom frogs
  local f = {
   visible = true,
   color = rnd({3,4,11}), --mostly green, a little brown
   size = 3,
   pos = create_vector(x, y),
   vel = create_vector(0, 0),
   acc = create_vector(0, 0),
   maxspeed = rnd(10), --always in pixels per frame
   -- frogs bounce against the boundaries.
   -- (see resolve_position())
   boundary_behavior = "bounce",
   -- main loop functions
   draw = _draw_frog,
   update = _update_frog,
   -- frogs make occasional ribbity soundss.
   sfx={idle={patch=10, probability = 600}}
  }
  add(world, f)
 end
   add_caption("+"..n .. " frogs")
end

function _draw_frog(self)
-- frogs are a little larger than flies.
 circfill(self.pos.x, self.pos.y, self.size, self.color)
end

function _update_frog(self)
    -- frogs tend to go slowly, if at all
  local hop = self.vel:magnitude()
  if hop > 0 then
    -- come to a quick halt after a burst of acceleration
    local hop_stop = self.vel:copy_vector()
    hop_stop:scale_vector(-hop/5)
    add_force(self, hop_stop)
  end
  if hop < self.maxspeed /3 then
    -- if frog is slow enough, just come to a complete halt.
    -- (stops frogs from drifting)
    self.vel:set_magnitude(0)
  end
  -- frogs mostly sit still.
  -- no motion, so maybe start some?
  if (hop == 0 and rnd(30)<=1) then
    -- frogs occasionally hop in a forward-ish direction.
    -- right now, frogs just hop toward to the uppish.
    -- later we can add frog headings for local directionality
    local dv=dir_vecs[rnd({"u", "u", "u", "ul", "ur"})]
    local fd=dv:copy_vector()
    local s = rnd(self.maxspeed)   -- frogs tend to go slowly, if at all
    fd:scale_vector(s)
    add_force(self, fd)
  end
-- frogs make occasional ribbity sounds.
  play_psfx(self.sfx.idle)
end
