require "yaml"
require "highline/import"
require "pry"

#object for consumable items: malt, hops, yeast, etc
class Consumable
  def initialize(type, name, amount)
    @item = {type: type.upcase, name: name.upcase, amount: amount}
  end

  #returns the data stored in the object as a string
  def to_s
    return "#{@item[:type]} #{@item[:name]} #{@item[:amount]}"
  end

  #returns only the name of the item as a string
  def name
    return "#{@item[:name]}"
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

  #returns true if the Consumable object contains the term being looked for, else false
  def me?(term)
    term = term.upcase
    if(term.eql? "*")
      return true
    elsif((term.eql? @item[:type]) || (term.eql? @item[:name]))
      return true
    else
      return false
    end
  end #me?

  #modifies the Consumable object (duh)
  #takes up to two parameters: a string for the name, and an integer for the amount
  def modify(*param)
    #rudimentary error checking. needs to be improved
    if param.empty?
      return false
    elsif param.length > 2
      return false
    end

    for parameter in param
      if parameter.is_a?(String)
        @item[:name] = parameter.upcase
      elsif parameter.is_a?(Integer)
        @item[:amount] = parameter
      end
    end #for
  end #modify
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

  #stringifies the recipe and returns the string
  def to_s
    return "#{@name}\n#{@ingredients.to_s}#{@method}\n"
  end

  #returns the name of the recipe as a string
  def name
    return "#{@name}"
  end

  def print
    puts to_s
  end

  #returns true if the Recipe object's name matches the term being looked for, else false
  def me?(term)
    term = term.upcase
    if(term.eql? "*")
      return true
    elsif(term.eql? @name)
      return true
    else
      return false
    end
  end #me?
end #end recipe class


class DB
  def initialize
    @stock = Array.new
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
  def self.import(filename)
    if(File.exist? filename)
      return YAML::load(File.open(filename,"r"){|file| file.read})
    else
      dbFile = File.open filename, "w"
      dbFile.close
    end #if
  end #import

  def export(filename)
    dbFile = File.new filename, "w"
    dbFile.puts YAML::dump self
    dbFile.close
  end #export

  #returns an array of DB items that match a search query
  def find(query, type = "ALL")
    found = Array.new
    if((type.eql? "ALL") || (type.eql? "RECIPE"))
      for recipe in @recipes
        if recipe.me?(query)
          found.push(recipe)
        end
      end
    end
    if((type.eql? "ALL") || (type.eql? "STOCK"))
      for item in @stock
        if item.me?(query)
          found.push(item)
        end
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

#used to generate choices in a selection menu based on what's in the db
#returns an array of strings that represent the choices available to the user
def generateChoices(query, db)
  choiceList = Array.new

  if(query.eql? "STOCK")
    #dump all the consumables in stock
    tempList = db.find("*","STOCK")
  elsif(query.eql? "RECIPE")
    #dump all the recipes
    tempList = db.find("*","RECIPE")
  else #otherwise, find the relevant stuff
    tempList = db.find(query)
  end

  for item in tempList
    choiceList.push(item.name)
  end

  return choiceList
end #generateChoices

#takes user input to assemble a list of consumable items and returns
#an array of the selected items. Used for assembling the items in recipes
def assembleItems(type, db)
  type = type.upcase
  items = Array.new
  im = HighLine.new
  #produce a list of items to choose from
  choiceList = generateChoices(type, db)
  choiceList.push("Create new #{type}")
  choiceList.push "DONE"
  #don't know how many items the user will require, so infinite loop until done, then return
  loop do
    im.choose do |item|
      item.prompt = "Select a #{type}: "
      item.choices(*choiceList) do |chosen|
        if chosen == choiceList.last #choiceList.last == DONE
          return items
        elsif chosen == choiceList[-2] #if create new
          newItem "STOCK", db
          choiceList = generateChoices(type, db)
          choiceList.push("Create new #{type}")
          choiceList.push("DONE")
        else
          items.concat(db.find(chosen))
          if((type.eql? "MALT") || (type.eql? "HOPS"))
            items.last.modify(items.last.name, ask("Please enter the amount of #{items.last.name} in grams: ", Integer))
          elsif(type.eql? "YEAST")
            return items
          end
        end #if
      end #|chosen|
    end #|item|
  end #loop
end #assembleItems

#generates the UI for selecting an item to modify
def modifyItemMenu(db)
  choose do |type|
    type.prompt = "Select an item type to modify: "
    type.choices("STOCK","RECIPE") do |typeChosen|
      choose do |item|
        item.prompt = "Select the item to modify: "
        item.choices(*generateChoices("#{typeChosen.upcase}", db)) do |itemChosen|
          db.modify(itemChosen)
        end #itemChosen
      end #item
    end #typeChosen
  end #type
end #modifyItem

#pass a string to indicate what sort of DB object you want it to make (recipe or stock).
#function takes user input, builds item and adds it to the db
def newItem(type, db)
  type = type.upcase
  responseArray = Array.new
  selectedItems = Array.new
  recipeItems = ItemArray.new
  stockTypes = ["MALT", "HOPS", "YEAST"]

  case type
  #uses user input to create a recipe object
  when "RECIPE"
    responseArray.push(ask("Recipe name: "))
    #cycle through the different stock types available and ask the user to make selections
    for stockType in stockTypes
      selectedItems.concat(assembleItems(stockType, db))
    end
    #stick all the selected items together into an ItemArray to create the new recipe
    for item in selectedItems
      recipeItems.add item
    end
    responseArray.push recipeItems
    responseArray.push(ask("Type the method: "))
    db.add Recipe.new *responseArray
    return
  #uses user input to create a Consumable object and add it to the db
  when "STOCK"
    tm = HighLine.new
    tm.choose do |stockType|
      stockType.prompt = "Select a stock category to add: "
      stockType.choices(*stockTypes) do |chosen|
        responseArray.push(chosen)
        responseArray.push(ask("Name of the item: "))
        responseArray.push(ask("Amount (in grams): ", Integer))
      end
    end
    db.add Consumable.new *responseArray
    return
  end #case
end #newItem

#function to add items to the db.
def add(db)
  am = HighLine.new
  selection = ["Add a consumable stock item", "Add a recipe"]
  loop do
    am.choose do |menu|
      menu.prompt = "What would you like to add? "
      menu.choices(*selection) do |chosen|
        case chosen
        when selection[0]
          newItem "STOCK", db
          return
        when selection[1]
          newItem "RECIPE", db
          return
        end #case
      end #|chosen|
    end #|menu|
  end #loop
end

#main menu and program control
def main(db)
  selection = ["View Database", "Add to Database", "Modify an Item", "Exit"]
  mm = HighLine.new
  loop do
    mm.choose do |menu|
      menu.header = "\nRUBY BREW v0.1\n============="
      menu.prompt = "What would you like to do?  "
      menu.choices(*selection) do |chosen|
        case chosen
        when selection[0]
          puts db.to_s
        when selection[1]
          add db
        when selection[2]
          modifyItemMenu db
        when selection.last
          db.export "db.yaml"
          exit
        end #case
      end #|chosen|
    end #|menu|
  end #loop
end

myDB = DB.new
myDB = DB.import "db.yaml"
main myDB
