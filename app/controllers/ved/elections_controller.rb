class Ved::ElectionsController < ApplicationController
  def show
    @election = Vedastore::Election.find(params[:id])
  end
end
