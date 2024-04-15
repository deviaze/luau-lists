--!strict
-- can't decide on whether Array or List so why not ArrayList fml


--- Parent class for custom typed Arrays and List datatypes 
local ArrayList = {}
      ArrayList.__index = ArrayList
      ArrayList.List = {}

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

      function List.new(...)
            local newList = setmetatable(List.newList(), List.ListInstance) :: any
            newList.is_empty = true
            newList.length = 0 -- somehow need these for type inference? 
            for _, arg in {...} do
                  newList:append(arg) -- please ignore the type error im tired
            end
            return newList :: typeof(setmetatable(List.newList(), List.ListInstance)) -- average typehacks :cries: 
      end

      export type List = typeof(List.new(...))

      --- new LinkedList from {array}
      function List.from(basic_array : {any})
            return List.new(unpack(basic_array))
      end
      function List.frompairs(dictionary: {[any]: any})
            local newPairedList = List.new() 
            for key, value in dictionary do 
                  newPairedList:append({key, value})
            end
            return newPairedList
      end
      function List.mappairs<K,V, I, J>(dictionary: {[K]: V}, breakup: (key : K, value : V) -> (I, J)) : {[I]: J}
            return List.frompairs(dictionary):topairs(breakup)
      end

local ListInstance = List.ListInstance
      ListInstance.__index = ListInstance

      --- O(1) LinkedList appends
      function ListInstance.append(self : List, ... : any) : ()
            if not self.length then
                  error(`LinkedList TypeError: expected self, got ({self}). Did you use a dot .append instead of :append ?`)
            end
            for _, value in {...} do
                  local newNode = List.newNode(value)
                  if self.is_empty then
                        self.head = newNode
                        self.first = newNode.value
                        self.last = newNode.value
                        self.is_empty = false
                  else
                        local last_node = self:__get_node(self.length - 1)
                        assert(last_node)
                        last_node.next = newNode
                        self.last = newNode.value
                  end
                  if not self.length then
                        print(self)
                  end
                  self.length += 1
            end
      end

      --- LinkedList:get(target_index: 0 to #LinkedList) and negative indices | aliases: get, at, __call
      function ListInstance.get(self: List, target_index)
            if target_index < 0 then
                  target_index = self.length + target_index -- turn our negatives upside-down :p
            end
            local node_at_index = self:__get_node(target_index)
            if node_at_index then 
                  return node_at_index.value
            else
                  return nil
            end
      end

      function ListInstance.at(self: List, ...)
            return self:get(...)
      end

      function ListInstance.__call(self: List, target_index : number)
            return self:get(target_index)
      end

      function ListInstance.__get_node(self : List, target_index : number) : Node?
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

     
      function ListInstance.print(self: List) : List
            print(self:__tostring())
            return self
      end

      function ListInstance.pp(self: List): List
            local output = "[LinkedList:\n"
            local middle = self:collect("", function(v, i)
                  local number_padding = if i < 10 then "0" else ""
                  return `  [{number_padding}{i}]: {v}\n`
            end) .. "]"
            print(output .. middle)
            return self
      end

      function ListInstance.__tostring(self: List)
            return `[LinkedList: {self:collect("", function(element, i)
                  return `{element}{
                        if i < self.length - 1 then ", " else ""
                  }` end)
            }]`
      end

      --- Conversions
      --- String representation with brackets
      function ListInstance.string(self : List)
            return tostring(self):gsub("LinkedList: ", "")
      end

      --- Array-Like-Table
      function ListInstance.table(self: List)
            return self:collect({})
      end

      --- remove node at index and return value
      function ListInstance.remove(self: List, target_index: number)
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
                  cached_node = self:__get_node(self.length - 1)
                  local last_node = self:__get_node(self.length - 2)
                  if last_node then last_node.next = nil end
                  assert(last_node)
                  self.last = last_node.value
            else
                  cached_node = self:__get_node(target_index)
                  local prev_node = self:__get_node(target_index - 1)
                  local next_node = self:__get_node(target_index + 1)
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

      function ListInstance.shift(self: List)
            return self:remove(0)
      end

      function ListInstance.pop(self: List)
            return self:remove(self.length - 1)
      end

      function ListInstance.each(self: List, onEach: (value : any, index : number?) -> (), range : {number?}?)
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
      end


      --- Equivalent to a map + filter. Generates a new LinkedList from your function `map`; includes all truthy returns. 
      function ListInstance.map(self: List, map: (value: any, index: number?) -> (any | nil)) : List
            local mappedList = List.new()
            self:each(function(v, i) 
                  local result = map(v, i)
                  if result then
                        mappedList:append(result)
                  end
            end)
            return mappedList
      end

      -- maps an array of [key, value] pairs into a dictionary
      function ListInstance.topairs(self: List, breakup: (key : any, value : any) -> (any, any))
            local result = {}
            self:each(function(pair, index)
                  local key, value = pair[1], pair[2]
                  local new_key, new_value = breakup(key, value)
                  result[new_key] = new_value
            end)
            return result
      end

      --- Combines or reduces all values in your List into a single value--you decide. default operations: string: `..=`, number: `+=`, {array}: append `v`
      function ListInstance.collect<T>(self: List, into : T, reducer: ((value: any, index : number?, into : T?) -> (any | nil))? ) : T
            local very_default_function = function(v) return v end
            reducer = reducer or very_default_function
            self:each(function(v, i)
                  assert(reducer, "")
                  local result = reducer(v, i, into)
                  if result then
                        if typeof(into) == "string" then
                              into ..= result
                        elseif typeof(into) == "number" then
                              into += result
                        elseif typeof(into) == "table" then
                              into[#into + 1] = result
                        end
                  end
            end)
            return into
      end

      function ListInstance.sum(self: List): number
            return self:collect(0)
      end

      -- note, this is a sort in place!
      function ListInstance.sort(self: List, sort_by : ((a: any, b: any) -> (boolean))?): List
            local default_sort = function(a: number, b: number) return b > a end
            sort_by = sort_by or default_sort
            assert(sort_by, "")
            local prev : Node?
            
            -- just your average overnegineered recursive sort alg
            local changes = 0
            local curr_index, succ_index = 0, 1
            while succ_index < self.length do
                  local curr, succ = self:__get_node(curr_index), self:__get_node(succ_index)
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
                  prev = self:__get_node(curr_index)
                  curr_index += 1; succ_index += 1
            end
           
            if changes > 0 then
                  return self:sort(sort_by)
            else
                  return self
            end
      end


      -- function ListInstance.__index(self, target_index)
      --       ListInstance.__index = ListInstance
      --       return ListInstance
      -- end

      -- function ListInstance.__index(self : List, target_index : string | number | {number}) : any
      --       if typeof(target_index) == "number" then
      --             print(self)
      --             if target_index >= self.length then
      --                   return nil -- index out-of-bounds
      --             end
      --             local index_current = 0
      --             local node_current = self.head :: Node
      --             while index_current < target_index do
      --                   index_current += 1
      --                   if node_current.next then
      --                         node_current = node_current.next
      --                   else
      --                         return nil
      --                   end
      --             end
      --             return node_current.value
      --       elseif typeof(target_index) == "table" then
      --             print("LinkedList[{number}] not implemented yet")
      --       end
      --       return rawget(getmetatable(self), target_index)
      -- end
      function ListInstance.__len(self : List)
            return self.length
      end

return List