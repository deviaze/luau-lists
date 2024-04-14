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
                  first = nil :: Node?,
                  last = nil :: Node?,
                  length = 0 :: number,
            }
      end
      
      List.ListInstance = {}

      function List.new(...) : List
            local newList = setmetatable(List.newList(), List.ListInstance) :: List
            newList.is_empty = true
            newList.length = 0 -- somehow need these for type inference? 
            for _, arg in {...} do
                  newList:append(arg)
            end
            return newList
      end

      export type List = typeof(List.new(...))
      

local ListInstance = List.ListInstance
      -- ListInstance.__index = ListInstance

      function ListInstance.insert(self : List, value : any) : ()
            
      end

      function ListInstance.__index(self : List, target_index : string | number | {number}) : any
            if typeof(target_index) == "number" then
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
                  return node_current.value
            elseif typeof(target_index) == "table" then
                  print("LinkedList[{number}] not implemented yet")
            end
            return rawget(ListInstance, target_index)
      end
      function ListInstance.__len(self : List)
            return self.length
      end

      --- O(1) LinkedList appends
      function ListInstance.append(self : List, ... : any) : ()
            for _, value in {...} do
                  local newNode = List.newNode(value)
                  if self.is_empty then
                        self.head = newNode
                        self.last = newNode
                        self.is_empty = false
                  elseif self.last then
                        self.last.next = newNode
                        self.last = newNode
                  end
                  self.length += 1
            end
      end



return List