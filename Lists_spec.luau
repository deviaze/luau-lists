local List = require "Lists"

type List = List.List

type Test = {
      tip : string,
      call : (any) -> any,
}

local function newTest(tip, call) : Test
      return {
            tip = tip,
            call = call
      }
end

local function expect(test : Test, args, result)
      local r
      if typeof(args) == "table" then
            r = test.call(table.unpack(args))
      else
            r = test.call(args)
      end
      if result(r) then
            print(`test {test.tip} passed!`)
            return true
      end
      print(`test {test.tip} failed :?`)
      print(r)
      return false
end


local new : Test = {
      tip = "correctly makes a new LinkedList",
      call = List.new,
}

expect(new, {10, 20, 30}, function(result)
      if result.head.value == 10 and result.head.next.value == 20 and result.head.next.next.value == 30 then
            return true
      else
            return false
      end
end)
