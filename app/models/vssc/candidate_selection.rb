class Vssc::CandidateSelection < Vssc::BallotSelection
  
  define_element("Candidate", type: Vssc::CandidateSelectionCandidateRef, method: :candidate_selection_candidate_refs)
  has_many :candidate_selection_candidate_refs
  has_many :candidates, through: :candidate_selection_candidate_refs
  
  define_element("EndorsementParty", type: String, method: :parties)
  has_many :candidate_selection_party_refs
  has_many :parties, through: :candidate_selection_party_refs
  
  
  define_attribute("isWriteIn", type: "xsd:boolean", method: :is_write_in)
  
end