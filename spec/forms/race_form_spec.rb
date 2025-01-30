require 'rails_helper'

RSpec.describe RaceForm do
  let(:student1) { create(:student) }
  let(:student2) { create(:student) }
  let(:student3) { create(:student) }

  describe 'validations' do
    it 'should not allow a race to be created without a title' do
      form = RaceForm.new(
        ActionController::Parameters.new(
          title: nil
        )
      )
      expect(form).not_to be_valid
      expect(form.errors[:title]).to include("can't be blank")
    end

    describe 'number of students' do
      it 'is invalid with less than 2 students' do
        form = RaceForm.new(
          ActionController::Parameters.new(
            title: 'Race 1',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 }
            }
          )
        )

        expect(form).not_to be_valid
        expect(form.errors[:base]).to include('A race must have at least 2 students')
      end

      it 'is valid with 2 or more students' do
        form = RaceForm.new(
          ActionController::Parameters.new(
            title: 'Race 1',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 },
              '1' => { student_id: student2.id, lane_number: 2 }
            }
          )
        )

        expect(form).to be_valid
      end
    end

    describe 'unique student ids' do
      it 'is invalid when the same student is assigned multiple times' do
        form = RaceForm.new(
          ActionController::Parameters.new(
            title: 'Race 1',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 },
              '1' => { student_id: student1.id, lane_number: 2 }
            }
          )
        )

        expect(form).not_to be_valid
        expect(form.errors[:base]).to include('A student can only enter the race once')
      end
    end

    describe 'single lane assignment' do
      it 'is invalid when multiple students are assigned to the same lane' do
        form = RaceForm.new(
          ActionController::Parameters.new(
            title: 'Race 1',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 },
              '1' => { student_id: student2.id, lane_number: 1 }
            }
          )
        )

        expect(form).not_to be_valid
        expect(form.errors[:base]).to include('Lane 1 has been assigned for more than one student')
      end
    end
  end

  describe '#initialize' do
    context 'with valid params' do
      let(:params) do
        ActionController::Parameters.new(
          title: 'Race 1',
          race_memberships: {
            '0' => { student_id: student1.id, lane_number: 1 },
            '1' => { student_id: student2.id, lane_number: 2 }
          }
        )
      end

      it 'creates a new race with race memberships' do
        form = RaceForm.new(params)
        
        expect(form.title).to eq('Race 1')
        expect(form.race.race_memberships.size).to eq(2)
        expect(form.race.race_memberships.first.student_id).to eq(student1.id)
        expect(form.race.race_memberships.first.lane_number).to eq(1)
        expect(form.race.race_memberships.last.student_id).to eq(student2.id)
        expect(form.race.race_memberships.last.lane_number).to eq(2)
      end
    end

    context 'with no params' do
      it 'creates an empty race' do
        form = RaceForm.new

        expect(form.title).to be_nil
        expect(form.race.race_memberships).to be_empty
      end
    end
  end
end
