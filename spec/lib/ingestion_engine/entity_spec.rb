require 'spec_helper'

class InvitedUser < IngestionEngine::Entity
  computed_attrs :full_name, :token

  def full_name
    "#{object.first_name}#{object.last_name}"
  end

  def token
    SecureRandom.hex
  end
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
      IngestionEngine::Base.new(User, csv).ingest(as: InvitedUser)
      expect(User.first.full_name).to eq 'BrandonMathis'
    end
  end
end
