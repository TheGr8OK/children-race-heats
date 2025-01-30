class SubmitRaceResultsForm
  include ActiveModel::Model

  attr_accessor :race

  validate :submitted_results_format

  def initialize(race:, params:)
    @race = race
    @params = params
    @memberships_to_update = []
    return unless results_params.present?

    results_params.each do |id, result|
      membership = race.race_memberships.find(id)
      membership.place = result[:place]
      @memberships_to_update << membership
    end
  end

  def save
    return false unless valid?
    
    @memberships_to_update.all?(&:save)
  end

  private

  def results_params
    return {} unless @params[:submit_race_results_form]

    @params.dig(:submit_race_results_form, :race_memberships)
  end


  # In the case of a tie, the next available place should skip the number of tied students, for
  # example in the case of 2 ties for 1st, the next student cannot place 2nd but instead needs
  # to place 3rd (1, 1, 3). In the case of 3 ties for 1st, the next student must place 4th (1, 1, 1,
  # 4), and so on. This is also valid for ties in other places, e.g. (1, 2, 2, 4).
  def submitted_results_format
    if results_params.values.any? { |result| result[:place].blank? }
      errors.add(:place, "must be present for all students")
      return
    end

    if results_params.values.any? { |result| result[:place].to_i < 1 }
      errors.add(:place, "must be greater than 0")
      return
    end

    sorted_places = results_params.values.map { |result| result[:place] }.sort

    current_place = 1
    tie_count = 0
    sorted_places.each do |place|
      place = place.to_i
      if place == current_place
        current_place += 1
        tie_count = 0
      elsif place == (current_place - (tie_count + 1))
        current_place += 1
        tie_count += 1
      else
        errors.add(:place, "must be consecutive numbers starting from 1, or check the hint at the bottom of the page in case of a tie.")
      end
    end
  end
end
