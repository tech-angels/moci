require 'spec_helper'

describe Project do
  subject { Factory :project }

  it { should validate_presence_of :name }
  it { should validate_presence_of :project_type }
  it { should validate_presence_of :vcs_type }

  context "project type"  do
    it { should allow_value("Rails").for :project_type }
    it { should_not allow_value("Foobar").for :project_type }
  end

  context "vcs type"  do
    it { should allow_value("Git").for :vcs_type }
    it { should_not allow_value("Moo").for :vcs_type }
  end
end
