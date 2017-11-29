local helper = {}

function helper.validate(self, required, params)
  for attrName, attrType in pairs(required) do
    local split = {}
    for i in string.gmatch(attrName .. '.', '(.-)%.') do
      table.insert(split, i)
    end
    local attr = split[1]
    local sub = split[2] or nil
    local rc = nil
    if attr ~= attrName then
      if type(params[attr]) == 'table' then
        rc = self:validate({ [sub] = attrType }, params[attr])
      end
    else
      if type(params[attr]) == attrType then
        rc = true
      end
    end
  end
  return rc
end

return helper
