require 'spec_helper'

describe App do
  def app
    App.new
  end

  describe ':to mapping for all subdomains' do
    specify do
      request('http://foo.example1.com')
      last_response.body.should eq 'in users/foo'
      last_response.ok?.should be_true
    end
  end

  describe 'nested mapping with :except condition' do
    specify 'j' do
      request('http://example2.com')
      last_response.body.should eq 'in root'
      last_response.ok?.should be_true
    end
    specify do
      request('http://www.example2.com')
      last_response.body.should eq 'in root'
      last_response.ok?.should be_true
    end
    specify do
      request('http://downloads.example2.com')
      last_response.body.should eq 'in downloads'
      last_response.ok?.should be_true
    end
    specify do
      request('http://foo.example2.com')
      last_response.body.should eq 'in users/foo'
      last_response.ok?.should be_true
    end
  end

  describe ':to mapping with :only condition' do
    specify do
      request('http://www.example3.com')
      last_response.body.should eq 'in nested'
      last_response.ok?.should be_true
    end
    specify do
      request('http://example3.com')
      last_response.body.should eq 'in nested'
      last_response.ok?.should be_true
    end
  end
end
