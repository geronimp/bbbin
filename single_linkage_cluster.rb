#!/usr/bin/env ruby

require 'csv'

clusters = {}

$stderr.puts "warning: currently this script does not care about the singletons"

unless ARGV.length == 1
  $stderr.puts "usage: single_linkage_cluster.rb <JOIN_FILE>"
  $stderr.puts "  where <JOIN_FILE> is a tab-separated list of linkages"
  $stderr.puts
  exit 1
end

# Read in and parse
group_number = 1
CSV.foreach(ARGV[0], :col_sep => "\t") do |row|
  one = row[0]
  two = row[1]

  next if one == two #things blast against themselves. dir.

  # if both have a hit, that is the hardest case
  if clusters[one] and clusters[two]
    # assign all to two's cluster, since that will probably result in less numbers being turned over
    old_one_number = clusters[one]
    clusters[one] = clusters[two]
    clusters.each {|key, value| clusters[key] = clusters[two] if value == old_one_number} # look for other A values

  # elsif only one has a hit, that's easy
  elsif clusters[one]
    clusters[two] = clusters[one] # assign two to one's cluster
  elsif clusters[two]
    clusters[one] = clusters[two] # assign one to two's cluster (less likely to happen)

  # else there is no hit, so this is a new group completely
  else
    clusters[one] = group_number
    clusters[two] = group_number
    group_number += 1
  end
end

# Print out the clusters
# Reverse the cluster so that numbers point to arrays
reversed = {}
clusters.each do |seq, number|
  reversed[number] ||= []
  reversed[number].push seq
end
# Print the reversed cluster
reversed.each do |key, hits|
  hits.each do |h|
    puts [key,h].join("\t")
  end
end

