--!strict
--!nolint LocalShadow

local tf, ptf = require('tf')

--- Parent class for custom typed Arrays and List datatypes 
local ArrayList = {}
      ArrayList.__index = ArrayList
      ArrayList.List = {}
      ArrayList.PairedList = {}

local List = ArrayList.List
      List.__index = List
      
      function List.newNode(value : any) : Node 
            return {
                  value = value,
                  next = nil :: Node?,
            }
      end
      export type Node = typeof(List.newNode(...))
      function List.newList()
            return {
                  head = nil :: Node?,
                  is_empty = true :: boolean,
                  first = nil :: any?,
                  last = nil :: any?,
                  length = 0 :: number,
            }
      end

      List.ListInstance = {}

      --[=[
            LinkedList default constructor
            ### Usage:
            ```lua
            local List = require("@/path_to/Lists")
            type List = List.List

            local newListy = List.new(1, 2, 3, "red", "blue", Instance.new("braincell"))
            ```
      ]=]
      function List.new<element>(...: element?)
            local newList = setmetatable(List.newList(), List.ListInstance) :: any
            newList.is_empty = true
            newList.length = 0 -- somehow need these for type inference? 
            for _, arg in {...} do
                  newList:append(arg)
            end
            return newList :: typeof(setmetatable(List.newList(), List.ListInstance)) -- average typehacks :cries: 
      end

      export type List<e> = typeof(List.new(...:: e))
      --- Constructs LinkedList from `{array-like-table}`
      function List.from<element>(array : {element}) : List<element>
            if array ~= nil then
                  return List.new(table.unpack(array))
            else
                  error("LinkedList.from(array) expected an array-like-table, but was called with no arguments or nil")
            end
      end

local PairedList = ArrayList.PairedList
local PairedListInstance = {}
      PairedListInstance.__index = PairedListInstance
      setmetatable(PairedListInstance, List.ListInstance)

--- new `LinkedList` from dictionary table
function PairedList.from<k,v>(dictionary: {[k]: v})
      if dictionary == nil then
            error("PairedList.from(dictionary) expected a table, but was called with no arguments or nil")
      end
      
      local newPairedList = List.new() :: any
      for key, value in dictionary do 
            newPairedList:append({key, value :: any})
      end
      -- for k, v in List.ListInstance do 
      --       if typeof(v) == "function" or k == "internal" then
      --             if PairedListInstance[k] ~= nil then
      --                   PairedListInstance[k] = v
      --             end
      --       end
      -- end

      newPairedList = setmetatable(newPairedList, PairedListInstance)
      return newPairedList :: typeof(setmetatable(List.newList(), PairedListInstance))
end
export type PairedList<k, v> = typeof(PairedList.from(...))

function PairedList.mapped<K,V>(dictionary: {[K]:V}, mapper: (key: K, value: V) -> (any?, any?))
      return PairedList.from(dictionary):map(function(key: K, value: V)
            local newK, newV = mapper(key, value)
            if newK and newV then
                  return newK, newV
            end
            return nil
      end)
end


--[=[
      Creates a new dictionary by mapping keys and values from an existing dictionary.
      ### Usage:
      ```lua
      local old_table = {
            grandpa = "Jimothy",
            grandma = "Samantha",
      }
      local new_table = List.remap_dictionary(old_table, function(title, name)
            return title:match("[..]$"), name.chars(1, 3)
      end)
      --- output --> new_table = {pa = "Jim", ma = "Sam"}
      ```
]=]
function PairedList.remap_dictionary<K, V, K2, V2>(dictionary: {[K]: V}, breakup: (key : K, value : V) -> (PairedListPair<K2,V2>?)) : {[K2]: V2}
      return PairedList.from(dictionary):table(breakup)
end

