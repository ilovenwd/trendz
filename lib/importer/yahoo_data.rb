module Importer
  class YahooData
    include Connectable
    BASEURL = 'ichart.finance.yahoo.com'

    def import
      stocks = Stock.all(:conditions => 'yahoo_code is not null')
      stocks.each do |stock|
        path = construct_sub_path(stock)
        response = connection(BASEURL).request_get(path)
        next if response.class == Net::HTTPNotFound
        process_data(response, stock)
      end
    end

    private
    def process_data(response, stock)
      data_rows = CSV.parse(response.body)
      data_rows.reverse.each do |row|
        next if row[0] == 'Date'
        date = Date.parse(row[0])
        quote = EqQuote.find_or_create_by_stock_id_and_date(stock.id, date)
        quote.update_attributes(:open=>row[1], :high=>row[2], :low=>row[3],
                       :close=>row[4], :traded_quantity=>row[5])
        quote.save!
        MovingAverageCalculator.update(date, stock)
      end
    end

    def construct_sub_path(stock)
      today = Date.today
      start_date = (EqQuote.maximum(:date, :conditions => "stock_id = #{stock.id} and traded_quantity is not null") or Date.parse(START_DATE)) + 1
      params_hash = {:s=> CGI.escape(stock.yahoo_code),
                     :a=> start_date.month - 1, :b=> start_date.day, :c=> start_date.year,
                     :d=> today.month - 1, :e=> today.day, :f=> today.year,
                     :g=> 'd', :ignore=> '.csv'}
      path = params_hash.inject('/table.csv?') { |params, pair| "#{params}&#{pair.first}=#{pair.last}" }
    end
  end
end
