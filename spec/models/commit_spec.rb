
require 'spec_helper'

describe Commit do

  context "short_number" do
    it "should be max 9 chars" do
      commit = Factory.build :commit, :number => '123456789012345'
      commit.short_number.should == '123456789'
    end
  end

  context "ordering do" do
    before :each do
      pr = Factory.create(:project)
      @c1 = Factory.create(:commit, :committed_at => 3.minutes.ago, :project => pr)
      @c2 = Factory.create(:commit, :committed_at => 2.minutes.ago, :project => pr)
      other_one = Factory.create(:commit, :committed_at => 1.minute.ago) # some commit in different project
      @c3 = Factory.create(:commit, :committed_at => 1.minute.ago, :project => pr)
    end

    it "should point to next commit properly" do
      @c1.next.should == @c2
      @c2.next.should == @c3
      @c3.next.should be_nil
    end

    it "should point to previous commit properly" do
      @c1.previous.should be_nil
      @c2.previous.should == @c1
      @c3.previous.should == @c2
    end
  end

  context "parents" do
    it "should have parents" do
      c1,c2,c3 = Array.new(3) { Factory.create :commit }
      c1.parents.should be_empty
      c1.parents << c2
      c1.reload.parents.should == [c2]
      c1.parents << c3
      c1.reload.parents.to_set.should == [c2, c3].to_set
    end

    it "should have children" do
      c1,c2,c3 = Array.new(3) { Factory.create :commit }
      c1.parents.should be_empty
      c1.parents << c2
      c2.reload.children.should == [c1]
      c3.parents << c2
      c2.reload.children.to_set.should == [c1, c3].to_set
    end

    it "should handle skipped commits properly in parents_without_skipped" do
      c1,c2,c3 = Array.new(3) { Factory.create :commit }
      c1.parents << c2
      c2.parents << c3
      c2.update_attribute :skipped, true
      c1.parents_without_skipped.should == [c3]
    end

    it "should handle skipped merge commits properly in parents_without_skipped" do
      c1,c2,c3,c4,c5,c6,c7 = Array.new(7) { Factory.create :commit }

      c1.parents << c2

      c2.parents << c3
      c2.parents << c4

      c3.parents << c5

      c4.parents << c6
      c4.parents << c7

      # one merge commit skipped
      c2.update_attribute :skipped, true
      c1.parents_without_skipped.to_set.should == [c3, c4].to_set

      # 2 merge commits skipped in a row
      c4.update_attribute :skipped, true
      c1.parents_without_skipped.to_set.should == [c3, c6, c7].to_set
    end
  end

  context "prepared?" do
    it "should be prepared if there's one instance commit and it's prepared" do
      pic = Factory :project_instance_commit, :state => 'prepared'
      pic.commit.prepared?.should == true
    end

    it "should be not prepared if there's one instance commit and it's not prepared" do
      pic = Factory :project_instance_commit, :state => 'preparation_failed'
      pic.commit.prepared?.should == false
    end

    # with uccernt design it should never be the case
    it "should not be prepared if there are no project instance commits" do
      commit = Factory :commit
      commit.prepared?.should == false
    end

    it "should be prepared if at least one instance commit is prepared" do
      commit = Factory :commit
      pic1 = Factory :project_instance_commit, :state => 'prepared', :commit => commit
      pic2 = Factory :project_instance_commit, :state => 'preparation_failed', :commit => commit
      commit.prepared?.should == true
    end
  end

  it "should return project instance commit when calling #in_instance" do
    pic = Factory :project_instance_commit
    pic.commit.in_instance(pic.project_instance).should == pic
  end

  it "should have an author" do
    author = Factory.build(:commit).author
    author.should be_kind_of Author
    author.name.should_not be_empty
    author.email.should_not be_empty
  end

end
