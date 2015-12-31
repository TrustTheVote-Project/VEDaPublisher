Vedastore::CandidateSelection.class_eval do
  def candidates
    candidate_selection_candidate_refs.collect(&:candidate)
  end
  
  def name
    candidates.collect(&:ballot_name).join(", ")
  end
  
end
