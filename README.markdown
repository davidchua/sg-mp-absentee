# Singapore Members of Parliament's Absentee Record

Simple script to scrap data from Singapore Parliament's proceeding reports. This
script helps to track MP's absentee records and outputs the result into a sqlite3
database.

## Usage

1. Clone the repository
2. Make sure you have the following gems:
 rubygems
 sequel
 hpricot 
3. You'd also need sqlite3
4. run 'ruby scrap.rb'

### Changing the name of your database

To change your sqlite3 database name or path, you have to edit both scrap.rb and parsething.rb.

## Todo

- Allow script to actually pull data from 11th Parliament despite being uploaded
- To reduce the number of gem dependency
- The ability to generate attendance statistics within the script

## License

The MIT License

Copyright (c) 2010 David Chua

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


