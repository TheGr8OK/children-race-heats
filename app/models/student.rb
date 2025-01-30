class Student < ApplicationRecord
  has_many :race_memberships
  has_many :races, through: :race_memberships

  def full_name
    "#{first_name} #{last_name}"
  end
end
