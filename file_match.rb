require 'yaml'
require 'find'
require 'rethinkdb'
include RethinkDB::Shortcuts

config = YAML.load_file("config/database.yml")
host = config["database"]["host"] || "localhost"
port = config["database"]["port"] || "28015"
db = config["database"]["db"] || "dropsuite_test"

conn = r.connect(host: host, port: port, db: db)

r.db_create("dropsuite_test").run(conn) unless r.db_list.run(conn).include?("dropsuite_test")

database = r.db('dropsuite_test')

database.table_create('files').run(conn) unless database.table_list().run(conn).include?("files")

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

url = ARGV[0]
puts "Going to open dir '#{url}'"


file_paths = []
Find.find(url) do |path|
  fh = open path
  file_paths << {path: path, content: fh.read.force_encoding("ISO-8859-1").encode("UTF-8") } if File.file?(path) && !path.include?(".DS_Store") && !path.include?(".keep")
  fh.close
end

database.table("files").insert(file_paths).run(conn)
result = database.table('files').group('content').count().run(conn)

database.table("files").delete.run(conn)

if result.empty?
  puts "No file in directory #{url}" 
else
  result = result.sort_by {|key, value| value}
  content = result.last.first.dup
  puts "#{content.force_encoding('UTF-8').encode('ISO-8859-1')} #{result.last.last}"
end