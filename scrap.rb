require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'date'
require 'time'
require './parsething'
#require 'ap'
require 'ruby-debug'
require 'sequel'
$database_path = "sqlite://12attendance.db"


@hp = Hpricot(open("http://www.parliament.gov.sg/publications/votes-and-proceedings12th"))

db = Sequel.connect("#$database_path")
dataset = db[:attendance]

if db.table_exists? :attendance
  maxdate = DateTime.parse(dataset.max(:date))
end
# get the max date from the database
# compare it with the parse_date

#@hp.search("//a[@class='pub']").each do |link|
elements = @hp.search("//div[@id='bill_introduced']/table")
(elements/"//a").each do |link|
#@hp.search("//a[@class='pub']").each do |link|
  @date = link.inner_html.gsub(/\s{2,}/, " ")
  #puts @date
  @parse_date = DateTime.parse(@date)
#  puts @parse_date
  if !maxdate.nil? && @parse_date <= maxdate
  else
  m1 = system("wget -U firefox \"#{link["href"]}\" -O #{@parse_date}.pdf > /dev/null")
  m2 = system("pdftotext #{@parse_date}.pdf -enc UTF-8 > /dev/null")
  puts @parse_date

  if @parse_date.to_s == "2011-10-10T00:00:00+00:00"
    puts "WADADADASDSDSA"
  end
  begin
   @go = Parsething.new("#{@parse_date}.txt", link["href"])
   @go.parse
  puts link["href"]
  rescue Exception=>e
    puts "Rescued"
    puts "--"
    puts e.inspect
    puts link["href"]
    puts "-----"
  end
 end
end

puts "Scraping completed ..."
puts " "
Parsething.generate_stats
