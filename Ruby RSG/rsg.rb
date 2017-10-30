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
  raw_def = raw_def.split(/;\n*/) #split each ;

  if(raw_def[0].match("<start>")) #spliting strings cased on each .g file pattern
    raw_def[0] = raw_def[0].split(/\n+\t*(<start>) *\n+\t*/)
  else
    raw_def[0] = raw_def[0].split(/\n+\t*(<.+?>) *\n*\t*/)
  end

  raw_def = raw_def.flatten #make it 1 dimensional array
  raw_def[0] = ""
  while raw_def[0] == "" do   #remove empty elements from the beginning of the array
    raw_def.shift
  end

  return raw_def
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
  firstRound
  for i in 0..(split_def_array.length-1)
    split_def_array[i].each do |item|
      if(firstRound) #skips the first elements in the inner arrays, elements with patten <('*\w*_*-*\d*_*-*\w*)*>
        firstRound = false
      else
        items.push(item.split())
      end
    end
    firstRound = true
    hashing[split_def_array[i][0]] = items
    items = []
  end
  hashing
end

# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
  # TODO: your implementation here
  if(s.length > 1)
    if(s.match(/<('*\w*_*-*\d*_*-*\w*)*>/)) #it looks for all the possible words between <>
      return true
    else
      return false
    end
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
  i = rand(0..((grammar[non_term].length)-1)) #generate a random number used to generate the random sentence
  x = ''

  grammar[non_term][i].each do |item| #it starts with the <start> => array first and recursively generate the sentence
    if(!is_non_terminal?(item)) #base case
      if(item === "." or item === ",") #check for the end of the sentence or comma
        x = x.rstrip + item +  " "
      else
        x = x  + item + " "
      end
    else
      x = x + String(expand(grammar, non_term=item)) #recursion
    end
  end
  x
end


# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(filename)
  # TODO: your implementation here
  x = read_grammar_defs(filename) #reads the grammer
  grammer = []
  x.each do |item| #creats a 2d array for the function to_grammar_hash()
    grammer.push(split_definition(item))
  end

  hash = to_grammar_hash(grammer)  #Calling for the function to_grammar_hash()

  randomSentence = expand(hash) #calling the expand function to return the random sentence
  puts(randomSentence) #prints the random sentence.

end

if __FILE__ == $0
  # TODO: your implementation of the following
  # prompt the user for the name of a grammar file
  # rsg that file
  filename = ""
  while filename != "0"  do
    puts()

    print( "Enter your file name (0 to Exit): ")
    STDOUT.flush
    filename = gets.chomp

    if(filename != "0")
      begin
        rsg(filename)
      rescue Exception => e
        puts("File does not exists! try again!")
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end
end