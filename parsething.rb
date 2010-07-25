class Parsething

  def initialize(doc, link)
    data = String.new
    @filename = doc.to_s
    f = File.open(doc.to_s, "r")
    f.each_line do |line|
      data += line
    end
    @doc = data.to_s
    @link = link
  end

  def parse

    # look through doc for the keyword 'ABSENT'
    @people = @doc[/ABSENT:\n+(.*)\n{2}/m,1]
    if @people.nil?
      return
    end

#   @split = @people[/((Mr|Ms|Dr|RAdm (NS)|Mrs)*\s(\w)+(\s)+(.*)\n+)+/].split(/\n+/)
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w)+)+/].split(/\n+/)
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split(/\n+/)
    # look through results and then search for instances of names and split them
#   @split = @people[/((Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split(/\n{2}/)


   @split = @people[/((Mdm|Er|Prof|Mr|Ms|Dr|[RAdm (NS)]|Mrs|[Assoc. Prof.])*\s(\w)+(.*)(\n|\w|[.])+)+/].split(/\n{2}/)
    if !@split.nil?
        @db = Sequel.connect('sqlite://attendance.db')
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
      items.insert(:name => name, :ward => ward, :attended => false, :parliament => "11", :date => @filename.to_s.gsub('.txt', ''), :link => @link)
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
