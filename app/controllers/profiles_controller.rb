require 'rmagick'
class ProfilesController < ApplicationController
  include Magick
  include TreeGenerationForUsers
  before_action :authenticate_user!
  before_action :set_date_range, only: [:group_statistics, :chart]

  layout 'user'

  def home
    @posts = Post.order(created_at: :desc).page(params[:page]).per(5)
  end

  def events
    respond_to do |format|
      format.html {
        @events = Event.order(starts_at: :desc).page(params[:page]).per(20)
        @events = @events.where(id: params[:id]) if params[:id]
      }
      format.json {
        @events = Event.where(starts_at: params[:start]..params[:end]).order(starts_at: :asc)
      }
    end
  end

  def team_manager
    @team = team_for current_user
  end

  def chart
    @chart = [
        { name: 'Silver', data: [] },
        { name: 'Gold', data: [] },
        { name: 'Platinum', data: [] }
    ]

    (1..5).each do |level|
      users_for_level = current_user.find_all_by_generation(level).includes(:subscriptions).where(created_at: @start_date..@end_date).to_a
      @chart.each do |d|
        d[:data] << ["Tier #{level}", users_for_level.count { |u| u.current_plan == d[:name].downcase }]
      end
    end

    render json: @chart.to_json
  end

  def card
    rank = "gold"
    image = ImageList.new("app/assets/images/card_bg_#{rank}.png")
    text = Draw.new

    image.annotate(text,0,0,0,0, "#{current_user.full_name}    \n#{current_user.email}    \n") do
      text.gravity = Magick::SouthEastGravity
      text.pointsize = 38
      text.stroke_width = 1
      text.stroke = '#000000'
      text.fill = '#ffffff'
      text.font_family = 'Helvetica'
      text.font_weight = Magick::BoldWeight
    end

    image.format = 'png'

    disposition = params[:download] ? 'attachment' : 'inline'

    send_data image.to_blob, stream: false, filename: 'member_card.png', type: 'image/png', disposition: disposition
  end

  private

  def set_date_range
    if params[:all_time]
      @start_date = Time.at(0)
      @end_date = DateTime.tomorrow
      return
    end

    if params[:users]

      @start_date = Date.civil(params[:users][:"created_at_start(1i)"].to_i,
                               params[:users][:"created_at_start(2i)"].to_i,
                               params[:users][:"created_at_start(3i)"].to_i)

      @end_date   = Date.civil(params[:users][:"created_at_end(1i)"].to_i,
                               params[:users][:"created_at_end(2i)"].to_i,
                               params[:users][:"created_at_end(3i)"].to_i)
    end

    @start_date ||= Time.zone.now - 1.month
    @end_date ||= DateTime.tomorrow
  end
end
