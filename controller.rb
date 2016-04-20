require_relative "view"
require_relative "recipe"
require "open-uri"
require 'nokogiri'

class Controller
  attr_accessor :start_by_keyword

  def initialize(cookbook)
    @cookbook = cookbook
    @view = View.new
    @start_by_keyword = {}
  end

  def list
    # 1. on demande la liste des recettes au repo
    recipes = @cookbook.all
    # 2. on l'envoie à la vue pour qu'elle les affiche
    @view.display_recipes(recipes)
  end

  def create
    # 1. demander à la view le name et la description
    name = @view.ask_user_for("Name")
    description = @view.ask_user_for("Description")
    # 2. on crée une instance de recette
    recipe = Recipe.new(name: name, description: description)
    # 3. on la rajoute au cookbook
    @cookbook.add_recipe(recipe)
  end

  def destroy
    # 0. demander au repo les recettes
    recipes = @cookbook.all
    # 1. on demande à la vue d'afficher les recettes
    @view.display_recipes(recipes)
    # 2. on demande à la vue de récupérer l'index de la recette à detruire
    index = @view.ask_user_for_index
    # 3. on l'envoie au cookbook pour qu'il la supprime
    @cookbook.remove_recipe(index)
    # 0. demander au repo les recettes
    recipes = @cookbook.all
    # 1. on demande à la vue d'afficher les recettes
    @view.display_recipes(recipes)
  end

  def destroy_all
    re = @view.destroy_all?
    @cookbook.remove_all if re
    @view.all_is_destroyed!(re)
  end

  def fetch_marmiton
    names = []
    descriptions = []
    preparation_times = []
    cooking_times_array = []
    votes = []
    note_count = 0
    notes = []

    html_keyword = @view.get_user_desire
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
    recipes_from_marmiton = []
    for i in (0..names.length)
      recipes_from_marmiton << Recipe.new(name: names[i], description: descriptions[i], preparation_time: preparation_times[i], cooking_time: cooking_times_array[i], number_of_votes: votes[i], note: notes[i])
    end
    @view.display_recipes(recipes_from_marmiton)
    re = @view.wanna_add_to_cookbook?
    if re
      recipes_from_marmiton.each do |r|
        @cookbook.add_recipe(r)
      end
    end
    if @view.show_more?
      start += 10
      @start_by_keyword[html_keyword] = start
      fetch_marmiton
    else
      return false
    end
  end
end
