# TODO: do we need this SQL for optimization?
class Vssc::CandidateSelectionCandidateRef < ActiveRecord::Base
  include VsscFunctions
  
  belongs_to :candidate_selection
  # belongs_to :candidate, primary_key: :object_id, foreign_key: :object_id
  
  
 
  has_one :candidate, -> {joins("LEFT JOIN vssc_candidate_selection_candidate_refs on vssc_candidate_selection_candidate_refs.object_id = vssc_candidates.object_id LEFT JOIN vssc_ballot_selections ON vssc_ballot_selections.id = vssc_candidate_selection_candidate_refs.candidate_selection_id LEFT JOIN vssc_contests on vssc_ballot_selections.contest_id = vssc_contests.id").where("vssc_contests.election_id=vssc_candidates.election_id")}, primary_key: :object_id, foreign_key: :object_id
  
  # def candidate
  #   self.candidate_selection.contest.election.candidates.where(object_id: object_id).first
  # end
  
  def self.parse_vssc(node)
    e = self.new
    e.object_id = node.text
    e
  end
  
  def to_xml_node(xml = nil, node_name = nil)
    xml.send("Candidate", self.object_id.to_s)
  end
  
end
