require 'spec_helper'

describe Result do

  let(:source) { Submission.all }
  let(:period) { 1.week }
  let(:start_date) { 1.week.ago.to_date }
  let(:sample) { subject.sample }

  # get some subs in there
  before(:each) do
    create_list(:submission, 10, created_at: 3.days.ago)
    create_list(:completed_submission, 10, created_at: 3.days.ago)
  end

  subject do
    Result.new source: source, period: period, start_date: start_date
  end

  describe '#to_param' do
    it 'should be Ymd' do
      subject.to_param.should == (start_date + period).strftime('%Y%m%d')
    end
  end

  describe '#empty?' do
    it 'should be sample.empty?' do
      sample = double
      sample.should_receive(:empty?) { 'foobar' }
      subject.stub(:sample) { sample }

      subject.empty?.should == 'foobar'
    end
  end

  describe '#sample' do
    it 'should be the result of querying the source within the given period' do
      subject.sample.should == subject.source.where('created_at >= ?', start_date.at_beginning_of_day).where('created_at <= ?', (start_date + period).at_end_of_day)
    end
  end

  describe '#rating' do
    it 'should be the average of all ratings' do
      ratings = sample.complete.map(&:rating)

      subject.rating.should == (ratings.sum.to_f / ratings.size).round(1)
    end
  end

  describe '#delta' do
    it 'should be the current rating minus the previous rating'
  end

  describe '#representation' do
    it 'should be sample/population' do
      subject.representation.should == Submission.complete.count.to_f / Submission.count
    end
  end

  describe '#comments' do
    it 'should be an array of Comments, sourced from the sample' do
      Submission.all.update_all comments: '', comments_public: false

      subs = Submission.all.sample(5)
      subs.each { |s| s.comments = 'foobar'; s.save! }

      subject.comments.size.should == 5
      subject.comments.map(&:class).uniq.should == [Comment]
    end
  end

  describe '#public_comments' do
    it 'should be an array of public Comments, sourced from the sample' do
      Submission.all.update_all comments: '', comments_public: false

      subs = Submission.all.sample(5)
      subs.each { |s| s.comments = 'foobar'; s.save! }

      subs = Submission.all.sample(3)
      subs.each { |s| s.comments = 'foobar'; s.comments_public = true; s.save! }

      subject.public_comments.size.should == 3
      subject.public_comments.map(&:class).uniq.should == [Comment]
      subject.public_comments.all?(&:public?).should be_true
    end
  end

  describe '#shortest_time_to_completion' do
    it 'should be a thing' do
      subject.shortest_time_to_completion.should_not be_nil
    end
  end

  describe '#previous' do
    context 'with no data' do
      it 'should be nil' do
        subject.previous.should be_nil
      end
    end

    context 'with data' do
      it 'should not be nil' do
        old_subs = create_list :submission, 7, created_at: start_date - period + 1.day
        subject.previous.sample.size.should == 7
      end
    end
  end

  describe '#next' do
    context 'with no data' do
      it 'should be nil' do
        subject.next.should be_nil
      end
    end

    context 'with data' do
      it 'should not be nil' do
        old_subs = create_list :submission, 6, created_at: start_date + period + 1.day
        subject.next.sample.size.should == 6
      end
    end
  end

end
