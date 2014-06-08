class ResultMetric
  include ActiveModel::Model

  attr_accessor :metric, :submission_metrics

  delegate :name, :slug, :description, to: :metric

  def count
    @count ||= submission_metrics.complete.count
  end

  def rating
    @rating ||= (submission_metrics.complete.map(&:rating).sum.to_f / count).round(1)
  end

  def confidence
    @confidence ||= (count.to_f / submission_metrics.count.to_f)
  end

  def comments
    @comments ||= begin
      submission_metrics.reject { |sm| sm.comments.blank? }.map do |sm|
        {
          user:    sm.user,
          content: sm.comments,
        }
      end
    end
  end

  def rating_counts
    @rating_counts ||= begin
      grouped_counts = submission_metrics.complete.group(:rating).count

      # represent the zero counts
      Hash[SubmissionMetric::VALID_RATINGS.map { |r| [r, 0] }].merge(grouped_counts)
    end
  end

end