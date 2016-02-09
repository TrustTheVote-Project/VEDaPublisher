Vedastore::VoteCount.class_eval do
  def report_gp_unit
    Vedastore::ElectionReport.where(election_id: countable.contest.election.id).first.gp_units.where(object_id: gp_unit_identifier).first
  end
  
end
