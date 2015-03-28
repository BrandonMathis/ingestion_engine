require 'spec_helper'

# TODO Maybe make this some kind of from_csv method on models
class User < ActiveRecord::Base
  include IngestionEngine::Ingestable
end

describe IngestionEngine::Ingestable do
  describe '.ingestable' do
    it { User.ingestable }
  end

  describe '#' do
  end
end
