require 'csv'
require 'fileutils'
require 'zip'

class Jurisdiction < ActiveRecord::Base
  before_save :process_csv_election_definition, :process_hart_upload, :process_reporting_unit_kml_upload
  
  belongs_to :state
  
  has_many :districts, dependent: :destroy
  has_many :reporting_units, dependent: :destroy
  
  has_many :background_sources, dependent: :destroy
  has_many :election_report_uploads, dependent: :destroy
  
  CSV_HEADERs = [
    "TYPE", #ignored
    "ID",         #internal
    "NAME",	
    "DISTRICTTYPE",	
    "SEQUENCE",	
    "DISTRICTTYPE",	
    "GROUPID",	
    "VISIBLE",	
    "STANDARD_DISTRICT_TYPE",	
    "STANDARD_UID",	
    "OCD_ID",
    "ENCLOSING_IDS"
  ]
    
    
  # districts
  # t.string   "name"
  # t.string   "internal_id"
  # t.string   "district_type"
  # t.datetime "created_at",      null: false
  # t.datetime "updated_at",      null: false
  # t.integer  "ocd_object_id"
  # t.integer  "jurisdiction_id"
  
  # RUs
  # t.string   "name"
  # t.string   "internal_id"
  # t.datetime "created_at",      null: false
  # t.datetime "updated_at",      null: false
  # t.integer  "ocd_object_id"
  # t.integer  "jurisdiction_id"
  
  # OCD
  # t.string   "name"
  # t.string   "unit_type"
  # t.string   "district_type"
  # t.string   "ocd_id"
  # t.datetime "created_at",    null: false
  # t.datetime "updated_at",    null: false
  # t.integer  "ocd_object_id" - this is for "parent" levels (maybe unnecessary)

  attr_reader :background_csv, :background_vip, :hart_election_report, :vedastore_election_report
  def background_csv=(file)
    @background_csv=file
    self.load_from_csv(file.read, file.original_filename)
  end
  def background_vip=(file)
    @background_vip=file
    self.load_from_vip(file.read, file.original_filename)
  end
  def vedastore_election_report=(file)
    eru = ElectionReportUpload.new(source_type: "NIST ERR XML", file_name: file.original_filename)
    eru.election_report = Vedastore::ElectionReport.parse_ved_file(file)
    self.election_report_uploads << eru
    self.save!
  end
  def vip_election_report=(file)
    eru = ElectionReportUpload.new(source_type: "VIP XML", file_name: file.original_filename)
    eru.election_report = Vedastore::ElectionReport.parse_vip_file(file)
    self.election_report_uploads << eru
    self.save!
  end
  
  attr_accessor :selected_source_for_reporting_unit_kml, :reporting_unit_kml
  def process_reporting_unit_kml_upload
    if kml = self.reporting_unit_kml
      background = BackgroundSource.find(self.selected_source_for_reporting_unit_kml)
      source = background.shape_sources.build(name: kml.original_filename)
      source.load_reporting_units_from_kml(kml)
      background.save!
    end
  end
  
  attr_accessor :selected_source_for_hart, :hart_election_report
  def process_hart_upload
    if zip_file = self.hart_election_report
      # TODO: handle zip-file differences better
      dest = Rails.root.join('zip_uploads', Time.now.getutc.to_s)
      FileUtils.mkdir_p(dest)
      Zip::File.open(zip_file.path) do |zip_file|
        zip_file.each do |entry|
          Rails.logger.info "Extracting #{entry.name}"
          entry.extract(dest.join(entry.name))
        end
      end
      eru = ElectionReportUpload.new(source_type: "Hart ZIP", file_name: zip_file.original_filename)

      eru.jurisdiction = self
      eru.background_source_id = self.selected_source_for_hart
      eru.build_election_report
      eru.election_report.parse_hart_dir(
        dest.join(zip_file.original_filename.gsub(".zip", '')),
      )
      eru.save!
    
      # delete from the hart file      
    end
  end
  
  attr_accessor :selected_source_for_csv_definition, :csv_election_definition, :csv_election_definition_name
  def process_csv_election_definition
    if self.csv_election_definition && self.selected_source_for_csv_definition
      eru = ElectionReportUpload.new(source_type: "CSV Definition", file_name: self.csv_election_definition.original_filename)
      eru.jurisdiction = self
      eru.background_source_id = self.selected_source_for_hart
      eru.election_report = Vedastore::ElectionReport.from_jurisdiction(self)
      eru.election_report.build_election
      eru.election_report.election.name = Vedastore::InternationalizedText.new
      eru.election_report.election.name.language_strings << Vedastore::LanguageString.new(language: 'en', text: self.csv_election_definition_name)
      eru.save!
      eru.election_report.election_results_csv = self.csv_election_definition
    end
  end
  
    
  def load_from_csv_file(filename)
    File.open(filename, "r") do |f|
      load_from_csv(f.read, filename)
    end
  end
  
  def load_from_csv(filedata, filename)
    source = BackgroundSource.new(name: filename)
    self.background_sources << source
    enclosings = {} # ru.id => [district]
    mappings = []
    internal_objects = {"precinct" => {}}    
    rus = {}
    districts = {}
    CSV.parse(filedata, headers: true) do |row|    
      case row["TYPE"].to_s.downcase
      when "", "district"
        d = self.districts.build
        d.background_source = source
        d.name = row["NAME"]
        d.internal_id = row["ID"]
        d.district_type = row["DISTRICT_TYPE"]
        d.build_ocd_object
        d.ocd_object.name = row["NAME"]
        d.ocd_object.district_type = row["STANDARD_DISTRICT_TYPE"]
        d.ocd_object.ocd_id = row["OCD_ID"]
        districts[d.internal_id] = d
      when "precinct"
        r = self.reporting_units.build
        r.background_source = source
        r.internal_id = row["ID"]
        r.name = row["NAME"]
        r.build_ocd_object
        r.ocd_object.name = row["NAME"]
        r.ocd_object.ocd_id = row["OCD_ID"]
        if row["ENCLOSING_IDS"]
          row["ENCLOSING_IDS"].split(',').each do |encloser|
            e_type, e_internal_id = encloser.split(':')
            
            if e_type == "District" || (e_internal_id.nil? && !e_type.blank?)
              enclosings[r] ||= []
              enclosings[r] << (e_internal_id || e_type)
            else
              # shouldn't be anything else
            end
          end
        end
        rus[r.internal_id] = r
      else # it's  a mapping from Precinct to District
        if row["ENCLOSING_IDS"]
          row["ENCLOSING_IDS"].split(',').each do |encloser|
            e_type, e_internal_id = encloser.split(':')
            if e_type == "Precinct"
              internal_objects["precinct"] ||= {}
              internal_objects["precinct"][e_internal_id] ||= []
              internal_objects["precinct"][e_internal_id] << "#{row["TYPE"].downcase}:#{row["ID"]}"
            elsif e_type == "District" || e_internal_id.nil?
              internal_objects[row["TYPE"].downcase] ||= {}
              internal_objects[row["TYPE"].downcase][row["ID"]] ||= []
              internal_objects[row["TYPE"].downcase][row["ID"]] << ("district:#{e_internal_id || e_type}")
            else
            end
          end
        end        
      end
    end
    # turn internal objects into enclosings
    internal_objects["precinct"].each do |precinct_id, enclosers|
      r = rus[precinct_id]
      if r.nil?
        raise precinct_id.to_s
      end
      enclosers.each do |encloser|
        e_type, e_internal_id = encloser.split(':')
        internal_objects[e_type.downcase][e_internal_id].each do |district_encloser|
          d_type, d_internal_id = district_encloser.split(':')
          enclosings[r] ||= []
          enclosings[r] << d_internal_id
        end
      end
    end
    # handle enclosings
    enclosings.each do |ru, d_internal_ids|
      d_internal_ids.uniq.each do |d_id|
        if districts[d_id]
          ru.districts << districts[d_id]
        else
          raise "'#{d_id.to_s}'" + districts.keys.to_s
        end
      end
    end
    
    self.save!
  end
  
  
  def load_from_vip(filedata, filename)
    source = BackgroundSource.new(name: filename)
    self.background_sources << source
    enclosings = {} # ru.id => [district]
    mappings = []
    internal_objects = {"precinct" => {}}    
    rus = {}
    districts = {}
    
    doc = Nokogiri::XML(filedata) { |config| config.noblanks }
    
    # Make sure there's only one locality!
    if doc.css("locality").count != 1
      raise "For background data, there must be exactly one locality in the VIP to define this jurisdiction #{self.name}"
    end
    

  
    doc.css("electoral_district").each do |ed|
      d = self.districts.build
      d.background_source = source
      d.internal_id = ed.attributes["id"].value
      d.name = ed.css("> name").text
      d.district_type = ed.css("> type").text
      d.save!
    end

    doc.css("precinct").each do |p|
      r = self.reporting_units.build
      r.background_source = source
      r.internal_id = p.attributes["id"].value
      r.name = p.css("> name").text
      p.css("> electoral_district_id").each do |ed_id|
        d = source.districts.where(internal_id: ed_id.text).first
        d.reporting_units << r
      end
      r.save!
    end
    doc.css("precinct_split").each do |p|
      # find the precinct this talks about
      r = self.reporting_units.where(internal_id: p.css("> precinct_id").text).first
      p.css("> electoral_district_id").each do |ed_id|
        d = source.districts.where(internal_id: ed_id.text).first
        d.reporting_units << r
      end
    end
    self.save!
  end
  
  def state_abbreviation
    state ? state.abbreviation : nil
  end
  
  def to_ved_xml
    Vedastore::ElectionReport.from_jurisdiction(self).to_xml_node
  end
  
end
