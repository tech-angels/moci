require 'spec_helper'

describe User do
  subject { Factory :user }

  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
end
