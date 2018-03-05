require 'find'
require 'rethinkdb'
include RethinkDB::Shortcuts

conn = r.connect(host: "localhost", port: 28015, db: "dropsuite_test")

r.db_create("dropsuite_test").run(conn) unless r.db_list.run(conn).include?("dropsuite_test")

database = r.db('dropsuite_test')

database.table_create('files').run(conn) unless database.table_list().run(conn).include?("files")
# url = "/Users/bayu-worka/Documents/projects/DropsuiteTest"

database.table("files").delete.run(conn)

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

url = ARGV[0]
puts "Going to open dir '#{url}'"


file_paths = []
Find.find(url) do |path|
  fh = open path
  file_paths << {path: path, content: fh.read} if File.file?(path) && !path.include?(".DS_Store")
  fh.close
end

database.table("files").insert(file_paths).run(conn)
result = database.table('files').group('content').count().run(conn)

if result.empty?
  puts "No file in directory #{url}" 
else
  "#{result.first.first} #{result.first.last}"
end