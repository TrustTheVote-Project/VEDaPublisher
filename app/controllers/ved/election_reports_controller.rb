class Ved::ElectionReportsController < ApplicationController
  
  def show
    @er = Vedastore::ElectionReport.find_with_eager_load(params[:id])
    respond_to do |f|
      f.xml { render text: @er.to_xml_node.to_xml }
    end
  end
  
  def update
    @er = Vedastore::ElectionReport.find(params[:id])
    @er.update(election_report_params)
    redirect_to @er.jurisdiction
  end
  
  def destroy
    @er = Vedastore::ElectionReport.find(params[:id])
    @er.destroy!
    redirect_to @er.jurisdiction
  end
  
private
    def election_report_params
      params.require(:vedastore_election_report).permit(:election_results_csv)
    end


  
  
end
