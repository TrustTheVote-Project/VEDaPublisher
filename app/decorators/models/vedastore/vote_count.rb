Vedastore::VoteCount.class_eval do
  def report_gp_unit
    ballot_selection.contest.election.election_report.gp_units.where(object_id: gp_unit).first
  end
  
end
