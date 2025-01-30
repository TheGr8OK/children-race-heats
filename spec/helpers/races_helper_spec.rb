require 'rails_helper'

RSpec.describe RacesHelper, type: :helper do
  describe '#drawer' do
    it 'sets content for drawer title and content' do
      expect(helper).to receive(:content_for).with(:drawer_title, 'Test Title')
      expect(helper).to receive(:content_for).with(:drawer_content, kind_of(String))
      expect(helper).to receive(:turbo_stream).and_return(double(replace: true))
      
      helper.drawer('Test Title') { 'Test Content' }
    end
  end

  describe '#race_status' do
    let(:live_race) { create(:race, status: :live) }
    let(:completed_race) { create(:race, status: :completed) }

    it 'renders live status with correct icon' do
      result = helper.race_status(live_race)
      expect(result).to include('Live')
      expect(result).to include('text-lime-400')
    end

    it 'renders completed status with correct icon' do
      result = helper.race_status(completed_race)
      expect(result).to include('Completed')
      expect(result).to include('text-blue-500')
    end
  end

  describe '#student_place' do
    let(:student) { create(:student, first_name: 'John', last_name: 'Doe') }
    let(:race) { create(:race) }

    context 'when student finishes in 1st place' do
      let(:membership) { create(:race_membership, race: race, student: student, place: 1) }

      it 'renders icon with student name' do
        result = helper.student_place(membership)
        expect(result).to include('John Doe')
        expect(result).to include('<svg id="first"')
        expect(result).to_not include('1st')
      end
    end

    context 'when student finishes in a regular position' do
      let(:membership) { create(:race_membership, race: race, student: student, place: 4) }

      it 'renders ordinal number with student name' do
        result = helper.student_place(membership)
        expect(result).to include('John Doe')
        expect(result).to include('4th')
      end
    end
  end

  describe '#ordinal_suffix' do
    it 'returns correct suffix for numbers ending in 1' do
      expect(helper.send(:ordinal_suffix, 1)).to eq('st')
      expect(helper.send(:ordinal_suffix, 21)).to eq('st')
    end

    it 'returns correct suffix for numbers ending in 2' do
      expect(helper.send(:ordinal_suffix, 2)).to eq('nd')
      expect(helper.send(:ordinal_suffix, 22)).to eq('nd')
    end

    it 'returns correct suffix for numbers ending in 3' do
      expect(helper.send(:ordinal_suffix, 3)).to eq('rd')
      expect(helper.send(:ordinal_suffix, 23)).to eq('rd')
    end

    it 'returns th for numbers 11, 12, 13' do
      expect(helper.send(:ordinal_suffix, 11)).to eq('th')
      expect(helper.send(:ordinal_suffix, 12)).to eq('th')
      expect(helper.send(:ordinal_suffix, 13)).to eq('th')
    end

    it 'returns th for other numbers' do
      expect(helper.send(:ordinal_suffix, 4)).to eq('th')
      expect(helper.send(:ordinal_suffix, 10)).to eq('th')
      expect(helper.send(:ordinal_suffix, 24)).to eq('th')
    end
  end

  describe '#render_place_prefix' do
    it 'renders first place icon for 1st place' do
      result = helper.send(:render_place_prefix, 1)
      expect(result).to include('<svg id="first"')
    end

    it 'renders second place icon for 2nd place' do
      result = helper.send(:render_place_prefix, 2)
      expect(result).to include('<svg id="second"')
    end

    it 'renders third place icon for 3rd place' do
      result = helper.send(:render_place_prefix, 3)
      expect(result).to include('<svg id="third"')
    end

    it 'renders ordinal number for other places' do
      result = helper.send(:render_place_prefix, 4)
      expect(result).to include('4th')
      expect(result).to include('font-medium')
    end
  end
end
