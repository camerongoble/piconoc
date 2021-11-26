-- animal: frog
-- features:
-- frogs are larger than flies.
-- frogs make occasional ribbity soundss.
-- frogs occasionally hop in a forward-ish direction.
-- frogs tend to go in rapid bursts, but not often
-- frogs mostly sit still.
-- frogs will go out of their way for a fly.
-- frogs tend to go slowly, if at all
-- frogs bounce against the boundaries.

function spawn_frog(n)
  for i = 1,n do
    -- frogs tend to go in rapid bursts, but not often
    local frog_maxspeed = 3
    local frog_mindistance = 8
    local x,y = flr(rnd(sw)), flr(rnd(sh))
    -- the following definitions are game-specific
    -- they define the particular froggyness of frogs
    local frog = {
      qualia="frog",
      eats={"fly", "worm"},
      eating_range = 15, -- pixels
      visible = true,
      color = rnd({3,4,11}), --mostly green, a little brown
      size = 3, -- pixels
      facing = dir_vecs[rnd(dir)]:copy_vector(),
      hopdist = rnd(frog_mindistance)+frog_mindistance, -- 100%-150%
      time_to_recovery = rnd(300),
      -- main loop functions
      draw = _draw_frog,
      update = _update_frog,
      -- frogs make occasional ribbity soundss.
      sfx={idle={patch=10, probability = 600}}
    }
    -- the following definitions are for systemic movement
    -- they take advantage of the ECS framework for
    -- locating and moving objects :
    local attrs = {
      pos = create_vector(x, y),
      vel = create_vector(0, 0),
      acc = create_vector(0, 0),
      maxspeed = rnd(frog_maxspeed)+frog_maxspeed, --100%-150% px per frame,
      -- frogs bounce against the boundaries.
      -- (see resolve_position())
      boundary_behavior = "bounce"
    }
    -- make sure the frog object can use common movement operations:
    frog = bestow_movement(frog, attrs)
    add(world, frog)
  end
end

function _draw_frog(self)
  -- frogs are larger than flies.
  local trunk = self.size * 1.5
  local stretch = self.size * 1.3
  if self.vel:magnitude() > 0 then
    if self.dist_traveled <= stretch then
      -- the butt is still at the start point
      circfill(self.start.x, self.start.y, trunk, self.color)
    elseif self.dist_traveled > stretch then
      -- the butt needs to catch up
      local butt = self.vel:copy_vector() -- which way are we going?
      butt:limit(3) -- no more than some px lengths
      butt:scale_vector(-1) -- in the opposite direction
      butt:add_vector(self.pos) -- to the frog's current position
      circfill(butt.x, butt.y, s, self.color)
    end
  end
  circfill(self.pos.x, self.pos.y, self.size, self.color)

end

function hop(self)
  -- a frog is inspired to hop.
  -- look toward a space in front of the frog, set as a destination
  local hop_profile = self.facing:copy_vector()
  self.start = self.pos:copy_vector()
  hop_profile:scale_vector(self.hopdist) -- go the distance
  self.dist_intended = hop_profile:magnitude()
  local facc = hop_profile:copy_vector()
  facc:limit(self.maxspeed) -- but not too fast
  local dest = self.pos:copy_vector()
  dest:add_vector(hop_profile) -- get the desired position
  -- note where frog is heading so we can tell when we get there
  self.destination = dest
  -- accelerate the front toward the target
  add_force(self, facc)
  self.dist_traveled = 0
end

function _update_frog(self)
  -- The big choice right now is: to hop, or not to hop?
  -- later we can add eat/not eat, mate/not mate, etc
  -- or rest if we gotta
  if self.vel:magnitude() == 0 then
    -- no motion, so maybe start some?
    -- frogs mostly sit still.

    local movement_vector=create_vector(0,0)

    -- Consider player input (allowing for diagonal movement)
    if btn(0) then
      movement_vector:add_vector(dir_vecs.l)
    end
    if btn(1) then
      movement_vector:add_vector(dir_vecs.r)
    end
    if btn(2) then
      movement_vector:add_vector(dir_vecs.u)
    end
    if btn(3) then
      movement_vector:add_vector(dir_vecs.d)
    end

    -- If no player input, allow a chance of moving in a random direction
    if movement_vector:magnitude()==0 and rnd(160)<=1 then
      movement_vector:add_vector(dir_vecs[rnd(dir)])
    end

    -- Finally, do the movement
    if movement_vector:magnitude()~=0 then
      self.facing = movement_vector
      hop(self)
    else
      -- frogs make occasional ribbity sounds.
      -- (not mid-hop, though)
      play_psfx(self.sfx.idle)
    end
  else
    -- we're in-hop.  Find out how far we've gone and expected to go
    -- i did this with vector math at first, but it doesn't handle
    -- walls and collision behviors.  better to just add frame-by-frame
    self.dist_traveled += self.vel:magnitude()
    -- if we've gone farther than expected, then -hard stop-.
    if self.dist_traveled >= self.dist_intended then --we've arrived
      local stop = self.vel:copy_vector()
      stop:scale_vector(-1)
      add_force(self, stop)
      self.dist_traveled = 0
      -- later this will probably be replaced with a more clean "arrive" function
    end
  end
end
