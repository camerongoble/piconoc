-- Nature of Code, Chapter 1
-- Vectors
-- See https://www.youtube.com/watch?v=bKEaK7WNLzM&list=PLRqwX-V7Uu6ZV4yEcW3uDwOgGXKUUsPOM&index=10

function create_vector(x,y)
  local v = {
    x=x,
    y=y,
    -- methods includions follow
    -- e.g. object:add_vector()
    -- see method definitions below
    copy_vector = _copyvec,
    add_vector = _addvec,
    sub_vector = _subvec,
    scale_vector = _scalevec,
    div_vector = _divvec,
    magnitude = _mag,
    set_magnitude = _setmag,
    normalize = _normvec,
    limit = _limitvec
  }
  return v
end

function create_random_vector(limit)
  -- returns a unit vector or within specified limits
  local limit = limit or 1
  local lx = rnd(limit*2)-limit
  local ly = rnd(limit*2)-limit
  return create_vector(lx, ly)
end

function add_force(e,fv)
  -- adds force vector to an entity's acceleration
  -- simple function written for code readability
  -- can be called multiple times per frame
  -- forces combine to single acceleration
  e.acc:add_vector(fv)
end

function to_target(sourceobj, targetobj)
  -- returns a vector to get from source to target
  -- if used as velocity, source arrives in 1 frame
  local sp = sourceobj.pos:copy_vector()
  local tp = targetobj.pos:copy_vector()
  tp:sub_vector(sp)
  return tp
end


-- method definitions
function _copyvec(self)
  --returns a copy of a vector for non-destructive manipulation
  local c = {}
  for k,v in pairs(self) do
    c[k] = v
  end
  return c
end

function _addvec(self,v)
  -- modifies/adds a vector to an existing vector.
  -- results in new absolute value to a relative change,
  -- like velocity added to position
  self.x += v.x
  self.y += v.y
end

function _subvec(self,v)
  -- modifies/subtracts a vector from an existing vector.
  -- results in relative difference to two absolute positions,
  -- like a velocity to go from one point to another
  self.x -= v.x
  self.y -= v.y
end

function _scalevec(self,s)
  -- modifies/scales a vector using multiplication
  self.x *= s
  self.y *= s
end

function _mag(self)
  -- returns a vector's magnitude using pythagoras
  local a,b = self.x,self.y
  local c = sqrt(a*a+b*b)
  return c
end

function _normvec(self)
  -- modifies/sets a vector magnitude to 1
  local m = self:magnitude()
  self.x /= m
  self.y /= m
end

function _setmag(self,s)
  -- modieifes/sets a vector magnitude to scale
  self:normalize()
  self:scale_vector(s)
end

function _limitvec(self,s)
  -- modifies/constrains a vector magnitude to a value
  -- no more than scale
  local m = self:magnitude()
  if m > s then self:set_magnitude(s) end
end

function _vectors_init()
   -- new object: a little blue ball
 ball = {visible = true,
         color = 12,
         pos=create_vector(rnd(sw),rnd(sh)),
         vel=create_vector(0,0),
         acc=create_vector(0,0),
         maxspeed=5,
         boundary_behavior = "bounce",
         target=center
        }
 add(world, ball)
 center.visible = true
 center.color = 14
end

function _vectors_update()
  -- generate some interesting sample accelerations to play with
  local rv = create_random_vector() -- nudge in some random direction
  local tv = to_target(ball, ball.target)
  tv:normalize() -- nudge toward target
  -- apply player input to the ball
  if btnp(❎) then add_force(ball, rv)  --random force
  elseif btnp(🅾️) then add_force(ball, tv) -- center force
  elseif btnp(⬆️) then add_force(ball,u)
  elseif btnp(⬇️) then add_force(ball,d)
  elseif btnp(⬅️) then add_force(ball,l)
  elseif btnp(➡️) then add_force(ball,r)
  end
end
