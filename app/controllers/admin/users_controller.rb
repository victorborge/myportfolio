class Admin::UsersController < ApplicationController
  include TreeGenerationForUsers
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.includes(:subscriptions).search(params[:search]).order(created_at: :desc).page(params[:page]).per(10)
  end


  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    @team = team_for @user
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1
  # PATCH/PUT /admin/users/1.json
  def update
    respond_to do |format|
      if user_params[:password].blank?
        filtered_params = user_params.except(:password)
      else
        filtered_params = user_params
      end

      if @user.update(filtered_params)
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :mobile_number, :nric, :address, :full_name, :password, :adjust_points, :recruiter_id, :leader_id)
  end
end
