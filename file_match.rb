require 'yaml'
require 'find'
require 'rethinkdb'
include RethinkDB::Shortcuts

config = YAML.load_file("config/database.yml")
host = config["database"]["host"] || "localhost"
port = config["database"]["port"] || "28015"
db = config["database"]["db"] || "dropsuite_test"
timeout = config["database"]["timeout"] || 20

conn = r.connect(host: host, port: port, db: db, timeout: timeout)

r.db_create(db).run(conn) unless r.db_list.run(conn).include?(db)

database = r.db(db)

database.table_create('files').run(conn) unless database.table_list().run(conn).include?("files")

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

url = ARGV[0]
puts "Going to open dir '#{url}'"


file_paths = []
Find.find(url) do |path|
  if File.file?(path) && !path.include?(".DS_Store") && !path.include?(".keep")
    file_content = ""
    IO.foreach(path) { |line| file_content << line.force_encoding("ISO-8859-1").encode("UTF-8") }
    file_paths << {path: path, content: file_content }
  end
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