# encoding: UTF-8

require "revs-utils/version"
require "countries"
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'csv'

PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')


REVS_LC_TERMS_FILENAME=File.join(PROJECT_ROOT,'files','revs-lc-marque-terms.obj')
REVS_MANIFEST_HEADERS_FILEPATH = File.join(PROJECT_ROOT,'config',"manifest_headers.yml")
REGISTER = "register"
METADATA = "metadata"


module Revs
  module Utils
    
      
      # a hash of LC Subject Heading terms and their IDs for linking for "Automobiles" http://id.loc.gov/authorities/subjects/sh85010201.html
      # this is cached and loaded from disk and deserialized back into a hash for performance reasons, then stored as a module
      # level constant so it can be reused throughout the pre-assembly run as a constant
      #  This cached set of terms can be re-generated with "ruby devel/revs_lc_automobile_terms.rb"
      AUTOMOBILE_LC_TERMS= File.open(REVS_LC_TERMS_FILENAME,'rb'){|io| Marshal.load(io)} if File.exists?(REVS_LC_TERMS_FILENAME)
      REVS_MANIFEST_HEADERS_FILE = File.open(REVS_MANIFEST_HEADERS_FILEPATH)
      REVS_MANIFEST_HEADERS = YAML.load( REVS_MANIFEST_HEADERS_FILE)
      
      
      def get_manifest_section(section)
        return REVS_MANIFEST_HEADERS[section]
      end
      
      def manifest_headers_file()
        return REVS_MANIFEST_HEADERS_FILE
      end
      
      def manifest_headers_path()
        return MAINFEST_HEADERS_FILEPATH
      end
      
      def manifest_register_section_name()
        return REGISTER
      end
      
      def manifest_metadata_section_name()
        return METADATA
      end
      
      def read_csv_with_headers(file)
        # load CSV into an array of hashes, allowing UTF-8 to pass through, deleting blank columns
        #file_contents = IO.read(file).force_encoding("ISO-8859-1").encode("utf-8", replace: nil) 
        file_contents = IO.read(file)
        csv = CSV.parse(file_contents, :headers => true)
        return csv.map { |row| row.to_hash.with_indifferent_access }
      end
      
      #Pass this function a list of all CSVs containing metadata for files you are about to register and it will ensure each sourceid is unique 
      def unique_source_ids(file_paths)
        files = Array.new
        file_paths.each do |fp|
          files << read_csv_with_headers(fp)
        end
        
        sources = Array.new
        files.each do |file|
          file.each do |row|
            #Make sure the sourcid and filename are the same
            fname = row[get_manifest_section(REGISTER)['filename']].chomp(File.extname(row[get_manifest_section(REGISTER)['filename']]))
            return false if row[get_manifest_section(REGISTER)['sourceid']] != fname
            sources << row[get_manifest_section(REGISTER)['sourceid']]
          end
          
          
         
        end
        return sources.uniq.size == sources.size
      
      end
      
      
      #Pass this function a CSV file and it will return true if the proper headers are there and each entry has the required fields filled in
      def valid_to_register(file_path)
        
        file = read_csv_with_headers(file_path)
        #Make sure all the required headers are there
        return false if not get_manifest_section(REGISTER).values-file[0].keys == []
        
        #Make sure all files have entries for those required headers
        file.each do |row|
          get_manifest_section(REGISTER).keys.each do |header| # label should be there as a column but does not always need a value
            return false if header.downcase !='label' && row[header].blank? #Alternatively consider row[header].class != String or row[header].size <= 0
          end
        end
       return true
      end
      
      #Pass this function a CSV file and it will return true if the proper headers are there and each entry has the required fields filled in.  
      def valid_for_metadata(file_path)
        file = read_csv_with_headers(file_path)
        file_headers=file[0].keys
        #The file doesn't need to have all the metadata values, it just can't have headers that aren't used for metadata or registration
        if file_headers.include?('date') && file_headers.include?('year') # can't have both date and year 
          return false
        elsif file_headers.include?('location') && file_headers.include?('state') && file_headers.include?('city') && file_headers.include?('country') # can't have both location and the specific fields
          return false
        else
          return file_headers-get_manifest_section(METADATA).values-get_manifest_section(REGISTER).values == []
        end
      end

      def clean_collection_name(name)
        return "" if name.blank? || name.nil?
        name=name.to_s
        name.gsub!(/\A(the )/i,'')
        name.gsub!(/( of the revs institute)\z/i,'')
        name.gsub!(/( of the revs institute for automotive research)\z/i,'')
        name.gsub!(/( of the revs institute for automotive research, inc)\z/i,'')
        name.gsub!(/( of the revs institute for automotive research, inc.)\z/i,'')
        return name.strip
      end

      def clean_marque_name(name)
        return "" if name.blank? || name.nil?
        name=name.to_s
        name.gsub!(/(automobiles)\z/i,'')
        name.gsub!(/(automobile)\z/i,'')
        return name.strip
      end
            
      def parse_location(row, location)
        row[location].split(/[,|]/).reverse.each do |local|
          country = revs_get_country(local)
          city_state = revs_get_city_state(local) 
          row['country'] = country.strip if country 
          if city_state
            row['state'] = revs_get_state_name(city_state[1].strip)
            row['city'] = city_state[0].strip
          end
          if not city_state and not country
            row['city_section'] = local
          end
        end

        return row
      end

      def revs_check_format(format)
        return revs_check_formats([format]).first
      end
      
      # check the incoming format and fix some common issues
      def revs_check_formats(format)
        known_fixes = {"black-and-white negative"=>"black-and-white negatives",
                       "color negative"=>"color negatives",
                       "slides/color transparency"=>"color transparencies",
                       "color negatives/slides"=>"color negatives",
                       "black-and-white negative strips"=>"black-and-white negatives",
                       "black and white"=>"black-and-white negatives",
                       "black-and-white"=>"black-and-white negatives",                       
                       "black and white negative"=>"black-and-white negatives",
                       "black and white negatives"=>"black-and-white negatives",
                       "color transparency"=>"color transparencies",
                       "slide"=>"slides"
                     }
        count = 0 
        format.each do |f|
          format[count] = known_fixes[f.downcase] || f.downcase
          count += 1
        end
        return format
      end

      # lookup the marque sent to see if it matches any known LC terms, trying a few varieties; returns a hash of the term and its ID if match is found, else returns false
      def revs_lookup_marque(marque)
        result=false
        variants1=[marque,marque.capitalize,marque.singularize,marque.pluralize,marque.capitalize.singularize,marque.capitalize.pluralize]
        variants2=[]
        variants1.each do |name| 
          variants2 << "#{name} automobile" 
          variants2 << "#{name} automobiles"
        end
        (variants1+variants2).each do |variant|
          lookup_term=AUTOMOBILE_LC_TERMS[variant]
          if lookup_term
            result={'url'=>lookup_term,'value'=>variant}
            break
          end
        end
        return result
      end # revs_lookup_marque

      # check if the string passed is a country name or code -- if so, return the country name, if not a recognized country, return false
      def revs_get_country(name)
        name='US' if name=='USA' # special case; USA is not recognized by the country gem, but US is
        country=Country.find_country_by_name(name.strip) # find it by name
        code=Country.new(name.strip) # find it by code
        if country.nil? && code.data.nil? 
          return false
        else
          return (code.data.nil? ? country.name : code.name)
        end
      end # revs_get_country

      # parse a string like this: "San Mateo (Calif.)" to try and figure out if there is any state in there; if found, return the city and state as an array, if none found, return false
      def revs_get_city_state(name)
        state_match=name.match(/[(]\S+[)]/)
        if state_match.nil?
          return false
        else
          first_match=state_match[0]
          state=first_match.gsub(/[()]/,'').strip # remove parens and strip
          city=name.gsub(first_match,'').strip # remove state name from input string and strip
          return [city,state]
        end
      end # revs_get_city_state

      # given an abbreviated state name (e.g. "Calif." or "CA") return the full state name (e.g. "California")
      def revs_get_state_name(name)
        test_name=name.gsub('.','').strip.downcase
        us=Country.new('US')
        us.states.each do |key,value|
          if value['name'].downcase.start_with?(test_name) || key.downcase == test_name
            return value['name']
            break
          end
        end
        return name
      end # revs_get_state_name


      # tell us if the string passed is a valid year
      def is_valid_year?(date_string,starting_year=1800)
        date_string.to_s.strip.scan(/\D/).empty? and (starting_year..Date.today.year).include?(date_string.to_i)
      end

      # tell us if the string passed is in is a full date of the format M/D/YYYY, and returns the date object if it is valid
      def get_full_date(date_string)
        begin
          date_obj=Date.strptime(date_string.gsub('-','/').delete(' '), '%m/%d/%Y')
          return (is_valid_year?(date_obj.year.to_s) ? date_obj : false)
        rescue
          false
        end
      end

      # given a string with dates separated by commas, split into an array
      # also, parse dates like "195x" and "1961-62" into all dates in that range
      def parse_years(date_string)
        date_string.delete!(' ')
        if date_string.include?('|')
          result=date_string.split('|')
        else
          result=date_string.split(',')
        end
        years_to_add=[]
        result.each do |year|

          if year.scan(/[1-2][0-9][0-9][0-9][-][0-9][0-9]/).size > 0 # if we have a year that looks like "1961-62" or "1961-73", lets deal with it turning it into [1961,1962] or [1961,1962,1963,1964,1965,1966,1967...etc]
            start_year=year[2..3]
            end_year=year[5..6]
            stem=year[0..1] 
            for n in start_year..end_year
              years_to_add << "#{stem}#{n}"
            end
          elsif year.scan(/[1-2][0-9][0-9][0-9][-][1-9]/).size > 0 # if we have a year that lloks like "1961-2" or "1961-3", lets deal with it turning it into [1961,1962] or [1961,1962,1963]
            start_year=year[3..3]
            end_year=year[5..5]
            stem=year[0..2]
            for n in start_year..end_year
              years_to_add << "#{stem}#{n}"
            end
          end

          if year.scan(/[1-2][0-9][0-9][0](('s)|s)/).size > 0 || year.scan(/[1-2][0-9][0-9][x_]/).size > 0 # if we have a year that looks like "195x", let's deal with it by turning it into [1950,1951,1952..etc]
            result.delete(year) # first delete the year itself from the list
            stem=year[0..2] # next get the stem, and expand into the whole decade
            %w{0 1 2 3 4 5 6 7 8 9}.each {|n| years_to_add << "#{stem}#{n}"} # add each year in that decade to the output array
          end

          if year.scan(/[1-2][0-9][0-9][0-9][-][1-2][0-9][0-9][0-9]/).size > 0 # if we have a year that lloks like "1961-1962" or "1930-1955", lets deal with it turning it into [1961,1962] or [1961,1962,1963]
            start_year=year[0..3]
            end_year=year[5..8]
            if end_year.to_i - start_year.to_i < 10 # let's only do the expansion if we don't have some really large date range, like "1930-1985" .. only ranges less than 9 years will be split into separate years
              for n in start_year..end_year
                years_to_add << n
              end
            end
          end

        end

        result = result.uniq
        result.each do |year|
          result.delete(year) if not year.scan(/\A[1-2][0-9][0-9][0-9]\z/).size == 1  #If it doesn't fit the format #### remove it
        end
        return result.concat(years_to_add).uniq.sort

      end

  end
end
