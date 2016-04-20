require "csv"
require_relative "recipe"

class Cookbook
  def initialize(csv_file)
    @csv_file = csv_file
    @recipes = []
    load_csv
  end

  def add_recipe(recipe)
    @recipes << recipe
    save_to_csv
  end

  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
    save_to_csv
  end

  def all
    @recipes
  end

  def remove_all
    File.open(@csv_file, 'w') { |file| file.truncate(0) }
    @recipes = []
  end

  private

  def load_csv
    CSV.foreach(@csv_file) do |row|
      name = row[0]
      description = row[1]
      preparation_time = row[2]
      cooking_time = row[3]
      number_of_votes = row[4]
      note = row[5]
      @recipes << Recipe.new(name: name, description: description, preparation_time: preparation_time, cooking_time: cooking_time, number_of_votes: number_of_votes, note: note)
    end
  end

  def save_to_csv
    CSV.open(@csv_file, "wb") do |csv|
      @recipes.each do |recipe|
        csv << [recipe.name, recipe.description, recipe.preparation_time, recipe.cooking_time, recipe.number_of_votes]
      end
    end
  end
end












