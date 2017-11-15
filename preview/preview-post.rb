require 'redcarpet'
require 'yaml'

HEAD = File.read("head.html")
FOOT = File.read("foot.html")

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {
  no_intra_emphasis: true,
  tables: false,
  fenced_code_blocks: true,
  strikethrough: true,
  lax_spacing: false,
  underline: false,
  disable_indented_code_blocks: true
})

if not ARGV[0]
  puts "Please provide a blog post to preview!"
  exit 1
end

path = File.absolute_path(ARGV[0])
path_regex = /(.*)\/(\d{4}\/\d{2}\/\d{2})\/.*/
if not path =~ path_regex
  puts "Blog post must be under year, month, and date folders in 'YYYY/MM/DD' format."
  exit 2
end
date = Date.strptime(path.sub(path_regex, '\2'), "%Y/%m/%d")
root = path.sub(path_regex, '\1')

post = File.read(ARGV[0])
yaml = post.sub(/---\n(.*)\n---(.*)/m, '\1')
md   = post.sub(/---\n(.*)\n---(.*)/m, '\2')
md = md.gsub(/\/blog\//, "#{root}/")
yaml = YAML.load(yaml)

header = <<-eof
<div class="header">
<h2>#{yaml["title"]}</h2>
<p>By #{yaml["author"]} · #{date.strftime("%A, %B %e, %Y")}</p>
<p class="tags">Tags: #{yaml["tags"]}</p>
</div>
eof

File.open('preview.html', 'w') do |file|
  file.write(HEAD)
  file.write(header)
  file.write(markdown.render md)
  file.write(FOOT)
end
