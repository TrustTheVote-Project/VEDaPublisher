class Vedastore::Contest < ActiveRecord::Base
  
  def contest_gp_scope_object
    election.election_report.gp_units.where(object_id: contest_gp_scope).first
  end
  
  
  def total_ballots_cast
    self.total_counts_by_gp_unit.sum(:ballots_cast)
  end
  def total_overvotes
    self.total_counts_by_gp_unit.sum(:overvotes)
  end
  def total_undervotes
    self.total_counts_by_gp_unit.sum(:undervotes)
  end
  def total_write_ins
    self.total_counts_by_gp_unit.sum(:write_ins)
  end
  
end
