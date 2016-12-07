
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
    @dbFileName = "db.csv"
    import
  end

  def add(type, name, amount)
    consumable = DBItem.new(type.upcase, name.upcase, amount.to_i)
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
          if item.name.eql? name[0].upcase
            item.print
            break
          end
        end
      end
    end #end case
  end #end print

  #returns the size of the db
  def size
    return @db.size
  end

  #reads DB from file. Creates a new db file one doesn't already exist
  def import
    #if db file exists, read contents, else create one
    if File.exist?(@dbFileName)
      dbFile = File.new(@dbFileName, "r")
      #read lines of file into array called fileContents
      fileContents = dbFile.readlines
      #take each line, split it by ',' marker, and pass the output to the add method
      for line in fileContents
        if line.size > 1 #if line size is 1, it can be discarded as irrelevant whitespace
          pieces = line.split(",")
          add(pieces[0], pieces[1], pieces[2])
        else
          break
        end #end if
      end #end for
    else
      dbFile = File.open(@dbFileName, "w")
    end #end if
    dbFile.close
  end #end import

  #write DB to file
  def export
    dbFile = File.new(@dbFileName, "w")
    #loop through DB and assemble each item into a comma-separated string ending in a \n
    #then write that line to the db file
    for item in @db
      line = item.type + "," + item.name + "," + item.amount.to_s
      # puts "Line to file: " + line
      dbFile.puts line
    end
    dbFile.close
  end #end export

end #end class ConsumableDB

#testing...
myDB = ConsumableDB.new


 #myDB.add("HOPS", "GOLDINGS", 100)
 #myDB.add("MALT", "TRAD ALE", 2400)
 #myDB.add("YEAST", "1968 Ale", 1)

myDB.export
