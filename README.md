# The Luau Lists

### Oh yeah, a linked list right?
Yep, a perfectly safe, healthy, and actually relatively typesafe pure Luau Typed LinkedList... with more coming (eventually)

## Features
- easy as sin install and usage -- copy and paste and I'll eventually come out with a lune autoupdater
- extremely ergonomic ruby-inspired functional API WITH TYPES :p
- extremely chainable
- ~~did i mention 0-indexed~~
- like manipulating lists and like --!strict? don't look any farther.
- let me know how y'all like dependency management so i can figure out ez deployment

## api
```luau
-- creating:
local newList = List.new(1, "all", "values", function() return "ok" end), "end")
local fromArray = List.from({1, 2, 3, 4, 5})
local fromTable = List.frompairs({key = "value1", key2 = "val2"})

-- adding vals:
fromArray.append(6, 7, 8)

-- accessing (3 aliases)
local one = newList:get(0) -- gets the number 1 (0th index of array)
local one = newList:at(0) -- same 
local one = newList(0) -- same
local last = newList(-1) -- negative indexes welcome

-- note that atm indexing[i] does not work because i'd have to sacrifice autocomplete to get newArray[index] to work without causing massive havoc
local one = newList.first 
local ennd = newList.last

-- iterating

LinkedList:each(function(value: any, index: number?) : List
    -- like a for loop (and chainable) 
end)

-- mapping

LinkedList:map(function(value: any, index: number?) : List
    -- combination of a map + filter in one! 
    -- truthy values get added the new mapped array, falsey values (nil, false) don't
end)

LinkedList:collect(into: {any} | number | string, reducer: function(value, index: number?, into) 
    -- allows you to collect/reduce an array into a single value
    -- reducer function optional; by default you can use returns to
        -- append elements to an {array}, 
        -- concat strings
        -- and sum numbers
    -- you can use custom logic here and return different values and map them too
end)



```

##
```luau
local List = require("@pkg/Lists")

local matches = List.new("car", "door", ".luaurc", "from", "cat", "carlos", "firefly.luau", "listing", "catching", "caching", "dogathan", "meow")
    :match("^ca", "luau$", "^d", "ing$", "ow"):pp()
    :map(function(value: string)
          return value .. if not value:match("luau") then ".luau" else ""
    end):print():collect({})
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
local List = require("@alias/Lists")
type List = List.List
-- and you should be all set
```

## Contributing guidelines
Please submit issues, prs, etc., it'd be most appreciated :p
