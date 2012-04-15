require 'spec_helper'

describe ProjectInstance do

  it "should properly lock" do
    project = Factory.create :project
    instance = Factory.create :project_instance, :project => project
    assert instance.try_to_acquire("foo")
    assert !instance.try_to_acquire("baz")
    instance.free!
    assert_nil instance.locked_by
    assert_nil instance.reload.locked_by
    assert instance.try_to_acquire("baz")
    assert_equal instance.locked_by, "baz"
    instance.free!
    assert_nil instance.locked_by
  end

  context "execute" do
    it "should collect output" do
      instance = Factory.create :project_instance
      output = ''
      assert instance.execute "echo 'this is test'", output
      lines = output.split("\n")
      assert lines[0].starts_with? '$' # first line is command being executed
      assert_equal lines[1], '' # second separating line
      assert_equal lines[2], 'this is test'
    end

    it "should track exit status" do
      instance = Factory.create :project_instance
      assert instance.execute("/bin/true")
      assert !instance.execute("/bin/false")
    end

    it "should raise on execute!" do
      instance = Factory.create :project_instance
      instance.execute!("/bin/true")
      assert_raise RuntimeError do
        instance.execute!("/bin/false")
      end
    end
  end

  context "VCS" do
    it "shuold properly create VCS handler object" do
      assert true
      project = Factory :project, :vcs_type => 'Git'
      instance = Factory :project_instance, :project => project
      Git.stub :open
      vcs = instance.vcs
      vcs.should be_kind_of(Moci::VCS::Base)
      vcs.should be_kind_of(Moci::VCS::Git)
      vcs.should respond_to(:checkout)
    end
  end

  context "Projcet handler" do
    it "shuold properly create project handler object" do
      assert true
      project = Factory :project, :project_type => 'Rails'
      instance = Factory :project_instance, :project => project
      ph = instance.project_handler
      ph.should be_kind_of(Moci::ProjectHandler::Base)
      ph.should be_kind_of(Moci::ProjectHandler::Rails)
      ph.should respond_to(:prepare_env)
    end
  end
end
