

#database object. strings DBItems together into an array to perform DB functionality
#obviously not fast, but brewers will rarely have more than ~100 items anyway
class OldDB
  #type is "recipe" or "consumable" depending on what DB objects you need
  def initialize (type, dbFileName)
    @db = Array.new
    @type = type
    @dbFileName = dbFileName
    import
  end

  def add(dataArray)
    if @type.eql? "recipe"
      item = DBrecipeItem.new(dataArray)
    elsif @type.eql? "consumable"
      item = Item.new(dataArray)
    end
    @db.push(item)
  end

  def print(*param)
    if(param.empty?)
      for item in @db
        item.print
      end
    end
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


#========================== FROM HERE DOWN ===========================================

#ITEM CLASS object for consumable items: malt, hops, yeast, etc
class Consumable
  def initialize(type, name, amount)
    @item = {type: type.upcase, name: name.upcase, amount: amount}
  end

  def outputData
    puts @item[:type] + "\n" + @item[:name] + "\n" + @item[:amount].to_s + "\n"
  end

  def print(*param)
    if(param.empty?)
      outputData
    else
      for term in param
        term = term.to_s.upcase
        if ((term.eql? @item[:type]) || (term.eql? @item[:name]))
          outputData
        end
      end
    end
  end #print

end #Item

#strings consumable Items together into an array.
#can be used to store a list of ingredients for either an inventory or a recipe
class ItemArray

  def initialize
    @items = Array.new
  end

  #accepts an item object to add to the array
  def add(item)
    @items.push(item)
  end

  def print(*param)
    for item in @items
      item.print(*param)
    end
  end #print

end #ItemArray class

#a Recipe is simply an array of consumable items with a method string
class Recipe
  #name and method are strings
  #items is an ItemArray object
  def initialize(name, items, method)
    @name = name.upcase
    @ingredients = items
    @method = method
  end

  def print
    puts @name + "\n" + "-----------\nINGREDIENTS:\n"
    @ingredients.print
    puts "METHOD:\n" + @method
  end
end #end recipe class

class DB
  def initialize(dbFileName)
    @recipes = Array.new
    @stock = Array.new
    @dbFileName = dbFileName
    #import
  end

  def import
  end #import

  def export
  end #export

  #adds an item to the DB (duh)
  #item is either a Recipe or Item object
  def add(item)
    if item.is_a?(Recipe)
      @recipes.push(item)
    elsif item.is_a?(Consumable)
      @stock.push(item)
    end
  end # add

  def find(query)
    query = query.upcase

  end #find

  def print(type)
    type = type.upcase
    if type.eql? "RECIPE"
      puts @recipes.length.to_s + " Recipe(s) on File\n=================="
      for recipe in @recipes
        recipe.print
      end
    elsif type.eql? "STOCK"
      for stock in @stock
        stock.print
      end
    end
  end #print

end #DB class

#testing...


hops = Consumable.new "hops","EK goldings",40
malt = Consumable.new "malt","Pale Ale",3500
malt2 = Consumable.new "malt","med crystal",250


itemDB = ItemArray.new
itemDB.add(hops)
itemDB.add(malt)
itemDB.add(malt2)

paleAle = Recipe.new "British Ale",itemDB,"Crush malt, mash, boil, add hops, yadda yadda yadda"

myDB = DB.new("somefile.file")
myDB.add(hops)
myDB.add(malt)
myDB.add(malt2)
myDB.add(paleAle)
myDB.print("RECIPE")
