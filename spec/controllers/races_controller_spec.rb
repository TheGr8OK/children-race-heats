require 'rails_helper'

RSpec.describe RacesController, type: :controller do
  describe 'GET #index' do
    it 'assigns all races ordered by created_at DESC' do
      race1 = create(:race, created_at: 1.day.ago)
      race2 = create(:race, created_at: 2.days.ago)
      
      get :index
      
      expect(assigns(:races)).to eq([race1, race2])
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    let(:race) { create(:race) }

    it 'assigns the requested race' do
      get :show, params: { id: race.id }
      expect(assigns(:race)).to eq(race)
    end

    it 'renders the show template' do
      get :show, params: { id: race.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new race form' do
      get :new
      expect(assigns(:form)).to be_a(RaceForm)
      expect(assigns(:form).race).to be_a_new(Race)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:student1) { create(:student) }
    let(:student2) { create(:student) }
    
    context 'with valid parameters' do
      let(:valid_params) do
        {
          race_form: {
            title: 'Test Race',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 },
              '1' => { student_id: student2.id, lane_number: 2 }
            }
          }
        }
      end

      it 'creates a new race' do
        expect {
          post :create, params: valid_params
        }.to change(Race, :count).by(1)
      end

      it 'creates race memberships' do
        expect {
          post :create, params: valid_params
        }.to change(RaceMembership, :count).by(2)
      end

      it 'redirects to races path with success notice' do
        post :create, params: valid_params
        expect(response).to redirect_to(races_path)
        expect(flash[:notice]).to eq('Race was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          race_form: {
            title: '',
            race_memberships: {
              '0' => { student_id: student1.id, lane_number: 1 }
            }
          }
        }
      end

      it 'does not create a new race' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Race, :count)
      end

      it 'renders new template with unprocessable_entity status' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #submit_results' do
    let(:race) { create(:race) }

    it 'assigns the requested race' do
      get :submit_results, params: { id: race.id }
      expect(assigns(:race)).to eq(race)
      expect(assigns(:form)).to be_a(SubmitRaceResultsForm)
    end

    it 'renders the submit_results template' do
      get :submit_results, params: { id: race.id }
      expect(response).to render_template(:submit_results)
    end
  end

  describe 'POST #submit_results' do
    let(:race) { create(:race) }
    let!(:membership1) { create(:race_membership, race: race) }
    let!(:membership2) { create(:race_membership, race: race) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          id: race.id,
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '2' }
            }
          }
        }
      end

      it 'updates race memberships with places' do
        post :submit_results, params: valid_params
        
        membership1.reload
        membership2.reload
        expect(membership1.place).to eq(1)
        expect(membership2.place).to eq(2)
      end

      it 'marks race as completed' do
        post :submit_results, params: valid_params
        
        race.reload
        expect(race).to be_completed
      end

      it 'redirects to races path with success notice' do
        post :submit_results, params: valid_params
        expect(response).to redirect_to(races_path)
        expect(flash[:notice]).to eq('Race results were successfully submitted.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: race.id,
          submit_race_results_form: {
            race_memberships: {
              membership1.id.to_s => { place: '1' },
              membership2.id.to_s => { place: '' }
            }
          }
        }
      end

      it 'does not update race memberships' do
        post :submit_results, params: invalid_params
        
        membership1.reload
        membership2.reload
        expect(membership1.place).to be_nil
        expect(membership2.place).to be_nil
      end

      it 'does not mark race as completed' do
        post :submit_results, params: invalid_params
        
        race.reload
        expect(race).not_to be_completed
      end

      it 'renders submit_results template with unprocessable_entity status' do
        post :submit_results, params: invalid_params
        expect(response).to render_template(:submit_results)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end 