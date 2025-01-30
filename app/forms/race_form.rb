class RaceForm
  include ActiveModel::Model

  attr_accessor :race

  delegate :title, :title=, to: :race

  validates :title, presence: true
  validate :number_of_students
  validate :unique_student_ids
  validate :single_lane_assignment

  def initialize(params = {})
    @race = Race.new
    @params = params
    return unless @params.present?

    %w[title].each do |attribute|
      send("#{attribute}=", @params[attribute]) if @params[attribute].present?
    end

    create_race_memberships
  end

  private

  def create_race_memberships
    return if race_memberships_params.blank?

    race_memberships_params.each do |race_membership|
      new_race_membership = @race.race_memberships.build
      race_membership.each do |key, value|
        new_race_membership.send("#{key}=", value)
      end
    end
  end

  def race_memberships_params
    return {} unless @params&.dig(:race_memberships)

    @params[:race_memberships].values.map { |membership| membership.permit(:student_id, :lane_number) }
  end

  def unique_student_ids
    student_ids = race_memberships_params.map { |membership| membership[:student_id] }
    if student_ids.uniq.count != student_ids.count
      errors.add(:base, "A student can only enter the race once")
    end
  end

  def single_lane_assignment
    lane_numbers = race_memberships_params.map { |membership| membership[:lane_number] }
    duplicate_lanes = lane_numbers.select { |lane| lane_numbers.count(lane) > 1 }.uniq
    if duplicate_lanes.any?
      errors.add(:base, "Lane #{duplicate_lanes.join(', ')} has been assigned for more than one student")
    end
  end

  def number_of_students
    errors.add(:base, "A race must have at least 2 students") if race_memberships_params.count < 2
  end
end
