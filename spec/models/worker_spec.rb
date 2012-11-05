require 'spec_helper'

describe Worker do
  subject { build :worker }

  context "worker_type" do
    it "should set worker type" do
      subject.worker_type = :master
      subject.worker_type_id.should == 0
      subject.should be_valid
    end

    it "should read worker type" do
      subject.worker_type_id = 1
      subject.worker_type.should == :slave
    end

    it "should validate worker type" do
      subject.worker_type = :foo
      subject.should_not be_valid
    end
  end

  context "task" do
    it "should be serialized" do
      subject.task = {:name => "doing stuff"}
      subject.save!
      worker = Worker.find subject.id
      worker.task.should == {:name => "doing stuff"}
    end
  end

  context ".alive" do
    before do
      @w1 = create :worker, last_seen_at: Time.now
      @w2 = create :worker, last_seen_at: Time.now - Worker::PING_FREQUENCY
      @w3 = create :worker, last_seen_at: Time.now - Worker::PING_FREQUENCY*3
    end

    it { Worker.alive.all.to_set.should == [@w1, @w2].to_set }
    it { Worker.dead.all.should == [@w3] }
    it { @w1.alive?.should == true }
    it { @w3.alive?.should == false }

  end
end
