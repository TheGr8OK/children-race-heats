class RacesController < ApplicationController
  before_action :set_race, only: [:submit_results, :show]
  before_action :set_form, only: [:new, :create]

  def index
    @races = Race.for_list
  end

  def show; end

  def new; end

  def create
    if @form.valid? && @form.race.save
      redirect_to races_path, notice: "Race was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def submit_results
    @form = SubmitRaceResultsForm.new(race: @race, params:)
    return unless request.post?

    if @form.save
      @form.race.completed!
      redirect_to races_path, notice: "Race results were successfully submitted."
    else
      render :submit_results, status: :unprocessable_entity
    end
  end

  private

  def set_race
    @race = Race.find(params[:id])
  end

  def set_form
    @form = RaceForm.new(race_form_params)
  end

  def race_form_params
    return nil unless params[:race_form]

    params.require(:race_form).permit(:title, race_memberships: {})
  end
end
