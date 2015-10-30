class Ved::ContestsController < ApplicationController
  def show
    @contest = Vedastore::Contest.find(params[:id])
  end
  
  def edit
    @contest = Vedastore::Contest.find(params[:id])
    #@gp_units = @contest.election.election_report.election_report_upload.background_source.districts + @contest.election.election_report.election_report_upload.background_source.reporting_units
    @gp_units = @contest.election.election_report.gp_units
  end
  
  def update
    @contest = Vedastore::Contest.find(params[:id])
    
    @contest.update_attributes(contest_params)
    redirect_to ved_contest_path(@contest)
  end

private
    def contest_params
      cp = params[:ved_candidate_choice] || params[:ved_ballot_measure]
      cp.permit(:contest_gp_scope)
    end
  
end
