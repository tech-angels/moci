require 'spec_helper'

describe ProjectPermission do
  it { should belong_to(:user) }
  it { should belong_to(:project) }
end
