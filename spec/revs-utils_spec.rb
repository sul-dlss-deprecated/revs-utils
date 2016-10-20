require 'spec_helper'

describe "Revs-Utils" do

  before(:each) do

    @revs=RevsUtilsTester.new # a class defined in the spec_helper which includes the module methods we need to test

  end

   it "should clean up collection names" do
     expect(@revs.clean_collection_name(nil)).to eq("")
     expect(@revs.clean_collection_name("")).to eq("")
     expect(@revs.clean_collection_name(123)).to eq("123")
     expect(@revs.clean_collection_name('This should be untouched')).to eq('This should be untouched')
     expect(@revs.clean_collection_name('The should be removed')).to eq('should be removed')
     expect(@revs.clean_collection_name('the should be removed')).to eq('should be removed')
     expect(@revs.clean_collection_name('THE should be removed')).to eq('should be removed')
     expect(@revs.clean_collection_name('Should the not be removed')).to eq('Should the not be removed')
     expect(@revs.clean_collection_name('The Dugdale Collection of the Revs Institute')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('the Dugdale Collection of the revs institute')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection of the Revs Institute')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection OF THE REVS INSTITUTE')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection of The Revs Institute')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection of the Revs institute for Automotive Research, Inc.')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection of the Revs Institute for Automotive Research, Inc')).to eq('Dugdale Collection')
     expect(@revs.clean_collection_name('Dugdale Collection of Some Other Institute for Automotive Research, Inc')).to eq('Dugdale Collection of Some Other Institute for Automotive Research, Inc')
     expect(@revs.clean_collection_name('Revs Institute Dugdale Collection of the Revs Institute')).to eq('Revs Institute Dugdale Collection')
     expect(@revs.clean_collection_name('of the Revs Institute The Dugdale Collection of the Revs Institute')).to eq('of the Revs Institute The Dugdale Collection')
   end

   it "should clean up marque names" do
     expect(@revs.clean_marque_name(nil)).to eq("")
     expect(@revs.clean_marque_name("")).to eq("")
     expect(@revs.clean_marque_name(123)).to eq("123")
     expect(@revs.clean_marque_name('This should be untouched')).to eq('This should be untouched')
     expect(@revs.clean_marque_name('Ford Automobiles')).to eq('Ford')
     expect(@revs.clean_marque_name('Ford Automobile')).to eq('Ford')
     expect(@revs.clean_marque_name('ford automobiles')).to eq('ford')
     expect(@revs.clean_marque_name('ford automobile')).to eq('ford')
     expect(@revs.clean_marque_name('ford')).to eq('ford')
   end

   it "should parse locations" do
     row={'other'=>'value','location'=>'123 Street | Palo Alto | United States'}
     expect(@revs.parse_location(row,'location')).to eq(row.merge('city_section'=>'123 Street ','country'=>'United States'))
   end

   it "should parse locations with comma delimiter" do
     row={'other'=>'value','location'=>'Paris, France'}
     expect(@revs.parse_location(row,'location')).to eq(row.merge('city_section'=>'Paris','country'=>'France'))
   end

   it "should lookup marques" do
     expect(@revs.revs_lookup_marque('Ford')).to eq({"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"})
     expect(@revs.revs_lookup_marque('Fords')).to eq({"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"})
     expect(@revs.revs_lookup_marque('Ford Automobiles')).to eq({"url"=>"http://id.loc.gov/authorities/subjects/sh85050464", "value"=>"Ford automobile"})
     expect(@revs.revs_lookup_marque('Porsche')).to eq({"url"=>"http://id.loc.gov/authorities/subjects/sh85105037", "value"=>"Porsche automobiles"})
     expect(@revs.revs_lookup_marque('Bogus')).to be_falsey
     expect(@revs.revs_lookup_marque('')).to be_falsey
   end

   it "should clean up some common format errors from an array" do
     expect(@revs.revs_check_formats(['black-and-white negative','color negative','leave alone'])).to eq(['black-and-white negatives','color negatives','leave alone'])
     expect(@revs.revs_check_formats(['black and white','color negative','black-and-white negative'])).to eq(['black-and-white negatives','color negatives','black-and-white negatives'])
   end

   it "should clean up some common format errors from a string" do
     expect(@revs.revs_check_format('black-and-white negative')).to eq('black-and-white negatives')
     expect(@revs.revs_check_format('leave alone')).to eq('leave alone')
   end

   it "should clean up some common format errors from that are uppercase and then lower case everything" do
     expect(@revs.revs_check_format('Color Transparency')).to eq('color transparencies')
     expect(@revs.revs_check_format('Glass negatives')).to eq('glass negatives')
     expect(@revs.revs_check_format('Leave Alone')).to eq('leave alone')
   end

   it "should indicate if a date is valid" do

     # formats that are ok
     expect(@revs.get_full_date('5/1/1959')).to eq(Date.strptime("5/1/1959", '%m/%d/%Y'))
     expect(@revs.get_full_date('5-1-1959')).to eq(Date.strptime("5/1/1959", '%m/%d/%Y'))
     expect(@revs.get_full_date('5-1-2014')).to eq(Date.strptime("5/1/2014", '%m/%d/%Y'))
     expect(@revs.get_full_date('5-1-59')).to eq(Date.strptime("5/1/1959", '%m/%d/%Y'))
     expect(@revs.get_full_date('1/1/71')).to eq(Date.strptime("1/1/1971", '%m/%d/%Y'))
     expect(@revs.get_full_date('5-1-14')).to eq(Date.strptime("5/1/2014", '%m/%d/%Y'))
     expect(@revs.get_full_date('5-1-21')).to eq(Date.strptime("5/1/1921", '%m/%d/%Y'))
     expect(@revs.get_full_date('1966-02-27')).to eq(Date.strptime("2/27/1966", '%m/%d/%Y'))
     expect(@revs.get_full_date('1966-2-5')).to eq(Date.strptime("2/5/1966", '%m/%d/%Y'))

     # bad full dates
     expect(@revs.get_full_date('1966-14-11')).to be_falsey# bad month
     expect(@revs.get_full_date('1966\4\11')).to be_falsey# slashes are the wrong way
     expect(@revs.get_full_date('bogus')).to be_falsey# crap string
     expect(@revs.get_full_date('')).to be_falsey# blank
     expect(@revs.get_full_date('1965')).to be_falsey# only the year
     expect(@revs.get_full_date('1965-68')).to be_falsey# range of years
     expect(@revs.get_full_date('1965,1968')).to be_falsey# multiple years
     expect(@revs.get_full_date('1965|1968')).to be_falsey# multiple years
     expect(@revs.get_full_date('1965-1968')).to be_falsey# multiple years
     expect(@revs.get_full_date('1965-8')).to be_falsey# multiple years

   end

   it "should indicate if we have a valid year" do
     expect(@revs.is_valid_year?('1959')).to be_truthy
     expect(@revs.is_valid_year?('bogus')).to be_falsey
     expect(@revs.is_valid_year?('1700')).to be_falsey # too old! no cars even existed yet
     expect(@revs.is_valid_year?('1700',1600)).to be_truthy # unless we allow it to be ok
  end

  it "should indicate if we have unknown formats" do
    expect(@revs.revs_is_valid_format?(nil)).to be_truthy
    expect(@revs.revs_is_valid_format?('')).to be_truthy
    expect(@revs.revs_is_valid_format?('slides')).to be_truthy
    expect(@revs.revs_is_valid_format?('glass negatives')).to be_truthy
    expect(@revs.revs_is_valid_format?('slide')).to be_falsey
    expect(@revs.revs_is_valid_format?('slides | slide')).to be_falsey
    expect(@revs.revs_is_valid_format?('slides | black-and-white negatives | Glass negatives')).to be_truthy
    expect(@revs.revs_is_valid_format?('black-and-white-negatives')).to be_falsey
    expect(@revs.revs_is_valid_format?('black-and-white negatives')).to be_truthy
  end

  it "should indicate if we have a valid datestring" do
    expect(@revs.revs_is_valid_datestring?('1959')).to be_truthy
    expect(@revs.revs_is_valid_datestring?('bogus')).to be_falsey
    expect(@revs.revs_is_valid_datestring?('')).to be_truthy
    expect(@revs.revs_is_valid_datestring?(nil)).to be_truthy
    expect(@revs.revs_is_valid_datestring?([])).to be_truthy
    expect(@revs.revs_is_valid_datestring?('2/2/1950')).to be_truthy
    expect(@revs.revs_is_valid_datestring?('2/31/1950')).to be_falsey
    expect(@revs.revs_is_valid_datestring?('2/2/50')).to be_truthy
    expect(@revs.revs_is_valid_datestring?('195x')).to be_truthy
 end

   it "should lookup the country correctly" do
     expect(@revs.revs_get_country('USA')).to eq("United States")
     expect(@revs.revs_get_country('US')).to eq("United States")
     expect(@revs.revs_get_country('United States')).to eq("United States")
     expect(@revs.revs_get_country('italy')).to eq("Italy")
     expect(@revs.revs_get_country('Bogus')).to be_falsey
   end

   it "should parse a city/state correctly" do
     expect(@revs.revs_get_city_state('San Mateo (Calif.)')).to eq(['San Mateo','Calif.'])
     expect(@revs.revs_get_city_state('San Mateo')).to be_falsey
     expect(@revs.revs_get_city_state('Indianapolis (Ind.)')).to eq(['Indianapolis','Ind.'])
   end

   it "should lookup a state correctly" do
     expect(@revs.revs_get_state_name('Calif')).to eq("California")
     expect(@revs.revs_get_state_name('Calif.')).to eq("California")
     expect(@revs.revs_get_state_name('calif')).to eq("California")
     expect(@revs.revs_get_state_name('Ind')).to eq("Indiana")
     expect(@revs.revs_get_state_name('Bogus')).to eq("Bogus")
     expect(@revs.revs_get_state_name('IN')).to eq("Indiana")
     expect(@revs.revs_get_state_name('IN')).to eq("Indiana")
   end

   it "should parse locations" do
     expect(@revs.revs_location({:cities_ssi=>'Paris',:countries_ssi=>'France'})).to eq('Paris, France')
     expect(@revs.revs_location({:id=>'123',:title_tsi=>'Test'})).to eq('')
     expect(@revs.revs_location({:city_sections_ssi=>'Rue Cool 123',:cities_ssi=>'Paris',:countries_ssi=>'France'})).to eq('Rue Cool 123, Paris, France')
     expect(@revs.revs_location({:city_sections_ssi=>'Cool Street',:cities_ssi=>'Paris',:states_ssi=>'Texas',:countries_ssi=>'USA'})).to eq('Cool Street, Paris, Texas, USA')
   end

  it "should parse 1950s and 1950's correctly" do

    expect(@revs.parse_years('1950s')).to eq(['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959'])
    expect(@revs.parse_years("1950's")).to eq(['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959'])

  end

  it "should parse 1955-57 correctly" do

    expect(@revs.parse_years('1955-57')).to eq(['1955','1956','1957'])

  end

  it "should parse 1955 | 1955 and not produce a duplicate year" do

    expect(@revs.parse_years('1955|1955')).to eq(['1955'])

  end

  it "should parse 1955-1957 | 1955-1957 and not produce duplicate years" do

    expect(@revs.parse_years('1955-1957 | 1955-1957')).to eq(['1955','1956','1957'])

  end

  it "should parse 1955-1957 | 1955 | 1955 and not produce duplicate years" do

    expect(@revs.parse_years('1955-1957 | 1955 | 1955')).to eq(['1955','1956','1957'])

  end

  it "should parse 1955-1957 | 1955 | 1954 and not produce duplicate years" do

    expect(@revs.parse_years('1955-1957 | 1955 | 1954')).to eq(['1954','1955','1956','1957'])

  end

  it "should parse 1800-1802" do

    expect(@revs.parse_years('1800-1802')).to eq(['1800','1801','1802'])

  end

  it "should parse 1955-1957 correctly" do

    expect(@revs.parse_years('1955-1957')).to eq(['1955','1956','1957'])

  end

  it "should be able to read the manifest headers file and load it as a hash" do
    file_status = File.exists? @revs.manifest_headers_file()
    expect(file_status).to eq(true)

    expect(YAML.load(File.open(@revs.manifest_headers_file())).class).to eq(Hash)
  end

  it "should have a list of headers required for registration in the manifest headers file" do
    expect(@revs.get_manifest_section(@revs.manifest_register_section_name()).size).to be > 0
    expect(@revs.get_manifest_section(@revs.manifest_register_section_name()).keys - ["sourceid", "label", "filename"]).to eq([]) #headers required to register
  end

  it "should have a list of headers required for metadata updating in the manifest headers file" do
     expect(@revs.get_manifest_section(@revs.manifest_metadata_section_name()).size).to be > 0
     expect(@revs.get_manifest_section(@revs.manifest_metadata_section_name()).keys - ["marque", "model", "people", "entrant", "photographer", "current_owner", "venue", "track", "event",
            "location", "year", "description", "model_year", "model_year", "group_or_class", "race_data", "metadata_sources","state", "country", "city", "date",
            "vehicle_markings", "inst_notes", "prod_notes", "has_more_metadata", "hide", "format", "format_authority", "collection_name", "engine_type","group","class","original_size"]).to eq([])
  end

  it "should return when true when given a clean sheet to check for headers required for registration and metadata updating" do
    sheet = Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"
    expect(@revs.valid_to_register(sheet)).to eq(true)
    expect(@revs.valid_for_metadata(sheet)).to eq(true)
  end

  it "should return true for registration, and should be ok for metadata if date exists instead of year" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-instead-of-year.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
     expect(@revs.valid_for_metadata(sheet)).to eq(true)
  end

  it "should return true for registration if label column exists but some values are blank" do
     sheet = Dir.pwd + "/spec/sample-csv-files/blank-label.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
     sheet = Dir.pwd + "/spec/sample-csv-files/no-blank-label.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
  end

  it "should return false for registration if label column does not exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/no-label-column.csv"
     expect(@revs.valid_to_register(sheet)).to eq(false)
  end

  it "should return true for registration, and should be ok for metadata even if year exists, but not date" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-instead-of-year.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
     expect(@revs.valid_for_metadata(sheet)).to eq(true)
  end

  it "should return true for registration, and should NOT be ok for metadata if both year and date exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/date-and-year.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
     expect(@revs.valid_for_metadata(sheet)).to eq(false)
  end

  it "should return true for registration, and should NOT be ok for metadata if both location and specific location fields exist" do
     sheet = Dir.pwd + "/spec/sample-csv-files/location-and-other-fields.csv"
     expect(@revs.valid_to_register(sheet)).to eq(true)
     expect(@revs.valid_for_metadata(sheet)).to eq(false)
  end

  it "should return false for registration and metadata when source_id is mislabeled" do
    sheet = Dir.pwd + "/spec/sample-csv-files/bad-source_id.csv"
    expect(@revs.valid_to_register(sheet)).to eq(false)
    expect(@revs.valid_for_metadata(sheet)).to eq(false)
  end

  it "should return false for registration and metadata when sourceid is not present" do
    sheet = Dir.pwd + "/spec/sample-csv-files/no-sourceid.csv"
    expect(@revs.valid_to_register(sheet)).to eq(false)
    expect(@revs.valid_for_metadata(sheet)).to eq(false)
  end

  it "should return false when a row does not have a sourceid" do
      sheet = Dir.pwd + "/spec/sample-csv-files/blank-sourceid.csv"
      expect(@revs.valid_to_register(sheet)).to eq(false)
  end

  it "should return true when each souceid is unique and properly formed from the filename" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"]
    expect(@revs.unique_source_ids(sheets)).to eq(true)
  end

  it "should return false when there are duplicate sourceids" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv",Dir.pwd + "/spec/sample-csv-files/clean-sheet.csv"]
    expect(@revs.unique_source_ids(sheets)).to eq(false)
  end

  it "should return false when a sourceid is not properly based off the filename" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/malformed-sourceid.csv"]
    expect(@revs.unique_source_ids(sheets)).to eq(false)
  end

  it "should return false when a sourceid has a space in it" do
    sheets = [Dir.pwd + "/spec/sample-csv-files/space-sourceid.csv"]
    expect(@revs.unique_source_ids(sheets)).to eq(false)
  end


end
