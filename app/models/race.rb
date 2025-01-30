class Race < ApplicationRecord
  has_many :race_memberships, dependent: :destroy
  has_many :students, through: :race_memberships

  validates :title, presence: true
  
  enum status: {
    live: 1,
    completed: 2,
  }

  scope :for_list, -> { order(created_at: :desc) }

  def members_preview
    if students.count == 2
      "#{students.first.first_name} and #{students.last.first_name}"
    elsif students.count > 2
      "#{students.first.first_name} and #{students.count - 1} more"
    end
  end
end

