class Recipe
  attr_reader :name, :description, :description_long, :preparation_time, :cooking_time, :number_of_votes, :note, :link

  def initialize(attributes = {})
    @name = attributes[:name]
    @description = attributes[:description]
    @description_long = attributes[:description_long]
    @preparation_time = attributes[:preparation_time]
    @cooking_time = attributes[:cooking_time]
    @number_of_votes = attributes[:number_of_votes]
    @note = attributes[:note]
    @link = attributes[:link]
  end
end
