class Vedastore::Party < Vedastore::BallotSelection
  def name
    read_attribute(:name)
  end
  
  
end
