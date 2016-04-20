require_relative 'cookbook'    # You need to create this file!
require_relative 'controller'  # You need to create this file!
require_relative 'router'
require_relative 'recipe'
require "sinatra"
require "pry-byebug"

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)
controller = Controller.new(cookbook)

router = Router.new(controller)

# # Start the app
# router.run

get '/' do
  erb :home
end

get '/recipes' do
  @recipes = cookbook.all
  erb :recipes
end

post '/recipes/delete' do
recipe_id = params[:recipe_id].to_i - 1
cookbook.remove_recipe(recipe_id)
redirect to "/recipes"
end

get '/recipes/new' do
  erb :new
end

get '/marmiton' do
  erb :marmiton
end

post '/recipes/done' do
  @recipe = Recipe.new(name: params[:name], description: params[:description])
  cookbook.add_recipe(@recipe)
  erb :done
end

# Reprise du code de fetch Marmiton from controller

post '/marmiton/fetch' do
  names = []
    descriptions = []
    preparation_times = []
    cooking_times_array = []
    votes = []
    note_count = 0
    notes = []
    @start_by_keyword = controller.start_by_keyword

    html_keyword = params[:type_recette]
    start = @start_by_keyword[html_keyword].nil? ? 0 : @start_by_keyword[html_keyword]
    html_file = "http://www.marmiton.org/recettes/recherche.aspx?aqt=#{html_keyword}&start=#{start}"
    response = open(html_file)
    html_doc = Nokogiri::HTML(response, nil, 'utf-8')
    html_doc.search('.m_titre_resultat > a').each do |n|
      names << n.attribute('title').to_s
    end
    html_doc.search('.m_texte_resultat').each do |d|
      descriptions << d.text[0...150] + '...'
    end
    html_doc.search('.m_prep_time').each do |preparation_time|
      preparation_times << preparation_time.next.to_s.gsub(/(\s|\smin)/, '').to_i
    end
    html_doc.search('.m_detail_time').each do |cooking_times|
      if cooking_times.at_css('.m_cooking_time')
        cooking_times_array << cooking_times.at_css('.m_cooking_time').next.to_s.gsub(/(\s|\smin)/, '').to_i
      else
        cooking_times_array << 0
      end
    end

    html_doc.search('.m_contenu_resultat').each do |c|
      note_count += 1  if c.at_css('.m_recette_note1')
    end

    html_doc.search('.m_contenu_resultat').each do |note2|
      notes << note_count
    end

    html_doc.search('.m_recette_nb_votes').each do |v|
      votes << v.text.to_s.gsub(/(\(|\))/, '').to_i
    end
    @recipes_from_marmiton = []
    for i in (0..names.length)
      @recipes_from_marmiton << Recipe.new(name: names[i], description: descriptions[i], preparation_time: preparation_times[i], cooking_time: cooking_times_array[i], number_of_votes: votes[i], note: notes[i])
    end
    erb :fetch
end


post '/marmiton/done' do
  binding.pry
  recipes_from_marmiton = params[:add_marmiton]
  recipes_from_marmiton.each do |r|
  cookbook.add_recipe(r)
  end
  erb :marmiton_added
end
