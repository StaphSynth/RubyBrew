require "jsonify" #store the inventory in JSON for the moment.

#Object containing each DB consumable item (malt, hops, yeast)
class DBItem
  def initialize(type, name, amount)
    @type = type
    @name = name
    @amount = amount
  end

  attr_reader :type
  attr_reader :name
  attr_reader :amount

  def print
    puts @type, @name, @amount.to_s, "\n"
  end
end

#database object. strings DBItems together into an array to perform DB functionality
class ConsumableDB

  def initialize
    @db = Array.new
  end

  def add(type, name, amount)
    consumable = DBItem.new(type, name, amount)
    @db.push(consumable)
  end

  def print(type, *name)
    i = 0
    case type
    when "all" #print whole db
      for i in 0...@db.size
        @db[i].print
      end
    when "hops"
      for i in 0...@db.size
        if @db[i].type.eql? "HOPS"
          @db[i].print
        end
      end
    #when "hops" #print only hops


    end #end case

  end #end print

end #end class ConsumableDB

#testing...
myDB = ConsumableDB.new
myDB.add("HOPS", "EK GOLDINGS", 100)
myDB.add("MALT", "Pale Ale", 15)
myDB.print("all")
