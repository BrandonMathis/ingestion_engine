require 'spec_helper'

class InvitedUser < IngestionEngine::Entity
  computed_attrs :username
end

describe IngestionEngine::Entity do
  let(:csv) { File.open('spec/sample_csvs/users.csv') }
  let(:emails) { User.all.map(&:email) }
  let(:usernames) { User.all.map(&:username) }

  describe '#ingest_as' do
    it 'will ingest the csv' do
      IngestionEngine::Base.new(User, csv).ingest(as: InvitedUser)
      expect(User.count).to eq 3
    end
  end

  describe '#has_attribute' do
    it 'will define the custom attributes' do
    end
  end
end
