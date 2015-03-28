require 'spec_helper'

describe IngestionEngine::Base do
  let(:csv) { 'spec/sample_csvs/users.csv' }
  let(:emails) { User.all.map(&:email) }
  let(:usernames) { User.all.map(&:username) }

  describe '#ingest' do
    it 'saves the given items' do
      IngestionEngine::Base.new(User, csv).ingest
      expect(User.count).to eq 3
      %w(BeMathis Carrion durrhurrdurr).each do |x|
        expect(usernames).to include x
      end
      %w(bemathis@gmail.com carrion@gmail.com durrhurrdurr@gmail.com).each do |x|
        expect(emails).to include x
      end
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
