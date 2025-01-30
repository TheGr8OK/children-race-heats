require 'rails_helper'

RSpec.describe Race, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should have_many(:race_memberships).dependent(:destroy) }
    it { should have_many(:students).through(:race_memberships) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(live: 1, completed: 2) }
  end

  describe 'scopes' do
    describe '.for_list' do
      it 'returns races ordered by created_at DESC' do
        race_old = create(:race, created_at: 2.days.ago)
        race_new = create(:race, created_at: 1.day.ago)

        expect(Race.for_list).to eq([race_new, race_old])
      end
    end
  end

  describe '#members_preview' do
    it 'returns the first name of the first two students' do
      race = create(:race)
      create(:race_membership, race: race, student: create(:student, first_name: 'John', last_name: 'Doe'))
      create(:race_membership, race: race, student: create(:student, first_name: 'Jane', last_name: 'Smith'))
      expect(race.members_preview).to eq('John and Jane')
    end

    it 'returns the first name of the first student and the number of other students' do
      race = create(:race)
      create(:race_membership, race: race, student: create(:student, first_name: 'John', last_name: 'Doe'))
      create(:race_membership, race: race, student: create(:student, first_name: 'Jane', last_name: 'Smith'))
      create(:race_membership, race: race, student: create(:student, first_name: 'Alice', last_name: 'Johnson'))
      expect(race.members_preview).to eq('John and 2 more')
    end
  end

  describe '#student_count' do
    let(:race) { create(:race) }

    it 'returns the number of students in the race' do
      create_list(:race_membership, 3, race: race)
      expect(race.students.count).to eq(3)
    end
  end

  describe 'status transitions' do
    let(:race) { create(:race) }

    it 'defaults to live status' do
      expect(race).to be_live
    end

    it 'can transition from live to completed' do
      expect(race).to be_live
      race.completed!
      expect(race).to be_completed
    end
  end
end
