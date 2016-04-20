require_relative 'cookbook'    # You need to create this file!
require_relative 'controller'  # You need to create this file!
require_relative 'router'
require_relative 'recipe'
require "sinatra"

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)
controller = Controller.new(cookbook)
router = Router.new(controller)

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
  erb :recipe
end

post '/marmiton/add-recipe' do
  @link = "http://www.marmiton.org" + params[:link]

  # Je fetch la page en question sur Marmiton :
  html_file = @link
  response = open(html_file)
  html_doc = Nokogiri::HTML(response, nil, 'utf-8')
  # Name, description, preparation_time, cooking_time, number_of_votes, note, link
  # Name
  html_doc.search('.m_title > .item > .fn').each do |n|
    @name = n.text.to_s
  end
  # Description
  html_doc.search('.m_content_recette_todo').each do |c|
    @description = c.text.to_s
  end
  # Preparation time
  html_doc.search('.preptime').each do |p|
    @cooking_time = p.text.to_i
  end
  # Cooking time
  html_doc.search('.cooktime').each do |c|
    @prep_time = c.text.to_i
  end
  @new_recipe = Recipe.new(name: @name, description: @description, cooking_time: @cooking_time, preparation_time: @prep_time, link: @link)
  cookbook.add_recipe(@new_recipe)
  erb :marmiton_added
end

# Reprise du code de fetch Marmiton from controller

post '/marmiton/fetch' do
  names = []
  descriptions = []
  descriptions_long = []
  preparation_times = []
  cooking_times_array = []
  votes = []
  note_count = 0
  notes = []
  links = []

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
    descriptions << d.text[0...150]
  end
  html_doc.search('.m_texte_resultat').each do |d|
    descriptions_long << d.text
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
  html_doc.search('.m_titre_resultat > a').each do |link|
    links << link.attribute('href').to_s
  end
  @recipes_from_marmiton = []
  for i in (0..names.length)
    @recipes_from_marmiton << Recipe.new(name: names[i], description: descriptions[i], description_long: descriptions_long[i], preparation_time: preparation_times[i], cooking_time: cooking_times_array[i], number_of_votes: votes[i], note: notes[i], link: links[i])
  end
  erb :fetch
end


