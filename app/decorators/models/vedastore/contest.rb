Vedastore::Contest.class_eval do
  
  def contest_gp_scope_object
    Vedastore::ElectionReport.where( election_id: election.id ).first.gp_units.where(object_id: electoral_district_identifier).first
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
