function printh_table(tbl, n)
  -- prints contents of a table, including subtables.
 local offset = 0 or n
 local o = ""
 for i=1,offset do
  o = o.."."
 end
 for k,v in pairs(tbl) do
  if type(v) == "table" then
   printh(o.."sub-table "..k)
   printh_table(v, offset+1)
  elseif type(v) != "function" then
   printh(o..k..": "..tostr(v))
  end
 end
end
