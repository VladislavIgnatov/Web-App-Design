# Extracts just the definitions from the grammar file
# Returns an array of strings where each string is the lines for
# a given definition (without the braces)
def read_grammar_defs(filename)
  filename = 'grammars/' + filename unless filename.start_with? 'grammars/'
  filename += '.g' unless filename.end_with? '.g'
  contents = open(filename, 'r') { |f| f.read }
  contents.scan(/\{(.+?)\}/m).map do |rule_array|
    rule_array[0]
  end
end


# Takes data as returned by read_grammar_defs and reformats it
# in the form of an array with the first element being the
# non-terminal and the other elements being the productions for
# that non-terminal.
# Remember that a production can be empty (see third example)
# Example:
#   split_definition "\n<start>\nYou <adj> <name> . ;\nMay <curse> . ;\n"
#     returns ["<start>", "You <adj> <name> .", "May <curse> ."]
#   split_definition "\n<start>\nYou <adj> <name> . ;\n;\n"
#     returns ["<start>", "You <adj> <name> .", ""]
def split_definition(raw_def)
  # TODO: your implementation here
  raw_def = raw_def.split(/\n/)[1..raw_def.length]
  raw_def = raw_def.map { |n| n.tr(";", "").strip() }
end


# Takes an array of definitions where the definitions have been
# processed by split_definition and returns a Hash that
# is the grammar where the key values are the non-terminals
# for a rule and the values are arrays of arrays containing
# the productions (each production is a separate sub-array)

# Example:
# to_grammar_hash([["<start>", "The   <object>   <verb>   tonight."], ["<object>", "waves", "big    yellow       flowers", "slugs"], ["<verb>", "sigh <adverb>", "portend like <object>", "die <adverb>"], ["<adverb>", "warily", "grumpily"]])
# returns {"<start>"=>[["The", "<object>", "<verb>", "tonight."]], "<object>"=>[["waves"], ["big", "yellow", "flowers"], ["slugs"]], "<verb>"=>[["sigh", "<adverb>"], ["portend", "like", "<object>"], ["die", "<adverb>"]], "<adverb>"=>[["warily"], ["grumpily"]]}
def to_grammar_hash(split_def_array)
  # TODO: your implementation here
  hashing = {}
  items = []
  firstRound = true
  puts()
  for i in 0..(split_def_array.length-1)
    split_def_array[i].each do |item|
      if(firstRound)
        firstRound = false
      else
        items.push(item.split())
      end
    end
    firstRound = true
    hashing[split_def_array[i][0]] = items
    items = []
  end
  print(hashing)
  puts()
  hashing
end

# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
  # TODO: your implementation here
  if(s.match(/<[a-z]*[0-9]*>/))
    return true
  else
    return false
  end
end

# Given a grammar hash (as returned by to_grammar_hash)
# returns a string that is a randomly generated sentence from
# that grammar
#
# Once the grammar is loaded up, begin with the <start> production and expand it to generate a
# random sentence.
# Note that the algorithm to traverse the data structure and
# return the terminals is extremely recursive.
#
# The grammar will always contain a <start> non-terminal to begin the
# expansion. It will not necessarily be the first definition in the file,
# but it will always be defined eventually. Your code can
# assume that the grammar files are syntactically correct
# (i.e. have a start definition, have the correct  punctuation and format
# as described above, don't have some sort of endless recursive cycle in the
# expansion, etc.). The names of non-terminals should be considered
# case-insensitively, <NOUN> matches <Noun> and <noun>, for example.
def expand(grammar, non_term="<start>")
  # TODO: your implementation here
  
end


# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(filename)
  # TODO: your implementation here
  x = read_grammar_defs(filename)
  grammer = []
  print(x)
  puts()
  puts()
  x.each do |item| #creat an 2d array for the function to_grammar_hash()
    print( split_definition(item))
    grammer.push(split_definition(item))
    puts()
  end
  puts()
  print( grammer)
  puts()
  hash = to_grammar_hash(grammer)  #check for the function to_grammar_hash()
  puts()
  print(is_non_terminal?(hash["<start>"][0][3])) #check for the function is_non_terminal?()
end

if __FILE__ == $0
  # TODO: your implementation of the following
  # prompt the user for the name of a grammar file
  # rsg that file
  #print( "Enter your file name: ")
  #STDOUT.flush
  filename = "poem"#gets.chomp
  puts "Your file name is " + filename
  puts()
  rsg(filename)
end