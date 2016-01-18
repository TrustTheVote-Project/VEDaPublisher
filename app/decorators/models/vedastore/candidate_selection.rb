Vedastore::CandidateSelection.class_eval do
  def candidates
    Vedastore::Candidate.where(object_id: ballot_selection_candidate_id_refs.collect(&:candidate_id_ref))
  end
  
  def name
    candidates.collect(&:ballot_name).join(", ")
  end
  
end
