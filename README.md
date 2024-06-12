# The Luau Lists

### Oh yeah, a linked list right?
Yep, perfectly safe, healthy, and actually relatively typesafe pure Luau Typed LinkedLists... with more coming (eventually)

## Features
- LinkedLists for arrays and PairedLists for dictionaries
- ergonomic ruby-inspired functional API WITH TYPES :p
- extremely chainable
- like manipulating lists and like --!strict? don't look any farther.
- ~~did i mention 0-indexed~~

Please note this README may be outdated and doesn't show all available methods.
Use VSCode inline hints (or read Lists.luau) for the most complete documentation.
## LinkedList Api:
```luau
-- creating:
local newList = List.new(1, "all", "values", function() return "ok" end), "end")
local fromArray = List.from({1, 2, 3, 4, 5})

-- adding vals:
fromArray:append(6, 7, 8)

-- indexing
local one = newList:get(0) -- gets 0th index of the LinkedList
local one = newList:at(0) -- same

-- note that atm indexing[i] does not work because i'd have to sacrifice autocomplete to get newArray[index] to work without causing massive havoc
local one = newList.first 
local ennd = newList.last

-- iterating

fromArray:each(function(value: number, index: number?)
    -- like a for loop
end)

-- mapping

LinkedList:map(function(value: any, index: number?) : LinkedList
    -- combination of a map + filter in one! 
    -- non-nil values get added the new mapped array, nils don't
end)

LinkedList:collect(into: V, reducer: function(value, index: number, into: V) : V
    -- allows you to collect/reduce an array into a single value
    -- reducer function optional; by default you can use returns to
        -- append elements to an {array}, 
        -- concat strings
        -- and sum numbers
    -- you can use custom logic here and return different values and map them too
end)
```

## PairedList Api:
```luau
local Lists = require("@alias/Lists")
local PairedList = Lists.PairedList

local t = {
	ducks = 3,
	fs = require("@lune/fs"),
}

-- constructor

local newList = PairedList.from(t)

-- iterator
newList:each(function(key, value, index)
	print(key, value)
end)

-- mappers
type PairedListPair<K, V> = { [K]: V }
local mappedList = newList:map(function(key: K, value, index: number)
	local newKey = "new" .. tostring(key)
	local newVal = {index, value}
	return {[newKey] = newVal} -- note that PairedListPairs must be used in place of multiple returns in most PairedList Api.
end

local mappedListValues = newList:map_values(function(key: K, value, index: number)
	local newVal = {index, value}
	return newVal
end

```

## examples
```luau
local Lists = require("@alias/Lists")
local List, PairedList = Lists.List, Lists.PairedList

local matches = List.new("car", "door", ".luaurc", "from", "cat", "carlos", "firefly.luau", "listing", "catching", "caching", "dogathan", "meow")
    :match("^ca", "luau$", "^d", "ing$", "ow"):pp()
    :map(function(value: string)
          return value .. if not value:match("luau") then ".luau" else ""
    end):pp():array()
print(matches)
```
### output!
```ts
[LinkedList:
  [00]: car
  [01]: door
  [02]: cat
  [03]: carlos
  [04]: firefly.luau
  [05]: listing
  [06]: catching
  [07]: caching
  [08]: dogathan
  [09]: meow
]
[LinkedList: car.luau, door.luau, cat.luau, carlos.luau, firefly.luau, listing.luau, 
catching.luau, caching.luau, dogathan.luau, meow.luau]

↓ regular Lune {string} array ↓
{
    [1] = "car.luau",
    [2] = "door.luau",
    [3] = "cat.luau",
    [4] = "carlos.luau",
    [5] = "firefly.luau",
    [6] = "listing.luau",
    [7] = "catching.luau",
    [8] = "caching.luau",
    [9] = "dogathan.luau",
    [10] = "meow.luau",
}
```
## irl uses?:
```luau
-- usage example with Lune runtime??
local fs = require("@lune/fs")
local process = require("@lune/process")

local tests = List.from(fs.readDir("..")):match("spec.luau$")
      :map(function(file: string)
            return process.spawn("lune", {"run", file})
      end)
:each(function(test: process.SpawnResult)
      print(`{test.stdout}\n {test.stderr}`)
end)
```

## Install
just `clone the repo` (or copy and paste the main file), move files to your package manager directory, and just 
```luau
local Lists = require("@alias/Lists")
local List, PairedList = Lists.List, Lists.PairedList
type List = List.List
type PairedList = List.PairedList
-- and you should be all set
```

## Contributing guidelines
Please submit issues, prs, etc., it'd be most appreciated :p