local ListInstance = List.ListInstance
      ListInstance.__index = ListInstance

      ListInstance.internal = {}

      function ListInstance.internal._append_value<E>(self: List<E>, value: E)
            local newNode = List.newNode(value)
            if self.is_empty then
                  self.head = newNode
                  self.first = newNode.value
                  self.last = newNode.value
                  self.is_empty = false
            else
                  local last_node = self.internal._get_node(self, self.length - 1)
                  assert(last_node)
                  last_node.next = newNode
                  self.last = newNode.value
            end
            if not self.length then
                  print(self)
            end
            self.length += 1
      end

      --[=[
            Appends one or many elements to `LinkedList`.
            ```lua
            newListy.append("tortoise")
            ```
      ]=]
      function ListInstance.append<E>(self : List<E>, ... : E | {any})
            if not self.length then
                  error(`LinkedList TypeError: expected self, got ({self}). Did you use a dot .append instead of :append ?`)
            end
            for _, value in {...} do
                  self.internal._append_value(self, value)
            end
            return self
      end

      --[=[
            retrieve value at index *(starts at 0)*
            ```lua
            local one = newList:get(0) -- gets the number 1 (0th index of array)
            local one = newList:at(0) -- same 
            local one = newList(0) -- same
            local last = newList(-1) -- negative indexes welcome
            ```
      ]=]
      function ListInstance.get<E>(self: List<E>, target_index): E?
            if target_index < 0 then
                  target_index = self.length + target_index -- turn our negatives upside-down :p
            end
            local node_at_index = self.internal._get_node(self, target_index)
            if node_at_index then 
                  return node_at_index.value
            else
                  return nil
            end
      end

      --- alias for Linkedlist:get(index: number)
      function ListInstance.at<E>(self: List<E>, ...: number): E?
            return self:get(...)
      end

      -- function ListInstance.__call<E>(self: List<E>, target_index : number): E?
      -- 	if target_index then
      --       	return self:get(target_index)
      --       else
      --       	return self
      --       end
      -- end

      function ListInstance.internal._get_node<E>(self : List<E>, target_index : number) : Node?
            if target_index >= self.length then
                  return nil -- index out-of-bounds
            end
            local index_current = 0
            local node_current = self.head :: Node
            while index_current < target_index do
                  index_current += 1
                  if node_current.next then
                        node_current = node_current.next
                  else
                        return nil
                  end
            end
            return node_current
      end

      --- check if value in LinkedList
      function ListInstance.has<E>(self: List<E>, value: any) : boolean
            return self:search(function(v)
                  return v == value
            end) :: boolean
      end

      function ListInstance.print<E>(self: List<E>) : List<E>
            print(self:__tostring())
            return self
      end

      --- pretty print for pretty Lists
      function ListInstance.pp<E>(self: List<E>): List<E>
            local pretty = tf(self:array(), true, {Prefix = "LinkedList", ArrayStartIndex = 0})
            print(pretty)
            return self
      end

      function ListInstance.__tostring<E>(self: List<E>)
      	return tf(self:array(), nil, {Prefix = "LinkedList", ArrayStartIndex = 0})
      end

      --- Conversions
      --- String representation with brackets
      function ListInstance.string<E>(self : List<E>)
            return tostring(self):gsub("LinkedList: ", "")
      end

      --- Converts LinkedList into regular {Array-Like-Table}. Alias for LinkedList:collect({})
      function ListInstance.array<E>(self: List<E>)
      	local indexedBy1 = self:collect({})
      	local result = {}
      	for index, value in indexedBy1 do
      		result[index - 1] = value
      	end
            -- return result
            return indexedBy1
      end

      --- remove node at index and return value
      function ListInstance.remove<E>(self: List<E>, target_index: number)
            local cached_node = nil :: Node?
            if target_index == 0 then
                  if self.head then
                        cached_node = self.head
                        if self.head.next then
                              self.head = self.head.next
                              self.first = self.head.value
                        end
                  end
            elseif target_index == self.length - 1 then
                  cached_node = self.internal._get_node(self, self.length - 1)
                  local last_node = self.internal._get_node(self, self.length - 2)
                  if last_node then last_node.next = nil end
                  assert(last_node)
                  self.last = last_node.value
            else
                  cached_node = self.internal._get_node(self, target_index)
                  local prev_node = self.internal._get_node(self, target_index - 1)
                  local next_node = self.internal._get_node(self, target_index + 1)
                  if prev_node then
                        prev_node.next = next_node
                  end
            end
            if cached_node then
                  self.length -= 1
                  if self.length == 0 then
                        self.is_empty = true
                  end
                  return cached_node.value
            else
                  return nil
            end
      end

      --[=[
            Removes and returns the first value in the LinkedList
            ```lua
            local popcorn = List.new("pop", "corn")
            local pop = popcorn:shift()
            ```
      ]=]
      function ListInstance.shift<E>(self: List<E>): E
            return self:remove(0)
      end
      
      --[=[
            Removes and returns the last value in the LinkedList
            ```lua
            local popcorn = List.new("pop", "corn")
            local corn = popcorn:pop()
            ```
      ]=]
      function ListInstance.pop<E>(self: List<E>): E
            return self:remove(self.length - 1)
      end

      --[=[
            ### Iterate through a LinkedList:
            note that LinkedLists start at index 0, not 1!
            ```lua
            local list = List.new("zeroth", "first", "second", "third")

            list:each(function(value, index) 
                  print(index .. value)
                  --> "0 .. zeroth" ...
            end)
            ```
      ]=]
      function ListInstance.each<E>(self: List<E>, onEach: (value : any, index : number) -> (), range : {number?}?)
            local min_index, max_index = 0, self.length
            if range then
                  if #range == 2 then
                        min_index, max_index = range[1] :: number, range[2] :: number
                  elseif #range == 1 then
                        max_index = range[1] :: number
                  end
            end
            local count = min_index
            while count < max_index do
                  onEach(self:get(count), count)
                  count += 1
            end
            return self
      end

      function ListInstance.search<E>(self: List<E>, query: (value: any, index: number?) -> (any), range: {number?}?): (E?, number?)
            local min_index, max_index = 0, self.length
            if range then
                  if #range == 2 then
                        min_index, max_index = range[1] :: number, range[2] :: number
                  elseif #range == 1 then
                        max_index = range[1] :: number
                  end
            end
            local count = min_index
            while count < max_index do
                  local response = query(self:get(count), count)
                  if response then
                        return response
                  end
                  count += 1
            end
            return nil
      end

      --[=[
            Equivalent to a map + filter. Generates a new `LinkedList` from your function `map`. Filtered by & including all truthy returns. 

            ```lua
            -- examples:
             -- subtract 1 from all (in new list)
                  local list = List.new(11, 21, 31, 41, 51, 61)

                  local list_one_less = list:map(function(value: number)
                        return value - 1
                  end):print()

             ---> output: "[LinkedList: 10, 20, 30, 40, 50, 60]"

             -- select only evens, subtract 10 from them, and then choose only those < 25
                  local numbers = List.new(1, 2, 5, 7, 8, 56, 21, 20, 40, 24, 489, 29, 28)

                  local evens_under_25 = numbers:map(function(n: number)
                        return n % 2 == 0 and (n - 10)
                  end):map(function(n)
                        return n < 25 and n
                  end):print()

             ---> output: "[LinkedList: -8, -2, 10, 14, 18]"

            ```
      ]=]
      function ListInstance.map<E>(self: List<E>, map: ((value: any, index: number) -> (any))?) : List<E>
            local mappedList = List.new()
            map = map or function(v,i)
                  if not v then return false
                  elseif typeof(v) == "string" and v:gsub(" ", "") == "" then
                        return false
                  elseif v == {} then
                        return false
                  end
                  return v
            end
            assert(map, " is a valid function")

            self:each(function(v, i)
                  local result = map(v, i)
                  if result then
                        mappedList:append(result)
                  end
            end)
            return mappedList
      end

      function ListInstance.match<E>(self: List<E>, matcher: string | (term : string) -> (boolean, string?), ... : string)
            if typeof(matcher) == "string" then
                  local matchers = {matcher, ...}
                  return self:map(function(value: string, index: number?)
                        for _, m in matchers do 
                              if value:match(m) then
                                    return value
                              end
                        end
                        return false
                  end)
            elseif typeof(matcher) == "function" then
                  return self:map(function(value: string, index: number?)
                        local filter, remapped_string = matcher(value)
                        if filter then
                              return if remapped_string then remapped_string else filter
                        end
                        return false
                  end)
            end
            error("LinkedList: provided matcher must be a string (string pattern) or function")
      end


      type yourFilterFunction <V,RType> = (value: V, index: number, collector: RType) -> (any?)

      --- Combines or reduces all values in your List into a single value—you decide. default operations: string: `..=`, number: `+=`, {array}: append `v`
      function ListInstance.collect<E, ReturnType>(self: List<E>, into: ReturnType, reducer: yourFilterFunction <E, ReturnType>?) : ReturnType
            reducer = reducer or function(v)
                  return v
            end
            assert(reducer, "LinkedList TypeError: invalid reduction/collection function.")

            self:each(function(v, index)
                  local result = reducer(v, index, into)
                  if not result then return end 

                  if typeof(into) == "string" then
                        into  ..= result
                  elseif typeof(into) == "number" then
                        into += result
                  elseif typeof(into) == "table" then
                        into[#into + 1] = result
                  end
            end)
            
            return into
      end
      --- returns sum of all elements. Assumes LinkedList[numbers]
      function ListInstance.sum(self: List<number>): number
            return self:collect(0)
      end

      -- note, this is a sort in place!
      function ListInstance.sort<E>(self: List<E>, sort_by : ((a: any, b: any) -> (boolean))?): List<E>
            local default_sort = function(a: number, b: number) return b > a end
            sort_by = sort_by or default_sort
            assert(sort_by, "")
            local prev : Node?
            
            -- just your average overnegineered recursive sort alg
            local changes = 0
            local curr_index, succ_index = 0, 1
            while succ_index < self.length do
                  local curr, succ = self.internal._get_node(self, curr_index), self.internal._get_node(self, succ_index)
                  assert(curr, self:string())
                  assert(succ, self:string())
                  if curr.value ~= succ.value and not sort_by(curr.value, succ.value) then
                        -- print(curr.value, "switching with", succ.value)
                        if prev then
                              prev.next = succ
                              curr.next = succ.next
                              succ.next = curr
                        else
                              self.head = succ
                              self.first = succ.value
                              curr.next = succ.next
                              succ.next = curr
                        end
                        changes += 1
                  end
                  prev = self.internal._get_node(self, curr_index)
                  curr_index += 1; succ_index += 1
            end
           
            if changes > 0 then
                  return self:sort(sort_by)
            else
                  return self
            end
      end

      function PairedListInstance.each<K,V>(self: PairedList<K,V>, for_each: (key: K, value: V, index: number) -> ()) : ()
            local self = self :: any
            local self = self :: List<any>

            local i = 0
            while i < self.length do 
                  local pair = self:get(i) :: {K & V}
                  if pair then
                        local key: K, value: V = pair[1], pair[2]
                        for_each(key, value, i)
                  end
                  i += 1
            end
      end

      type PairedListPair<K,V> = {[K]: V}
      function PairedListInstance.append<K, V>(self: PairedList<K,V>, ...: PairedListPair<K,V>)
            local self = self :: any
            local self = self :: List<any>

            for _, pair in {...} do
                  for key, value in pair do 
                        self.internal._append_value(self, {key, value :: any})
                  end
            end

      end

      function PairedListInstance.map<K, V, K2, V2>(self: PairedList<K, V>, map: (key: K, value: V, index: number?) -> (PairedListPair<K2,V2>?)) : PairedList<K2,V2>
            local mappedList = PairedList.from({}) :: PairedList<K2, V2>
            assert(map, " is a valid function")

            self:each(function(key, value, i)
                  local new_pair = map(key, value, i)
                  if new_pair then
                        mappedList:append(new_pair)
                  end
            end)
            return mappedList
      end
      --- maps a PairedList into a dictionary
      function PairedListInstance.table<K, V, K2, V2>(self: PairedList<K,V>, breakup: ((key : K, value : V, index: number) -> (PairedListPair<K2,V2>?))?): {[K2]: V2}
            local result = {}
            local mapper : (K, V) -> (PairedListPair<K2,V2>?) = breakup or function(k, v)
                  return {[k] = v}
            end
            assert(mapper, "splitting function must be provided")
            self:each(function(key: K, value: V, i: number)
                  local new_pair = mapper(key, value, i)
                  if new_pair then
                        for new_key, new_value in new_pair do 
                              result[new_key] = new_value
                        end
                  end
            end)
            return result
      end

      --[=[
            Remap each value in a PairedList.

            ```lua
            local animals = PairedList.from {
                  water = List.new("manatees", "dolphins", "sea otters"),
                  land = List.new("dogs", "cats", "elephants")
            }
            
            local animals_count = animals:map_values(function(habitat: string, animals: List<string>)
                  return animals:collect({}, function(animal: string, _, current: {[string]: number})
                        local initial_count = 10
                        if habitat == "land" then
                              initial_count *= 2
                        elseif habitat == "water" then
                              initial_count -= 5 -- marine mammals are endangered y'all
                        end
                        if animal ~= "dolphins" then
                              current[animal] = initial_count
                        end
                        return nil
                  end)
            end)

            animals_count:each(function(habitat, count_by_animal)
                  print(`{habitat}:`)
                  print(count_by_animal)
            end)

            --[[
                  water:
                  { manatees = 5, ["sea otters"] = 5 }
                  land:
                  { dogs = 20, cats = 20, elephants = 20 }
            ]]

            ```
      ]=]
      function PairedListInstance.map_values<K, V, V2>(self: PairedList<K,V>, mapper: (key: K, value: V) -> (V2?)): PairedList<K, V2>
            return self:map(function(key: K, value: V)
                  local result = mapper(key, value)
                  if result then
                        return {[key] = result}
                  end
                  return nil
            end)
      end

      --[=[
            Allows you to remap the array values in a `PairedList of Lists or arrays`.
            
            the array portion can be a regular {array} or a List!
            
            ```lua
            local arrays_by_key = {
                  part1 = {0, 1, 2, 3, 4},
                  part2 = {5, 5, 6, 9}
            }
            local remapped = PairedList.from(arrays_by_key):remap_array_values(function(value: number, _, _)
                  return value + 2
            end)

            remapped:each(function(key, value)
                  print(key, value)
            end)

            --[[
                  part1 {2, 3, 4, 5, 6}
                  part2 {7, 7, 8, 11}
            ]]
            ```
      ]=]
      function PairedListInstance.remap_array_values<K, V, VinA, V2inA>(self: PairedList<K, ({VinA} | List<VinA>)>, remapper: (value_in_array: VinA, array_index: number, outer_key: K) -> (V2inA?)) : PairedList<K, V>
            return self:map(function(outer_key: K, array_or_list: any)
                  if array_or_list.length then
                        local new_value = array_or_list :: List<VinA>
                        return {[outer_key] = new_value:map(function(old_value: VinA, inner_index)
                              return remapper(old_value, inner_index, outer_key)
                        end)}
                  elseif typeof(array_or_list) == "table" then
                        local result = {}
                        for i, v in array_or_list :: {VinA} do
                              local new_value = remapper(v, i, outer_key)
                              if new_value then
                                    table.insert(result, new_value)
                              end
                        end
                        return {[outer_key] = result}
                  end
                  error("PairedList: recieved invalid inner array type. PairedList:remap_array_values must remap either a List<element> or a regular table-like array {element}.")
            end :: (K, V) -> (PairedListPair<K, List<V2inA> | {V2inA}>))
      end
     
      local function pairedListIndexMapper<K, V>(key: K, value: V, index: number)
            local newKey = "[" .. tostring(index) .. "]: " .. (
            	if typeof(key) ~= "string" then
            		typeof(key) .. "(" .. tostring(key) .. ")"
            	else key
            )
            return {[index + 1] = {key = key, val = value}}
      end
      
      function PairedListInstance.print<K, V>(self: PairedList<K, V>) : PairedList<K,V>
      	print(tf(self:table(pairedListIndexMapper), false, {Prefix = "PairedList", ArrayStartIndex = 0}))
      	return self
      end
      function PairedListInstance.pp<K, V>(self: PairedList<K, V>) : PairedList<K,V>
      	print(tf(self:table(pairedListIndexMapper), true, {Prefix = "PairedList", ArrayStartIndex = 0}))
      	return self
      end
      function PairedListInstance.__tostring<K, V>(self: PairedList<K, V>) : string
      	return tf(self:table(), false, {Prefix = "PairedList"})
      end

      function ListInstance.__len<E>(self : List<E>): number
            return self.length
      end

return ArrayList