require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'date'
require 'time'
require 'parsething'
require 'ap'
require 'ruby-debug'
require 'sequel'

@hp = Hpricot(open("http://www.parliament.gov.sg/Publications/votes_11thParl.htm"))

db = Sequel.connect('sqlite://attendance.db')
dataset = db[:attendance]

if db.table_exists? :attendance
  maxdate = DateTime.parse(dataset.max(:date))
end
# get the max date from the database
# compare it with the parse_date

@hp.search("//a[@class='pub']").each do |link|
  @date = link.inner_html.gsub(/\s{2,}/, " ")
  @parse_date = DateTime.parse(@date)
  if !maxdate.nil? && @parse_date <= maxdate 
  else
  system("wget http://www.parliament.gov.sg/Publications/#{link["href"]} -O #{@parse_date}.doc")
  system("catdoc #{@parse_date}.doc > #{@parse_date}.txt")
    @go = Parsething.new("#{@parse_date}.txt", link["href"])
    @go.parse
  system("rm #{@parse_date}.txt #{@parse_date}.doc")
  puts link["href"]
 end

  puts "Scraping completed ..."
end
