
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
    puts @type, @name, @amount, "\n"
  end
end

#database object. strings DBItems together into an array to perform DB functionality
#obviously not fast, but brewers will rarely have more than ~100 items anyway
class ConsumableDB

  def initialize
    @db = Array.new
  end

  def add(type, name, amount)
    consumable = DBItem.new(type.upcase, name, amount)
    @db.push(consumable)
  end

  def print(type, *name)
    case type
    when "all" #print whole db
      for item in @db
        item.print
      end
    when "hops" #when "hops" print only hops
      for item in @db
        if item.type.eql? "HOPS"
          item.print
        end
      end
    when "yeast" #print all yeast in DB
      for item in @db
        if item.type.eql? "YEAST"
          item.print
        end
      end
    when "malt" #print all malt in DB
      for item in @db
        if item.type.eql? "MALT"
          item.print
        end
      end
    when "name" #for printing specific items by name
      if name[0] != nil
        for item in @db
          if item.name.eql? name[0]
            item.print
            break
          end
        end
      end
    end #end case
  end #end print

  def import #reads DB from file. *should create one if db doesn't already exist*
    dbFile = File.new("db.csv", "r")
    fileContents = dbFile.readlines
    puts fileContents[0]
    puts fileContents[1]
    dbFile.close
  end #end import

  def export #write DB to file
    dbFile = File.new("db.csv", "w")
    #do some stuff
    dbFile.close
  end #end export

end #end class ConsumableDB

#testing...
myDB = ConsumableDB.new
myDB.add("hops", "EK GOLDINGS", 100)
myDB.add("MALT", "Pale Ale", 15)
myDB.add "YEAST", "US-05", true
#myDB.print("all")
myDB.import
