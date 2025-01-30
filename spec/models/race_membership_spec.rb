require 'rails_helper'

RSpec.describe RaceMembership, type: :model do
  describe 'associations' do
    it { should belong_to(:race) }
    it { should belong_to(:student) }
  end

  describe 'validations' do
    it { should validate_presence_of(:lane_number) }
    it { should validate_numericality_of(:lane_number).is_greater_than(0) }
    
    describe 'lane_number uniqueness' do
      let(:race) { create(:race) }
      let!(:existing_membership) { create(:race_membership, race: race, lane_number: 1) }
      let(:new_membership) { build(:race_membership, race: race, lane_number: 1) }

      it 'validates uniqueness of lane_number within the scope of a race' do
        expect(new_membership).not_to be_valid
        expect(new_membership.errors[:lane_number]).to include("1 has been assigned for more than one student")
      end

      it 'allows the same lane_number in different races' do
        different_race = create(:race)
        new_membership.race = different_race
        expect(new_membership).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe '.for_list' do
      it 'returns race memberships ordered by place' do
        race = create(:race)
        third_place = create(:race_membership, race: race, place: 3)
        first_place = create(:race_membership, race: race, place: 1)
        second_place = create(:race_membership, race: race, place: 2)

        expect(RaceMembership.for_list).to eq([first_place, second_place, third_place])
      end
    end
  end
end
