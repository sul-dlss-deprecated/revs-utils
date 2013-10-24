require 'spec_helper'

describe "Revs-Utils" do

  before(:each) do
    
    @revs=RevsUtilsTester.new # a class defined in the spec_helper which includes the module methods we need to test 
    
  end
  
  it "should parse 1950s correctly" do
    
    @revs.parse_years('1950s').should == ['1950','1951','1952','1953','1954','1955','1956','1957','1958','1959']    
    
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

  it "should parse 1955-1957 correctly" do
    
    @revs.parse_years('1955-1957').should == ['1955','1956','1957']    
    
  end

end
