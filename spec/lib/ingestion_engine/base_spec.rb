require 'spec_helper'

class User < ActiveRecord::Base
  validates_presence_of :first_name
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
end

describe IngestionEngine::Base do
  describe '#ingest' do
    let(:csv) { File.open('spec/sample_csvs/users.csv') }
    let(:emails) { User.all.map(&:email) }
    let(:usernames) { User.all.map(&:username) }

    it 'saves the given items' do
      IngestionEngine::Base.new(User, csv).ingest
      expect(User.count).to eq 3
      expect(usernames).to include 'BeMathis'
      expect(usernames).to include 'Carrion'
      expect(usernames).to include 'durrhurrdurr'
      expect(emails).to include 'bemathis@gmail.com'
      expect(emails).to include 'carrion@gmail.com'
      expect(emails).to include 'durrhurrdurr@gmail.com'
    end

    context 'with missing attr that is required' do
      let(:csv) { File.open('spec/sample_csvs/users_with_missing_first_name.csv') }

      it 'does not save invalid items' do
        IngestionEngine::Base.new(User, csv).ingest
        expect(User.count).to eq 2
        expect(usernames).to include 'durrhurrdurr'
        expect(usernames).to include 'Carrion'
        expect(usernames).to_not include 'BeMathis'
      end

      it 'dumps the bad entry into invalid records csv' do
        IngestionEngine::Base.new(User, csv).ingest
        CSV.foreach('invalid.csv', {headers: true}) do |row|
          expect(row['username']).to eq 'BeMathis'
        end
      end
    end

    context 'with bad formatted email' do
      let(:csv) { File.open('spec/sample_csvs/users_with_bad_email.csv') }

      it 'dumps the bad entry into invalid records csv' do
        IngestionEngine::Base.new(User, csv).ingest
        invalids = CSV.parse(File.open('invalid.csv'), headers: true, header_converters: :symbol)
        expect(invalids[0][:username]).to eq 'BeMathis'
        expect(invalids[1][:username]).to eq 'Carrion'
        expect(invalids[0][:errors].strip).to eq 'Email is invalid'
        expect(invalids[1][:errors].strip).to eq 'Email is invalid'
      end
    end
  end
end
