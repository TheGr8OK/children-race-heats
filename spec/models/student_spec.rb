require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'associations' do
    it { should have_many(:race_memberships) }
    it { should have_many(:races).through(:race_memberships) }
  end

  describe '#full_name' do
    it 'returns the combined first and last name' do
      student = create(:student, first_name: 'John', last_name: 'Doe')
      expect(student.full_name).to eq('John Doe')
    end

    it 'handles nil values' do
      student = create(:student, first_name: nil, last_name: nil)
      expect(student.full_name).to eq(' ')
    end
  end
end
