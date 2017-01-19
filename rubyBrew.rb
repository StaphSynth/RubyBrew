require "yaml"

#object for consumable items: malt, hops, yeast, etc
class Consumable
  def initialize(type, name, amount)
    @item = {type: type.upcase, name: name.upcase, amount: amount}
  end

  #returns the data stored in the object as a string
  def to_s
    return "#{@item[:type]} #{@item[:name]} #{@item[:amount]}"
  end

  def print(*param)
    if(param.empty?)
      puts to_s
    else
      for term in param
        term = term.to_s.upcase
        if ((term.eql? @item[:type]) || (term.eql? @item[:name]))
          puts to_s
        end
      end
    end
  end #print

  #returns true if the Consumalbe object contains the term being looked for, else false
  def me?(term)
    term = term.upcase
    if((term.eql? @item[:type]) || (term.eql? @item[:name]))
      return true
    else
      return false
    end
  end #me?
end #Consumable

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

  def length
    return @items.length
  end

  def print(*param)
    for item in @items
      item.print(*param)
    end
  end #print

  def to_s
    string = ""
    for item in @items
     string += "#{item.to_s}\n"
    end
    return string
  end #to_s

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

  def to_s
    return "#{@name}\n#{@ingredients.to_s}#{@method}\n"
  end

  def print
    puts to_s
  end

  #returns true if the Recipe object's name matches the term being looked for, else false
  def me?(term)
    term = term.upcase
    if(term.eql? @name)
      return true
    else
      return false
    end
  end #me?
end #end recipe class




class DB
  def initialize(dbFileName)
    @recipes = Array.new
    @stock = Array.new
    @dbFileName = dbFileName
    #import
  end

  #returns the entire DB as a string
  def to_s
    string = "STOCK\n"
    for item in @stock
      string += "#{item.to_s}\n"
    end
    string += "RECIPES\n"
    for item in @recipes
      string += "#{item.to_s}\n"
    end
    return string
  end #to_s

  #adds an item to the DB (duh)
  #item is either a Recipe or Consumable object
  def add(item)
    if item.is_a?(Recipe)
      @recipes.push(item)
    elsif item.is_a?(Consumable)
      @stock.push(item)
    end
  end # add

  #imports DB from file. If no db file exists, it creates one
  def import
    if(File.exist? @dbFileName)
      dbFile = File.open @dbFileName, "r"
    #  self = YAML::load dbFile.read
    else
      dbFile = File.open @dbFileName, "w"
    end #if
    dbFile.close
  end #import

  def export
    dbFile = File.new @dbFileName, "w"
    dbFile.puts YAML::dump self
    dbFile.close
  end #export

  #returns an ItemArray of DB items that match a search query
  def find(query)
    found = ItemArray.new
    for recipe in @recipes
      if recipe.me?(query)
        found.add(recipe)
      end
    end
    for item in @stock
      if item.me?(query)
        found.add(item)
      end
    end
    if found.length > 0
      return found
    else
      return false
    end
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

smalt1 = Consumable.new "malt","wheat",3000
smalt2 = Consumable.new "malt","dark crystal",2000
s_hop1 = Consumable.new "hops","Galaxy",100


itemDB = ItemArray.new
itemDB.add(hops)
itemDB.add(malt)
itemDB.add(malt2)
# puts itemDB

paleAle = Recipe.new "British Ale",itemDB,"Crush malt, mash, boil, add hops, yadda yadda yadda"

myDB = DB.new("db.yaml")
myDB.add smalt1
myDB.add smalt2
myDB.add s_hop1
myDB.add(hops)
myDB.add(malt)
myDB.add(malt2)
myDB.add(paleAle)

myDB.export

# myDB.print("RECIPE")
# blah = myDB.find("british ale")
# blah.print
# myDB.print("STOCK")

serial = YAML::dump myDB
# puts serial + "\n\n"
db2 = DB.new "db.yaml"
db2 = YAML::load(File.open("db.yaml","r"){|f| f.read})
puts "DB2:\n#{db2}"

puts "\n\nTO_S TEST\n\n"
puts db2.to_s
