class ListsController < ApplicationController
  
  before_action :set_list, except: [:index, :new, :create]
  before_action :authenticate_user!, except: [:index]

  def index
  	@lists = List.all
    @users = User.all
    @favourited_lists = FavouriteList.all
  end

  def show
    
  end

  def new
  	@list = List.new
    @list.todos.build
  end

  def edit
  end

  def create
    @list = current_user.lists.new list_params
  	@list.todos.each do |todo|
      todo.user_id = current_user.id
    end

  	if @list.save

  		redirect_to @list, notice: "List was successfuly created!"
  	else
  		render action: :new
  	end
  end

  def update
        
    respond_to do |format|
  	  if @list.update(list_params)
  	    format.html { redirect_to @list, notice: "List was successfuly updated!" }
        format.json {render :show, status: :ok, location: @list }
    	else
  	    format.html {render :edit }
        format.json {render json: @list.errors, status: :unprocessable_entity }
      end

      @list.close = true
      @list.todos.each do |todo|
        if !todo.close
          @list.close = false
        end
      end
      @list.update(list_params)
  	end
  end

  def destroy
  	@list.destroy
  	redirect_to lists_url, notice: "List was successfuly removed!"
  end

  def favourite
    type = params[:type]
    if type == "favourite"
      current_user.favourites << @list
      redirect_to :back
    elsif type == "unfavourite"
      current_user.favourites.delete(@list)
      redirect_to :back
    else
      redirect_to :back, notice: "Nothing happened."
    end
  end
      

  private

  def set_list
  	@list = List.find(params[:id])
  end

  def list_params
  	params.require(:list).permit(:title, :public, :close, todos_attributes: Todo.attribute_names.map(&:to_sym).push(:_destroy))
  end

end
