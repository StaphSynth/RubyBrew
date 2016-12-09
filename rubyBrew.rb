
#Object containing each DB consumable item (malt, hops, yeast)
class DBconsumableItem
  def initialize(dataArray)
    @type = dataArray[0].upcase
    @name = dataArray[1].upcase
    @amount = dataArray[2].to_i
  end

  attr_reader :type
  attr_reader :name
  attr_reader :amount

  def outputData
    puts @type, @name, @amount
  end

  def print(*param)
    if(param.empty?)
      outputData
    else
      for term in param
        term = term.upcase
        if ((term.eql? @type) || (term.eql? @name))
          outputData
        end
      end
    end
  end
end

#database object. strings DBItems together into an array to perform DB functionality
#obviously not fast, but brewers will rarely have more than ~100 items anyway
class DB

  def initialize (dbFileName)
    @db = Array.new
    @dbFileName = dbFileName
    import
  end

  def add(dataArray)
    item = DBconsumableItem.new(dataArray)
    @db.push(item)
  end

  def print(type, *name)

  end #end print

  #returns the size of the db
  def size
    return @db.size
  end

  #reads DB from file. Creates a new db file if one doesn't already exist
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
          add(pieces)
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
#myDB = ConsumableDB.new


 #myDB.add("HOPS", "GOLDINGS", 100)
 #myDB.add("MALT", "TRAD ALE", 2400)
 #myDB.add("YEAST", "1968 Ale", 1)

#myDB.export

conItem = DBconsumableItem.new ["hops","EK goldings",100]
conItem.print
