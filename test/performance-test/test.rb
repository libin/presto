require 'tempfile'

ab = $*[0] || 'ab'

pids = {app: [], bench: []}
files = {}
results = Array.new

{
    'rack' => 60080,
    'presto' => 60082,
}.each_pair do |test, port|
  if pid = Process.spawn("ruby #{test}-app.rb #{port}")
    sleep 2
    pids[:app] << pid
    cmd = "#{ab} -n1000 -c100 -q localhost:#{port}/|grep 'Requests per second'"
    files[test] = Tempfile.new(test)
    pids[:bench] << Process.spawn(cmd, out: files[test].path)
  end
end

pids[:bench].each { |p| Process.wait(p) }
files.each_value do |file|
  file.rewind
  result = file.read.sub("Requests per second", "").strip
  results << result.sub(/.*\:\s+(.*)\s+\[.*/, '\1').to_f
end
pids[:app].each{|p| Process.kill(9, p)}

rack, presto = results
puts
puts "Requests per second:"
puts "  rack:   " + rack.to_s
puts "  presto: " + presto.to_s
puts "Presto Overhead: " + (((rack - presto)/rack) * 100).to_i.to_s + "%"
puts
