class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @user = current_user
    if @user.nil?
      redirect_to user_session_path, flash: { alert: 'You must be signed in to continue.' }
    else
      @recipes = @user.recipes
    end
  end

  def new
    @recipe = Recipe.new
    @foods = Food.all
    @recipe.recipe_foods.build
    @user = current_user
  end

  def show
    @recipe = Recipe.find_by_id(params[:id])
    @recipe_foods = @recipe&.recipe_foods
    @recipe = 'No recipes' if @recipe.nil?
    @user = current_user
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user_id = current_user.id

    if @recipe.save
      flash[:notice] = 'Recipe created successfully'
      redirect_to recipes_path
    else
      render :new
      flash[:notice] = 'Error adding recipe'
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:success] = 'Recipe deleted!'
    redirect_to recipes_path
  end

  def public_recipes
    @recipes = Recipe.where(public: true)
  end

  def toggle_public
    @recipe = Recipe.find(params[:recipe_id])
    @recipe.toggle!(:public)
    redirect_to recipe_path(@recipe)
  end

  def general_shopping_list
    @user = current_user
    @recipes = @user.recipes
    @foods = {}

    # make foods like
    # {
    #  name: recipe_food Object
    # }
    # add quantities for same food
    @recipes.each do |recipe|
      recipe.recipe_foods.each do |recipe_food|
        if @foods.key?(recipe_food.food.name)
          @foods[recipe_food.food.name].quantity += recipe_food.quantity
        else
          @foods[recipe_food.food.name] = recipe_food
        end
      end
    end

    puts @foods

    # @recipes.each do |recipe|
    #   recipe.recipe_foods.each do |recipe_food|
    #     @foods << recipe_food
    #   end
    # end

    render 'shopping-list/index'
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :preparation_time, :cooking_time, :description, :public)
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
