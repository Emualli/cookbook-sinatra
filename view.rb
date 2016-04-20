class View
  def display_recipes(recipes)
    recipes.each_with_index do |recipe, index|
      puts "#{index + 1}. #{recipe.name}: #{recipe.description}"
      puts "Temps de préparation: #{recipe.preparation_time} - Temps de cuisson: #{recipe.cooking_time}"
      puts "Note: #{recipe.note}/5 - Nombre de votes: #{recipe.number_of_votes}"
    end
  end

  def ask_user_for_index
    puts "Index?"
    print "> "
    return gets.chomp.to_i - 1
  end

  def ask_user_for(stuff)
    puts "#{stuff}?"
    print "> "
    return gets.chomp
  end

  def get_user_desire
    puts "Tell me - IN FRENCH - what recipes you want to research"
    print "> "
    return gets.chomp
  end

  def wanna_add_to_cookbook?
    re = puts "Wanna add these recipes to your cookbook? (y/n)"
    print "> "
    re = gets.chomp
    return re == 'y' ? true : false
  end

  def destroy_all?
    puts "ARE YOUR SURE ?!? :@ (y/n)"
    print "> "
    re = gets.chomp
    return re == 'y' ? true : false
  end

  def all_is_destroyed!(really)
    if really
      puts "You don't have any recipes now :'("
      puts "You're all alone"
    else
      puts "Pfiou! That was close"
    end
  end

  def show_more?
    puts "Do you wanna load MOAR recipes now? (y/n)"
    print "> "
    re = gets.chomp
    return re == 'y' ? true : false
  end
end
