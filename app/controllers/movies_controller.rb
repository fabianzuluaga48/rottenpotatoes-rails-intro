class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    # Handle rating filtering with session persistence
    if params[:ratings].present?
      # User provided new rating filters
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    elsif params.key?(:ratings) && params[:ratings].blank?
      # User unchecked all boxes - show all ratings
      @ratings_to_show = @all_ratings
      session[:ratings] = @all_ratings
    elsif session[:ratings].present?
      # No new params, use session values
      @ratings_to_show = session[:ratings]
    else
      # First visit, default to all ratings
      @ratings_to_show = @all_ratings
      session[:ratings] = @all_ratings
    end
    
    # Handle sorting with session persistence
    if params[:sort_by].present?
      # User provided new sort parameter
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present?
      # No new params, use session value
      @sort_by = session[:sort_by]
    else
      # No sorting preference
      @sort_by = nil
    end
    
    # Get filtered movies and apply sorting
    @movies = Movie.with_ratings(@ratings_to_show)
    
    if @sort_by.present? && ['title', 'release_date'].include?(@sort_by)
      @movies = @movies.order(@sort_by)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
