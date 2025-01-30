class RaceMembership < ApplicationRecord
  belongs_to :race
  belongs_to :student

  validates :lane_number, presence: true
  validates :lane_number, numericality: { greater_than: 0 }
  validates :lane_number, uniqueness: { scope: :race, message: ->(object, data) { "#{data[:value]} has been assigned for more than one student" } }

  scope :for_list, -> { order(place: :asc) }
end
