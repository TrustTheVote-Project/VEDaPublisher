class Ved::ElectionsController < ApplicationController
  def show
    @election = Vedastore::Election.find(params[:id])
    @election_report = Vedastore::ElectionReport.where(election_id: params[:id]).first
  end
end
