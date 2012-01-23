class Wordmap
  def initialize(path_to_wordmap)
    @wordmap = {}
    @revmap = {}
    IO.foreach(path_to_wordmap) do |line|
      if line.strip.size > 0
        word,index = *(line.strip.split(/\s+/))
        word = word.split("_")[0] if word.include?("_")
        @wordmap[index.to_i] = word.to_sym
        @revmap[word.to_sym] = index.to_i
      end
    end
  end
  
  def lookup(index)
    @wordmap[index]
  end
  
  def reverse_lookup(word)
    word = word.to_sym if word.respond_to?(:to_sym)
    @revmap[word]
  end
  
  def each(&block)
    self.words.each { |x| yield x }
  end
  
  def each_pair(&block)
    @wordmap.each_pair { |k,v| yield(k,v) }
  end
  
  def map(&block)
    self.words.map { |x| yield x }
  end
  
  def words
    @wordmap.values.uniq
  end

  alias :[] :lookup
end