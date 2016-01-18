h1. Election Import

This generic CSV format may be used for importing both election definitions as well as election results. The full format assumes
results, but these columns may be ommitted or contain '0' as the data in order to just import an election definition.

A header row for the CSV is required, and must exactly match the names here. The order of the columns is not imporant.

Fundamentally, each row describes all results for a particular candidate or ballot response within a particular
precinct or precinct split. Many rows will contain the same data for many of the columns. Some data, such as over and under counts,
will never be unique to a precinct-contest-response row.


Columns:
Precinct_name: (Either this or Pct_Id is required) The name of the precinct
Pct_Id: (Either this or Precicnt_name is required) An internal identifier matching internal IDs used to populate background jurisdiction data.
Split_name: (Optional) The name of the precinct split
Reg_voters: (Optional) The number of voters in this precinct
Contest_Id: The internal ID for the contest
Contest_seq: For ordering contests in a ballot
Contest_title: (Required when defining an election) The title / name of the contest
Contest_party_name: (Optional) TBD
Selectable_Options: Number of items that can be selected for this contest
candidate_id: The internal ID for the candidate
candidate_name: (Required when defining an election) - the candidate name or ballot response text for this selection
Candidate_Type: Should be 'C' for existing candidate/response 'W' for write-in candidate
cand_seq_nbr: (Optional) The order of candidates in the ballot
Party_Code: (Required when defining an election) REP, DEM, LIB, GRN

== The remaining are all optional ==

total_ballots: For this reporting unit
total_votes: For this candidate in this reporting uint
total_under_votes: For this reporting unit
total_over_votes: For this reporting unit	
absentee_ballots: For this reporting unit	
absentee_votes: For this candidate in this reporting unit
absentee_under_votes: For this reporting unit
absentee_over_votes: For this reporting unit
early_ballots: For this reporting unit
early_votes: For this candidate in this reporting unit
early_under_votes: For this reporting unit
early_over_votes: For this reporting unit
election_ballots: On election day for this reporting unit
election_votes: On election day for this candidate in this reporting unit
election_under_votes: On election day for this reporting unit
election_over_votes: On election day for this reporting unit