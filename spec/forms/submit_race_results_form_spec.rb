require 'rails_helper'

RSpec.describe SubmitRaceResultsForm do
  let(:race) { create(:race) }
  let(:student1) { create(:student) }
  let(:student2) { create(:student) }
  let(:student3) { create(:student) }
  let!(:membership1) { create(:race_membership, race: race, student: student1, lane_number: 1) }
  let!(:membership2) { create(:race_membership, race: race, student: student2, lane_number: 2) }
  let!(:membership3) { create(:race_membership, race: race, student: student3, lane_number: 3) }

  describe 'validations' do
    it 'is valid with proper consecutive places' do
      form = described_class.new(
        race: race,
        params: ActionController::Parameters.new(
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '2' },
              membership3.id.to_s => { place: '3' }
            }
          }
        )
      )

      expect(form).to be_valid
    end

    it 'is invalid when places are missing' do
      form = described_class.new(
        race: race,
        params: ActionController::Parameters.new(
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '' },
              membership3.id.to_s => { place: '3' }
            }
          }
        )
      )

      expect(form).not_to be_valid
      expect(form.errors[:place]).to include('must be present for all students')
    end

    it 'is invalid when places are less than 1' do
      form = described_class.new(
        race: race,
        params: ActionController::Parameters.new(
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '0' },
              membership2.id.to_s => { place: '1' },
              membership3.id.to_s => { place: '2' }
            }
          }
        )
      )

      expect(form).not_to be_valid
      expect(form.errors[:place]).to include('must be greater than 0')
    end

    context 'with ties' do
      it 'is valid with proper tie handling (two-way tie for first)' do
        form = described_class.new(
          race: race,
          params: ActionController::Parameters.new(
            submit_race_results_form: {
              race_memberships: {
                membership1.id.to_s => { place: '1' },
                membership2.id.to_s => { place: '1' },
                membership3.id.to_s => { place: '3' }
              }
            }
          )
        )

        expect(form).to be_valid
      end

      it 'is valid with proper tie handling (three-way tie for first)' do
        form = described_class.new(
          race: race,
          params: ActionController::Parameters.new(
            submit_race_results_form: {
              race_memberships: {
                membership1.id.to_s => { place: '1' },
                membership2.id.to_s => { place: '1' },
                membership3.id.to_s => { place: '1' }
              }
            }
          )
        )

        expect(form).to be_valid
      end

      it 'is valid with proper tie handling (tie for second place)' do
        form = described_class.new(
          race: race,
          params: ActionController::Parameters.new(
            submit_race_results_form: {
              race_memberships: {
                membership1.id.to_s => { place: '1' },
                membership2.id.to_s => { place: '2' },
                membership3.id.to_s => { place: '2' }
              }
            }
          )
        )

        expect(form).to be_valid
      end

      it 'is invalid with improper place sequence after tie' do
        form = described_class.new(
          race: race,
          params: ActionController::Parameters.new(
            submit_race_results_form: {
              race_memberships: {
                membership1.id.to_s => { place: '1' },
                membership2.id.to_s => { place: '1' },
                membership3.id.to_s => { place: '2' } # Should be 3 after a two-way tie for first
              }
            }
          )
        )

        expect(form).not_to be_valid
        expect(form.errors[:place]).to include('must be consecutive numbers starting from 1, or check the hint at the bottom of the page in case of a tie.')
      end
    end
  end

  describe '#save' do
    it 'saves all race memberships with their places when valid' do
      form = described_class.new(
        race: race,
        params: ActionController::Parameters.new(
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '2' },
              membership3.id.to_s => { place: '3' }
            }
          }
        )
      )

      expect(form.save).to be true
      
      membership1.reload
      membership2.reload
      membership3.reload
      
      expect(membership1.place).to eq 1
      expect(membership2.place).to eq 2
      expect(membership3.place).to eq 3
    end

    it 'returns false and does not save when invalid' do
      form = described_class.new(
        race: race,
        params: ActionController::Parameters.new(
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '' },
              membership3.id.to_s => { place: '3' }
            }
          }
        )
      )

      expect(form.save).to be false
      
      membership1.reload
      membership2.reload
      membership3.reload
      
      expect(membership1.place).to be_nil
      expect(membership2.place).to be_nil
      expect(membership3.place).to be_nil
    end
  end
end 