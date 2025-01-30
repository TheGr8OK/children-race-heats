require 'rails_helper'

RSpec.describe 'Race actions', type: :feature do
  describe 'race list page' do
    let!(:live_race) { create(:race, status: :live) }
    let!(:completed_race) { create(:race, status: :completed) }

    before do
      visit races_path
    end

    it 'shows submit results link for live races' do
      within("#race_#{live_race.id}") do
        expect(page).to have_link('Submit Results', href: submit_results_race_path(live_race))
      end
    end

    it 'does not show submit results link for completed races' do
      within("#race_#{completed_race.id}") do
        expect(page).not_to have_link('Submit Results')
        expect(page).to have_link('View Results', href: race_path(completed_race))
      end
    end
  end
end
