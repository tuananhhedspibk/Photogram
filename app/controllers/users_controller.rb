class UsersController < ApplicationController
	before_action :logged_in_user, only: [:edit, :update, :delete, :index]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: :destroy

	def index
		if(params[:search])
			@users = User.search(params[:search]).order('name ASC')
				.paginate(page: params[:page], per_page: 6)
		else
			@users = User.all.order('name ASC')
				.paginate(page: params[:page], per_page: 6)
		end
	end

	def new
		@user = User.new
	end

	def show
		@user = User.find_by(id: params[:id])
		if @user == nil
			not_found
		else
			@user1 = @user

			if params[:last_id]
				@microposts = @user.microposts.where("id < ? and user_id = ?", 
					params[:last_id], @user.id)
				render json: @microposts.as_json
			else
				@microposts = @user.microposts
			end
		end
	end

	def create
		@user = User.new(user_params)
		if @user.save
			log_in @user
			redirect_to @user
		else
			render 'new'
		end
	end

	def edit
		@user = User.find(params[:id])
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	private
		def user_params
			params.require(:user).permit(:name, :email, :gender, :password,
										 :password_confirmation, :avatar)
		end

		# Before filters

		# Confirms the correct user
		def correct_user
			@user = User.find_by(id: params[:id])
			if @user == nil
				not_found
			else
				redirect_to root_url unless current_user?(@user)
			end
		end
end