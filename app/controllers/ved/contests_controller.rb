class Ved::ContestsController < ApplicationController
  def show
    @contest = Vedastore::Contest.find(params[:id])
  end
  
  def edit
    @contest = Vedastore::Contest.find(params[:id])
    #@gp_units = @contest.election.election_report.election_report_upload.background_source.districts + @contest.election.election_report.election_report_upload.background_source.reporting_units
    @election_report = Vedastore::ElectionReport.where(election_id: @contest.election_id).first
    @gp_units = @election_report.gp_units
  end
  
  def update
    @contest = Vedastore::Contest.find(params[:id])
    
    @contest.update_attributes(contest_params)
    redirect_to ved_contest_path(@contest)
  end

private
    def contest_params
      cp = params[:candidate_contest] || params[:ballot_measure_contest]
      cp.permit(:electoral_district_identifier)
    end
  
end
