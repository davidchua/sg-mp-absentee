class Parsething

  def initialize(doc, link)
    data = String.new
    @filename = doc.to_s
    f = File.open(doc.to_s, "r:utf-8")
    f.each_line do |line|
      data += line
    end
    @doc = data.to_s
    @link = link
  end

  def self.generate_stats
    @db = Sequel.connect("#$database_path")
    items = @db[:attendance]
    latest_date = @db[:attendance].max(:date)
    latest_absentees = @db[:attendance].filter(:date => latest_date).all
    puts "Total number of Parliament Sittings with Absentee Records:"
    puts @db[:attendance].get{count(DISTINCT date)}
    puts "----------------------------"
    puts "Absentees on Last Parliament Sitting:  #{Time.parse(latest_date).strftime('%d/%m/%Y')}"
    puts "----------------------------"
    latest_absentees.each do |t|
      puts "#{t[:name]} of #{t[:ward]}"
    end
    puts ""
    puts "----------------------------"
    puts "Stats"
    puts "----------------------------"
    puts "Top 5 absent MPs:"
    @db.fetch("select name, count(name) AS count from attendance GROUP BY name ORDER BY count(name) DESC LIMIT 0,5") do |row|
      puts "#{row[:name]} with #{row[:count]}"
    end
    puts " "
    puts "Top 5 wards with highest number of absentees:"
    @db.fetch("select ward, count(ward) AS count from attendance GROUP BY ward ORDER BY count(ward) DESC LIMIT 0,5") do |row|
      puts "#{row[:ward]} with #{row[:count]}"
    end
    puts " "
  end

  def parse
    require 'ruby-debug'
    # look through doc for the keyword 'ABSENT'
   # debugger
    @people = @doc[/ABSENT:(.*?)_{2,}?\n{1,}/m]
    if @people.nil?
      return
    end

#   @split = @people[/((Mr|Ms|Dr|RAdm (NS)|Mrs)*\s(\w)+(\s)+(.*)\n+)+/].split(/\n+/)
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w)+)+/].split(/\n+/)
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split(/\n+/)
    # look through results and then search for instances of names and split them
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split(/\n{2}/)

   @people.gsub!('Assoc. Prof.', 'Associate Professor')
   #debugger
   @split = @people[/((Mdm|Er|Prof|Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split('.')
    if !@split.nil?
        @db = Sequel.connect("#$database_path")
        @db.create_table? :attendance do
          primary_key :id
          String :name
          String :ward
          Boolean :attended
          DateTime :date
          String :link
          String :parliament
        end
    end
    @split.each do |t|
      # is ______?
      if t =~ /[_]+/
        puts "WHAT"
        break
      end
      if !t.match(/Mdm|Prof|Er|Mr|Ms|Dr|RAdm|Mrs|Assoc/).nil?
      # remove the redundant '\n' from the line
       t = t.gsub(/\n/, ' ')
  #     ap t
      # only capture the name of member
      name = t.gsub(/([(].+[)])(.*)+/, '').strip
#      puts name
      items = @db[:attendance]
      ward = t[/([(].+[)])+/][1..-2]
      if name == "Mr SPEAKER"
        name = ward.gsub(/([(].+[)])(.*)+/, '').strip
        ward = ward[/([(].+[)])+/][1..-2]
        puts name
        puts ward
      end

      name = name.split.map { |x| x.capitalize}.join(' ')
      ward = ward.split.map { |x| x.capitalize}.join(' ')
      items.insert(:name => name, :ward => ward, :attended => false, :parliament => "12", :date => @filename.to_s.gsub('.txt', ''), :link => @link)
      else
      end
    end
#    @people = @doc[/ABSENT:\n+(.*)-{10}/m, 1].split(/\n+/)
  end
end

if $0 == __FILE__
  require "test/unit"

  class ParsethingTest < Test::Unit::TestCase
    def test_it
      @doc = "foo\n\nbar\n\nbaz\nABSENT:\n\nSomeone\nOther person\n\n\n\nSomeone else\n----------\n\nFoo"
      @parsething = Parsething.new(@doc)
      @parsething.parse

      assert_equal ["Someone", "Other person", "Someone else"], @parsething.people
    end
  end
end
