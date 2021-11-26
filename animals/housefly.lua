-- animal: housefly
-- chapter 1 features:
-- flies are tiny.
-- flies make annoying little sounds.
-- flies randomly hover around in all directions.
-- flies sometimes move fast, other times they linger.
-- flies bonk against the window infuriatingly.
-- chapter 2 features:
-- flies are repelled by frogs

function spawn_fly(n)
 for i = 1,n do
  local x,y = flr(rnd(sw)), flr(rnd(sh))
  -- the following definitions are game-specific
  -- they define the particular flyness of flies
  -- default fly
  -- adjust these parameters to make custom flies
  local f = {
   qualia="fly",
   visible = true,
   color = rnd({5,13}), --some shade of grayish
   attracted_to={"poop"},
   repelled_by={"frog"},
     -- flies make annoying little sounds.
   sfx = {boundary={patch=9, probability=100}}, -- larger numbers mean lower probabilities to play the patch e.g. 1 in 10
   -- main loop functions
   draw = _draw_fly,
   update = _update_fly
  }
  -- the following definitions are for systemic movement
  -- they take advantage of the ECS framework for
  -- locating and moving objects :
  local attr = {
    pos = create_vector(x, y),
    vel = create_vector(0, 0),
    acc = create_vector(0,0),
    maxspeed = rnd(1), --always in pixels per frame
    -- flies bonk against the window infuriatingly.
    -- (see resolve_position())
    boundary_behavior = "bonk"
  }
  f = bestow_movement(f, attr)
  add(world, f)
 end
end

function _draw_fly(self)
 -- flies are tiny.
 pset(self.pos.x, self.pos.y, self.color)
end

function _update_fly(self)
   -- flies randomly hover around in all directions.
  local d=rnd(dir)
    -- this streams a lot of disharmonious, cardinal unit vectors
    -- sequentially frame after frame, giving a twitchy, buzzy feel
    -- a truly random unit vector would be more subtle
    -- but flies aren't subtle :)
  self.acc:add_vector(dir_vecs[d])
   -- flies sometimes move fast, other times they linger.
  if self.feeling_swoopy then
   -- countdown to not be swoopy any more
   self.feeling_swoopy -= 1
   if self.feeling_swoopy == 0 then
    self.feeling_swoopy = nil
    self.maxspeed = rnd(1) -- okay, slow down
   end
  elseif flr(rnd(180))==1 then
   -- let's get swoopy!
   self.feeling_swoopy = flr(rnd(15)+15)  --for how many frames?
   self.maxspeed = rnd(3)+1  -- faster!  faster!  (for a while)
   end

end
