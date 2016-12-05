require "jsonify" #store the inventory in JSON for the moment.

#Object containing each DB consumable item (malt, hops, yeast)
class DBItem
  def initialize(type, name, amount)
    data = Struct.new(:type, :name, :amount)
    @item = data.new(type, name, amount)
  end

  def printItem
    puts @item.type, @item.name, @item.amount.to_s, "\n"
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
        @db[i].printItem
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
