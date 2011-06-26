require 'spec/spec_helper.rb'
require 'zip/zipfilesystem'

describe Importer::EquityBhav do

  describe 'processing dates' do
    before(:each) do
      @http = stub()
      Net::HTTP.expects(:new).with(NSE_URL).returns(@http)
      @importer = Importer::EquityBhav.new
    end

    it "should import start from next day of last available date upto current date" do
      EqQuote.expects(:maximum).returns(Date.parse('2/1/2010'))
      Date.stubs(:today).returns(Date.parse('2/4/2010'))
      @http.expects(:request_get).with('/content/historical/EQUITIES/2010/FEB/cm02FEB2010bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(stub(:class => Net::HTTPNotFound))
      @http.expects(:request_get).with('/content/historical/EQUITIES/2010/FEB/cm03FEB2010bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(stub(:class => Net::HTTPNotFound))
      @http.expects(:request_get).with('/content/historical/EQUITIES/2010/FEB/cm04FEB2010bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(stub(:class => Net::HTTPNotFound))
      @importer.import
    end

    it "should import start from Jan 1, 2005 if no prior equity quote" do
      EqQuote.expects(:maximum).returns(nil)
      Date.stubs(:today).returns(Date.parse('1/2/2005'))
      @http.expects(:request_get).with('/content/historical/EQUITIES/2005/JAN/cm01JAN2005bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(stub(:class => Net::HTTPNotFound))
      @http.expects(:request_get).with('/content/historical/EQUITIES/2005/JAN/cm02JAN2005bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(stub(:class => Net::HTTPNotFound))
      @importer.import
    end
  end

  describe 'processing bhav file content' do

    before(:all) do
      @http = stub()
      Net::HTTP.expects(:new).with(NSE_URL).returns(@http)
      @importer = Importer::EquityBhav.new
      EqQuote.expects(:maximum).returns(Date.parse('6/23/2011'))
      Date.stubs(:today).returns(Date.parse('6/24/2011'))
      response = stub(:body => File.open('spec/data/cm24JUN2011bhav.csv.zip').read )
      @http.expects(:request_get).with('/content/historical/EQUITIES/2011/JUN/cm24JUN2011bhav.csv.zip', {'User-Agent' => 'Firefox'}).returns(response)
      @importer.import
    end

    it "should import end of day data from zip file" do
      stock = Stock.find_by_symbol('20MICRONS')
      quote = EqQuote.find_by_stock_id(stock.id)
      quote.open.should == 46
      quote.high.should == 47.8
      quote.low.should == 45.6
      quote.close.should == 46.5
      quote.previous_close.should == 46.05
      quote.traded_quantity.should == 10706
    end

    it "should import all valid quotes" do
      EqQuote.count.should == 3
    end

    it "should update 10, 50, 200 days moving average" do
      stock = Stock.find_by_symbol('20MICRONS')
      quote = EqQuote.find_by_stock_id(stock.id)
      quote.mov_avg_10d.should_not eq(0)
      quote.mov_avg_50d.should_not eq(0)
      quote.mov_avg_200d.should_not eq(0)
    end

    it "should handle new stock codes" do
      Stock.count.should == 3
    end

  end
end