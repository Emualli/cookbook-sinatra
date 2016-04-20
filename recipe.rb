class Recipe
  attr_reader :name, :description, :preparation_time, :cooking_time, :number_of_votes, :note

  def initialize(attributes = {})
    @name = attributes[:name]
    @description = attributes[:description]
    @preparation_time = attributes[:preparation_time]
    @cooking_time = attributes[:cooking_time]
    @number_of_votes = attributes[:number_of_votes]
    @note = attributes[:note]
  end
end
