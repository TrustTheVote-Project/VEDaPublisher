class Vedastore::BallotSelection < ActiveRecord::Base
  def totals
    self.counts.group(:ballot_type).sum(:count)
  end
  
  def name
  end
  
end