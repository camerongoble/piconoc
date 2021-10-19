-- Entity Component System
-- See https://www.lexaloffle.com/bbs/?tid=30039

function _has(e, ks)
  for n in all(ks) do
    if not e[n] then
      return false
    end
  end
  return true
end

function system(ks, f)
  return function(es)
    for e in all(es) do
      if _has(e, ks) then
        f(e)
      end
    end
  end
end

-- To use it we'll need a collection of entities:
--
-- world = {}
--
-- add(world, {pos={x=32, y=64}, color=12})
-- add(world, {pos={x=64, y=64}, sprite=0})
-- add(world, {pos={x=96, y=64}, color=8, sprite=1})
-- Now we define a couple system functions, one for things with position and color components, and one for position and sprite.
--
-- circles = system({"pos", "color"},
--   function(e)
--     circfill(e.pos.x, e.pos.y, 8, e.color)
--   end)
--
-- sprites = system({"pos", "sprite"},
--   function(e)
--     spr(e.sprite, e.pos.x-4, e.pos.y-4)
--   end)
-- Finally, we call our systems on our entity collection:
--
-- function _draw()
--   cls()
--   circles(world)
--   sprites(world)
-- end
