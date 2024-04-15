--!nolint SameLineStatement
local List = require "Lists"

--[[
      this might not be the prettiest test suite you've seen
      will be fixed in post

      edit: inspired by rspec of course lol
]]

type List = List.List

-- makes a new list with all the right values do

local constructor = "constructor makes new list with all the right values" do
      local empty_constructor_works = "- List.new works with empty list" do 
            assert(List.new())
            print(empty_constructor_works)
      end
      local base_constructor_works = "- List.new works with multiple arguments" do 
            local new = List.new(10, 20, 30) 
            assert(new.head)
            assert(new.head.value == 10)
            assert(new.head.next)
            assert(new.head.next.value == 20)
            assert(new.head.next.next)
            assert(new.head.next.next.value == 30)
            print(base_constructor_works)
      end

      local fromArray = "knows how to make itself from array too" do 
            local test_array_list = List.from({1, 2, 3, 4, 5, 6}) do 
                  for i = 0, 5 do
                        assert(test_array_list:at(i) == i+1)
                  end
            end
            print(fromArray)
      end
      
      print(constructor)      
end



-- correctly indexes list do

local list_indexes = "indexes lists properly with all aliases\n" do 
      local passes_basic_indexing = "- passes basic :get and :__call indexing tests" do 
            local indexd = List.new(1, 3, 5, "text")
            assert(indexd:get(0) == 1)
            assert(indexd(2) == 5)
            assert(indexd:get(-1) == "text")
            assert(indexd(-2) == 5)
            print(passes_basic_indexing)
      end

      local osint = List.new("very", "special", "operation")
      local passes_additional_indexing = "- correctly indexes appends, last, etc" do 
            osint:append("10, 20", function() return 10 end) do
                  assert(osint.first == "very", `{osint.first}`)
                  assert(osint.last() == 10)
            end
            osint:append("spy cats") do 
                  assert(typeof(osint.last) ~= "function")
            end
            print(passes_additional_indexing)
      end

      local handles_removals_and_shifting = "- correctly .shift()s and handles element removal" do 
            local very = osint:shift() do
                  assert(very == "very")
                  assert(osint.first == "special" :: string)
                  assert(osint:at(10) == nil)
                  assert(osint:at(2) == "10, 20")
            end

            local sole_purpose_is_death_v2 = List.new("", "enemies", 12, 133) do 
                  assert(sole_purpose_is_death_v2:remove(1) == "enemies")
                  assert(sole_purpose_is_death_v2:pop() == 133)
                  assert(sole_purpose_is_death_v2:remove(0) == "")
                  assert(sole_purpose_is_death_v2:at(0) == 12)
                  assert(sole_purpose_is_death_v2.last == 12)
                  assert(sole_purpose_is_death_v2.first == 12)
                  assert(sole_purpose_is_death_v2:string() == "[12]")
                  assert(sole_purpose_is_death_v2:pop() == 12)
                  assert(sole_purpose_is_death_v2:string() == "[]")
                  assert(#sole_purpose_is_death_v2 == 0)
            end
            print(handles_removals_and_shifting)
      end
      print(list_indexes)
end


-- each works do

local each_works = "LinkedList.each iteration works!\n" do 
      local newArrayList = List.from({1, 2, 3, 4, 5, 6}) 
      newArrayList:each(function(value, index) 
            assert(value == newArrayList:at(index))
      end)
      print(each_works)
end


local conversions_work = "accurately converts list to {array} and back\n" do 
      local before = {10, 20, "hi", function() end, math.pi, string.char}
      local now_a_list = List.from(before)
      local back_from_listed = now_a_list:table()

      for i = 1, 6 do
            assert(back_from_listed[i] == before[i])
            -- comparing the arrays themselves with == doesn't work tho they have same elements; probs references yk
      end
      print(conversions_work)
end


-- making sure collect works with into passed along / not default argument returns

local mapping = "all LinkedList:map family methods work!!\n" do

      local array_filter_mapping = "-  LinkList:map works to map and filter arrays" do
            local old_array = List.new(1, 2, 3, 4, 6, 10, 12, 14)

            local new_array = old_array:map(function(value: number, index: number)
                  if value > 1 and value <= 6 then
                        return `{value}{old_array:at(index - 1)}`
                  elseif value == 4 then
                        return false -- also works as filter for falsey values 
                  elseif value > 10 then
                        return value + 5
                  end
                  return false
            end)
      
            assert(tostring(new_array) == "[LinkedList: 21, 32, 43, 64, 17, 19]")

            assert(new_array:string() == "[21, 32, 43, 64, 17, 19]")
            print(array_filter_mapping)
      end
      
      local collection_summation = "-  collect and sum/etc are passing" do 
            local sum = List.new(10, 20, 40, 12.5):collect(0, function(v) return v end)
            local sum2 = List.new(10, 20, 40, 12.5):collect(0)
            assert(sum == 82.5)
            assert(sum2 == sum)

            assert(List.new(10, 2, 3):collect(0, function(v, i)
                  if i % 2 == 0 then
                        return v
                  end
                  return false
            end) == 13)
            print(collection_summation)
      end

      local mapped_pairs = "-  mappairs correctly maps List to dictionaries" do 
            local stats = {
                  John = {
                        10, 20, 40, 60, 42, 20,
                  },
                  Sally = {
                        12, 14, 53, 12, 0, 21, 42
                  },
                  thor = {
                        12, 0, 0, 123, 127, 92,
                  }
            }
      
            local points = List.mappairs(stats, function(key : string, values)
                  return key, List.from(values):sum()
            end)
      
            assert(points.John == 192)
            assert(points.Sally == 154)
            assert(points.thor == 354)
            print(mapped_pairs)
      end
      print(mapping)

      local match_map_for_strings = "-  correctly handles default match map/filtering" do 
            local matches = List.new("car", "door", ".luaurc", "from", "cat", "carlos", "firefly.luau", "listing", "catching", "caching", "dogathan", "meow")
            :match("^ca", "luau$", "^d", "ing$", "ow")
            :map(function(value: string)
                  return value .. if not value:match("luau") then ".luau" else ""
            end):string()
            assert(matches == "[car.luau, door.luau, cat.luau, carlos.luau, firefly.luau, listing.luau, catching.luau, caching.luau, dogathan.luau, meow.luau]")
            print(match_map_for_strings)
      end
end

local sorting_works = "default LinkedList:sort() works" do 
      local sorty = List.new(2, 3, 7, 5, 5, 2)
      assert(sorty:sort():string() == "[2, 2, 3, 5, 5, 7]", sorty:string())
      print(sorting_works)
end
