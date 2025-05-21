---------------------------------------------------------------------
-- class.lua  –  Minimal object-oriented helper for Lua 5.1-5.4
---------------------------------------------------------------------
return function(base)
  -- Create a new table that will represent the class.
  local c = {}               -- the class
  local mt = { __index = c } -- instances delegate here

  -- Optional single inheritance
  if base then
    assert(type(base) == "table",
      "base class must be a table or nil")
    setmetatable(c, { __index = base }) -- class methods inherit
    c.__base = base
  end

  -----------------------------------------------------------------
  -- Constructor
  -----------------------------------------------------------------
  function c:new(...)
    local obj = setmetatable({}, mt)       -- create instance
    if obj.__init then obj:__init(...) end -- optional initializer
    return obj
  end

  -----------------------------------------------------------------
  -- Classic isinstance check
  -----------------------------------------------------------------
  function c:is_instance_of(t)
    local cls = getmetatable(self).__index
    while cls do
      if cls == t then return true end
      cls = cls.__base
    end
    return false
  end

  return c
end
