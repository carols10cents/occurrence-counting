require 'benchmark/ips'

def bench(arr)
  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 2)

    x.report("uniq-count") { arr.uniq.map { |x| [x, arr.count(x)] }.to_h }
    x.report("hash-each") { h = Hash.new(0); arr.each { |l| h[l] += 1 }; h }
    x.report("reduce-to-i") { arr.reduce({}) { |m, a| m[a] = m[a].to_i + 1; m } }
    x.report("inject") { arr.inject(Hash.new(0)) { |h, i| h[i] += 1; h } }
    x.report("chunk") { arr.sort.chunk { |ex| ex }.map { |k, v| [k, v.length] }.to_h }
    x.report("reduce-or-0") { arr.reduce({}) { |ret, val| ret[val] = (ret[val] || 0) + 1; ret }	}
    x.report("each-with-hash-new") { arr.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }	}
    x.report("each-with-empty-hash") { arr.each_with_object({}) { |item, memo| memo[item] ||= 0; memo[item] += 1 }	}
    x.report("map-inject") { arr.map { |x| { x => 1 } }.inject { |a, b| a.merge(b) { |k, x, y| x + y } } }
    x.report("group-by") { arr.group_by { |x| x }.map { |element, matches| [ element, matches.length ] }.to_h }
    x.report("group-by-itself") { Hash[arr.group_by(&:itself).map {|k,v| [k, v.size] }] }
    x.report("chunk-by-itself") { arr.sort.chunk(&:itself).map {|v, vs| [v, vs.count]}.to_h }

    x.compare!
  end
end

def data(size, items)
  size.times.map { items.sample }
end

items = "abcdefghijklmnopqrstuvwxyz".split("")

(1..10).each do |pow|
  pow_of_10 = 10 ** pow
  puts "Benching with array of length #{pow_of_10}"
  bench(data(pow_of_10, items))
end
