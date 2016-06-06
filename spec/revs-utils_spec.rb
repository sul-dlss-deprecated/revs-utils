require 'spec_helper'

describe "Revs-Utils" do

  before(:each) do

    @revs=RevsUtilsTester.new # a class defined in the spec_helper which includes the module methods we need to test

  end

   it "should clean up collection names" do
     @revs.clean_collection_name(nil).should == ""
     @revs.clean_collection_name("").should == ""
     @revs.clean_collection_name(123).should == "123"
     @revs.clean_collection_name('This should be untouched').should == 'This should be untouched'
     @revs.clean_collection_name('The should be removed').should == 'should be removed'
     @revs.clean_collection_name('the should be removed').should == 'should be removed'
     @revs.clean_collection_name('THE should be removed').should == 'should be removed'
     @revs.clean_collection_name('Should the not be removed').should == 'Should the not be removed'
     @revs.clean_collection_name('The Dugdale Collection of the Revs Institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('the Dugdale Collection of the revs institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of the Revs Institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection OF THE REVS INSTITUTE').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of The Revs Institute').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of the Revs institute for Automotive Research, Inc.').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of the Revs Institute for Automotive Research, Inc').should == 'Dugdale Collection'
     @revs.clean_collection_name('Dugdale Collection of Some Other Institute for Automotive Research, Inc').should == 'Dugdale Collection of Some Other Institute for Automotive Research, Inc'
     @revs.clean_collection_name('Revs Institute Dugdale Collection of the Revs Institute').should == 'Revs Institute Dugdale Collection'
     @revs.clean_collection_name('of the Revs Institute The Dugdale Collection of the Revs Institute').should == 'of the Revs Institute The Dugdale Collection'
   end

   it "should clean up marque names" do
     @revs.clean_marque_name(nil).should == ""
     @revs.clean_marque_name("").should == ""
     @revs.clean_marque_name(123).should == "123"
     @revs.clean_marque_name('This should be untouched').should == 'This should be untouched'
     @revs.clean_marque_name('Ford Automobiles').should == 'Ford'
     @revs.clean_marque_name('Ford Automobile').should == 'Ford'
     @revs.clean_marque_name('ford automobiles').should == 'ford'
     @revs.clean_marque_name('ford automobile').should == 'ford'
     @revs.clean_marque_name('ford').should == 'ford'
   end

   it "should parse locations" do
     row={'other'=>'value','location'=>'123 Street | Palo Alto | United States'}
     @revs.parse_location(row,'location').should == row.merge('city_section'=>'123 Street ','country'=>'United States')
   end

   it "should parse locations with comma delimiter" do
     row={'other'=>'value','location'=>'Paris, France'}
     @revs.parse_location(row,'location').should == row.merge('city_section'=>'Paris','country'=>'France')
   end

   it "should lookup marques" do
     @revs.revs_lookup_marque('Ford').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Fords').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Ford Automobiles').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"}
     @revs.revs_lookup_marque('Porsche').should == {"url"=>"http://id.loc.gov/authorities/subjects/sh85105037", "value"=>"Porsche automobiles"}
     @revs.revs_lookup_marque('Bogus').should be_falsey
     @revs.revs_lookup_marque('').should be_falsey
   end

   it "should clean up some common format errors from an array" do
     @revs.revs_check_formats(['black-and-white negative','color negative','leave alone']).should == ['black-and-white negatives','color negatives','leave alone']
     @revs.revs_check_formats(['black and white','color negative','black-and-white negative']).should == ['black-and-white negatives','color negatives','black-and-white negatives']
   end

   it "should clean up some common format errors from a string" do
     @revs.revs_check_format('black-and-white negative').should == 'black-and-white negatives'
     @revs.revs_check_format('leave alone').should == 'leave alone'
   end

   it "should clean up some common format errors from that are uppercase and then lower case everything" do
     @revs.revs_check_format('Color Transparency').should == 'color transparencies'
     @revs.revs_check_format('Glass negatives').should == 'glass negatives'
     @revs.revs_check_format('Leave Alone').should == 'leave alone'
   end

   it "should indicate if a date is valid" do

     # formats that are ok
     @revs.get_full_date('5/1/1959').should == Date.strptime("5/1/1959", '%m/%d/%Y')
     @revs.get_full_date('5-1-1959').should == Date.strptime("5/1/1959", '%m/%d/%Y')
     @revs.get_full_date('5-1-2014').should == Date.strptime("5/1/2014", '%m/%d/%Y')
     @revs.get_full_date('5-1-59').should == Date.strptime("5/1/1959", '%m/%d/%Y')
     @revs.get_full_date('1/1/71').should == Date.strptime("1/1/1971", '%m/%d/%Y')
     @revs.get_full_date('5-1-14').should == Date.strptime("5/1/2014", '%m/%d/%Y')
     @revs.get_full_date('5-1-21').should == Date.strptime("5/1/1921", '%m/%d/%Y')
     @revs.get_full_date('1966-02-27').should == Date.strptime("2/27/1966", '%m/%d/%Y')
     @revs.get_full_date('1966-2-5').should == Date.strptime("2/5/1966", '%m/%d/%Y')

     # bad full dates
     @revs.get_full_date('1966-14-11').should be_falsey# bad month
     @revs.get_full_date('1966\4\11').should be_falsey# slashes are the wrong way
     @revs.get_full_date('bogus').should be_falsey# crap string
     @revs.get_full_date('').should be_falsey# blank
     @revs.get_full_date('1965').should be_falsey# only the year
     @revs.get_full_date('1965-68').should be_falsey# range of years
     @revs.get_full_date('1965,1968').should be_falsey# multiple years
     @revs.get_full_date('1965|1968').should be_falsey# multiple years
     @revs.get_full_date('1965-1968').should be_falsey# multiple years
     @revs.get_full_date('1965-8').should be_falsey# multiple years

   end

   it "should indicate if we have a valid year" do
     @revs.is_valid_year?('1959').should be_truthy
     @revs.is_valid_year?('bogus').should be_falsey
     @revs.is_valid_year?('1700').should be_falsey # too old! no cars even existed yet
     @revs.is_valid_year?('1700',1600).should be_truthy # unless we allow it to be ok
  end

  it "should indicate if we have unknown formats" do
    @revs.revs_is_valid_format?(nil).should be_truthy
    @revs.revs_is_valid_format?('').should be_truthy
    @revs.revs_is_valid_format?('slides').should be_truthy
    @revs.revs_is_valid_format?('glass negatives').should be_truthy
    @revs.revs_is_valid_format?('slide').should be_falsey
    @revs.revs_is_valid_format?('slides | slide').should be_falsey
    @revs.revs_is_valid_format?('slides | black-and-white negatives | Glass negatives').should be_truthy
    @revs.revs_is_valid_format?('black-and-white-negatives').should be_falsey
    @revs.revs_is_valid_format?('black-and-white negatives').should be_truthy
  end

  it "should indicate if we have a valid datestring" do
    @revs.revs_is_valid_datestring?('1959').should be_truthy
    @revs.revs_is_valid_datestring?('bogus').should be_falsey
    @revs.revs_is_valid_datestring?('').should be_truthy
    @revs.revs_is_valid_datestring?(nil).should be_truthy
    @revs.revs_is_valid_datestring?([]).should be_truthy
    @revs.revs_is_valid_datestring?('2/2/1950').should be_truthy
    @revs.revs_is_valid_datestring?('2/31/1950').should be_falsey
    @revs.revs_is_valid_datestring?('2/2/50').should be_truthy
    @revs.revs_is_valid_datestring?('195x').should be_truthy
 end

   it "should lookup the country correctly" do
     @revs.revs_get_country('USA').should == "United States"
     @revs.revs_get_country('US').should == "United States"
     @revs.revs_get_country('United States').should == "United States"
     @revs.revs_get_country('italy').should == "Italy"
     @revs.revs_get_country('Bogus').should be_falsey
   end

   it "should parse a city/state correctly" do
     @revs.revs_get_city_state('San Mateo (Calif.)').should == ['San Mateo','Calif.']
     @revs.revs_get_city_state('San Mateo').should be_falsey
     @revs.revs_get_city_state('Indianapolis (Ind.)').should == ['Indianapolis','Ind.']
   end

   it "should lookup a state correctly" do
     @revs.revs_get_state_name('Calif').should == "California"
     @revs.revs_get_state_name('Calif.').should == "California"
     @revs.revs_get_state_name('calif').should == "California"
     @revs.revs_get_state_name('Ind').should == "Indiana"
     @revs.revs_get_state_name('Bogus').should == "Bogus"
     @revs.revs_get_state_name('IN').should == "Indiana"
     @revs.revs_get_state_name('IN').should == "Indiana"
   end

   it "should parse locations" do
     @revs.revs_location({:cities_ssi=>'Paris',:countries_ssi=>'France'}).should == 'Paris, France'
     @revs.revs_location({:id=>'123',:title_tsi=>'Test'}).should == ''
     @revs.revs_location({:city_sections_ssi=>'Rue Cool 123',:cities_ssi=>'Paris',:countries_ssi=>'France'}).should == 'Rue Cool 123, Paris, France'
     @revs.revs_location({:city_sections_ssi=>'Cool Street',:cities_ssi=>'Paris',:states_ssi=>'Texas',:countries_ssi=>'USA'}).should == 'Cool Street, Paris, Texas, USA'
   end

  it "should parse 1950s and 1950's correctly" do

    @revs.parse_years('1950s').should == ['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959']
    @revs.parse_years("1950's").should == ['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959']

  end

  it "should parse 1955-57 correctly" do

    @revs.parse_years('1955-57').should == ['1955','1956','1957']

  end

  it "should parse 1955 | 1955 and not produce a duplicate year" do

    @revs.parse_years('1955|1955').should == ['1955']

  end

  it "should parse 1955-1957 | 1955-1957 and not produce duplicate years" do

    @revs.parse_years('1955-1957 | 1955-1957').should == ['1955','1956','1957']

  end

  it "should parse 1955-1957 | 1955 | 1955 and not produce duplicate years" do

    @revs.parse_years('1955-1957 | 1955 | 1955').should == ['1955','1956','1957']

  end

  it "should parse 1955-1957 | 1955 | 1954 and not produce duplicate years" do

    @revs.parse_years('1955-1957 | 1955 | 1954').should == ['1954','1955','1956','1957']

  end

  it "should parse 1800-1802" do

    @revs.parse_years('1800-1802').should == ['1800','1801','1802']

  end

  it "should parse 1955-1957 correctly" do

    @revs.parse_years('1955-1957').should == ['1955','1956','1957']

  end

  it "should be able to read the manifest headers file and load it as a hash" do
    file_status = File.exists? @revs.manifest_headers_file()
    file_status.should == true

    YAML.load(File.open(@revs.manifest_headers_file())).class.should == Hash
  end

  it "should have a list of headers required for registration in the manifest headers file" do
    @revs.get_manifest_section(@revs.manifest_register_section_name()).size.should > 0
    (@revs.get_manifest_section(@revs.manifest_register_section_name()).keys - ["sourceid", "label", "filename"]).should == [] #headers required to register
  end

  it "should have a list of headers required for metadata updating in the manifest headers file" do
     @revs.get_manifest_section(@revs.manifest_metadata_section_name()).size.should > 0
     (@revs.get_manifest_section(@revs.manifest_metadata_section_name()).keys - ["marque", "model", "people", "entrant", "photographer", "current_owner", "venue", "track", "event",
            "location", "year", "description", "model_year", "model_year", "group_or_class", "race_data", "metadata_sources","state", "country", "city", "date",
            "vehicle_markings", "inst_notes", "prod_notes", "has_more_metadata", "hide", "format", "format_authority", "collection_name", "engine_type"]).should == []
  end

  it "should return when true when given a clean sheet to check for headers required for registration and metadata updating" do
    sheet = Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"
    @revs.valid_to_register(sheet).should == true
    @revs.valid_for_metadata(sheet).should == true
  end

  it "should return true for registration, and should be ok for metadata if date exists instead of year" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-instead-of-year.csv"
     @revs.valid_to_register(sheet).should == true
     @revs.valid_for_metadata(sheet).should == true
  end

  it "should return true for registration if label column exists but some values are blank" do
     sheet = Dir.pwd + "/spec/sample-csv-files/blank-label.csv"
     @revs.valid_to_register(sheet).should == true
     sheet = Dir.pwd + "/spec/sample-csv-files/no-blank-label.csv"
     @revs.valid_to_register(sheet).should == true
  end

  it "should return false for registration if label column does not exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/no-label-column.csv"
     @revs.valid_to_register(sheet).should == false
  end

  it "should return true for registration, and should be ok for metadata even if year exists, but not date" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-instead-of-year.csv"
     @revs.valid_to_register(sheet).should == true
     @revs.valid_for_metadata(sheet).should == true
  end

  it "should return true for registration, and should NOT be ok for metadata if both year and date exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-and-year.csv"
     @revs.valid_to_register(sheet).should == true
     @revs.valid_for_metadata(sheet).should == false
  end

  it "should return true for registration, and should NOT be ok for metadata if both location and specific location fields exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/location-and-other-fields.csv"
     @revs.valid_to_register(sheet).should == true
     @revs.valid_for_metadata(sheet).should == false
  end

  it "should return false for registration and metadata when source_id is mislabeled" do
    sheet = Dir.pwd + "/spec/sample-csv-files/bad-source_id.csv"
    @revs.valid_to_register(sheet).should == false
    @revs.valid_for_metadata(sheet).should == false
  end

  it "should return false for registration and metadata when sourceid is not present" do
    sheet = Dir.pwd + "/spec/sample-csv-files/no-sourceid.csv"
    @revs.valid_to_register(sheet).should == false
    @revs.valid_for_metadata(sheet).should == false
  end

  it "should return false when a row does not have a sourceid" do
      sheet = Dir.pwd + "/spec/sample-csv-files/blank-sourceid.csv"
      @revs.valid_to_register(sheet).should == false
  end

  it "should return true when each souceid is unique and properly formed from the filename" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"]
    @revs.unique_source_ids(sheets).should == true
  end

  it "should return false when there are duplicate sourceids" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv",Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"]
    @revs.unique_source_ids(sheets).should == false
  end

  it "should return false when a sourceid is not properly based off the filename" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/malformed-sourceid.csv"]
    @revs.unique_source_ids(sheets).should == false
  end

  it "should return false when a sourceid has a space in it" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/space-sourceid.csv"]
    @revs.unique_source_ids(sheets).should == false
  end


end
