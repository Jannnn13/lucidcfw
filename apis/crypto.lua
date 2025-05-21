local crypto = _ENV

local function xorByte(a, b)
  return bit.bxor(a, b)
end

local function toBytes(str)
  local bytes = {}
  for code in utf8.codes(str) do
    table.insert(bytes, code)
  end
  return bytes
end

local function fromBytes(bytes)
  local chars = {}
  for _, code in ipairs(bytes) do
    table.insert(chars, utf8.char(code))
  end
  return table.concat(chars)
end

function crypto.encode(seed, text)
  local seedBytes = toBytes(seed)
  local textBytes = toBytes(text)

  local resultBytes = {}
  for i = 1, #textBytes do
    local keyByte = seedBytes[(i - 1) % #seedBytes + 1]
    table.insert(resultBytes, xorByte(textBytes[i], keyByte))
  end

  return textutils.serialize(resultBytes)
end

function crypto.decode(seed, serialized)
  local seedBytes = toBytes(seed)
  local encodedBytes = textutils.unserialize(serialized)

  local resultBytes = {}
  for i = 1, #encodedBytes do
    local keyByte = seedBytes[(i - 1) % #seedBytes + 1]
    table.insert(resultBytes, xorByte(encodedBytes[i], keyByte))
  end

  return fromBytes(resultBytes)
end

return crypto
