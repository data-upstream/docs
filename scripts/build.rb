#!/usr/bin/env ruby

require 'json'

def root
  File.expand_path(File.dirname(File.dirname(__FILE__)))
end

def variables_path
  File.join(root, 'config', 'variables.json')
end

def source_path
  File.join(root, 'src', 'docs.md')
end

def dist_path
  File.join(root, 'dist', 'docs.md')
end

def variables
  file = File.read(variables_path)
  JSON.parse(file)
end

def source
  File.read(source_path)
end

def write_dist(str)
  File.write(dist_path, str)
end

def substitute(str, vars)
  vars.each.reduce(str) do |str, (key, value)|
    str.gsub("___#{key}___", value)
  end
end

write_dist(substitute(source, variables))
