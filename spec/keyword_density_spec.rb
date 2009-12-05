require File.dirname(__FILE__) + '/../lib/keyword_density'

module DensityTestHelper
  protected
  def empty_keyword
    @empty_keyword ||= KeywordDensity.new
  end
  def stemmable_keyword
    "keywords"
  end
  def stemmed_keyword
    "keyword"
  end
  def stemmable_phrase1
    "monster keywords"
  end
  def stemmed_phrase1
    "monster keyword"
  end
  def stemmable_phrase2
    "monsters keywords"
  end
  def stemmed_phrase2
    "monster keyword"
  end
  def singularize_keyword
    "keywords"
  end
  def singularize_phrase1
    "monster keywords"
  end
  def singularized_phrase1
    "monster keyword"
  end
  def singularize_phrase2
    "monsters keywords"
  end
  def singularized_phrase2
    "monster keyword"
  end
  def first_stopword
    empty_keyword.stop_words.first
  end
  def current_stopword
    empty_keyword.stop_words.last
  end
  def bad_stopword
    first_stopword + "junk123"
  end
  def alpha_space_str
    "abasdf ndsfds "
  end
  def alpha_double_space_str
    "asdfaffdf   ffdbff"
  end
  def non_alpha_str
    "asdfs 123 dfd ff 090 ...;;''qq
    
    x
    "
  end
  def upper_alpha_space_str
    alpha_space_str.upcase
  end
  def upper_alpha_double_space_str
    alpha_double_space_str.upcase
  end
  def upper_non_alpha_str
    non_alpha_str.upcase
  end
  def three_letter_word
    "qqq"
  end
  def three_letter_word2
    "xxx"
  end
  def only_1_or_2_letters
    "xx aa ff gg "
  end
  def has_1_3_letter_word
    "#{only_1_or_2_letters} #{three_letter_word}"
  end
  def has_only_stop_words
    "#{first_stopword} #{current_stopword}"
  end
  def keyword1
    "keyword"
  end
  def keyword2
    "keywerd"
  end
  def has_1_keyword
    [keyword1]
  end
  def has_2_keywords
    [keyword1,keyword2]
  end
  def keyword1_plural
    "#{keyword1}s"
  end
  def keyword2_plural
    "#{keyword2}s"
  end
  def has_two_plural_keywords
    [keyword1_plural,keyword2_plural]
  end
  def multi_word_keyword
    "#{keyword1} #{keyword2}"
  end
  def has_multi_keyword
    [multi_word_keyword]
  end
  def has_singularize_keyword
    [keyword1_plural, keyword1]
  end
  def has_singularize_keyword
    [keyword1_plural, keyword1]
  end
  def pathological_possesive
    "sainsbury's"
  end
  def pathological_possesive_translate
    "sainsbury"
  end
end

describe KeywordDensity, "Base word processing functionality" do
  include DensityTestHelper
  specify "valid stopwords" do
    empty_keyword.stop_word?(first_stopword).should == true
    empty_keyword.stop_word?(current_stopword).should == true
    empty_keyword.stop_word?(bad_stopword).should == false
  end
  specify "remove non alphanumeric characters" do
    KeywordDensity.remove_noise(alpha_space_str).should_not =~ /[^[:alpha:] ]+/
    KeywordDensity.remove_noise(alpha_space_str).should == alpha_space_str.strip
    KeywordDensity.remove_noise(alpha_double_space_str).should_not =~ /  /
    KeywordDensity.remove_noise(non_alpha_str).should_not =~ /[^[:alpha:] ]+/
    KeywordDensity.remove_noise(non_alpha_str).should_not =~ /  /
  end
  specify "lower case string" do
    KeywordDensity.remove_noise(upper_alpha_space_str).should_not =~ /[A-Z]+/
    KeywordDensity.remove_noise(upper_alpha_space_str).should == upper_alpha_space_str.downcase.strip
    KeywordDensity.remove_noise(upper_alpha_double_space_str).should_not =~ /[A-Z]+/
    KeywordDensity.remove_noise(upper_non_alpha_str).should_not =~ /[A-Z]+/
    KeywordDensity.remove_noise(upper_non_alpha_str).should_not =~ /[A-Z]+/
  end
  specify "filter <= 2 letter words" do
    empty_keyword.clean_words_string(only_1_or_2_letters).should == []
    empty_keyword.clean_words_string(has_1_3_letter_word).length.should == 1
  end
  specify "filter only stop words" do
    empty_keyword.clean_words_string(has_only_stop_words).should == []
    empty_keyword.clean_words_string("#{has_1_3_letter_word} #{has_only_stop_words}" ).length.should == 1
  end
  it "should singularize keyword" do
    KeywordDensity::make_phrase_singular(singularize_keyword).should == keyword1
  end

  it "should singularize simple phrase" do
    KeywordDensity::make_phrase_singular(singularize_phrase1).should == singularized_phrase1
  end

  it "should singularize complex phrase" do
    KeywordDensity::make_phrase_singular(singularize_phrase2).should == singularized_phrase2
  end
  
  it "should translate possesive into singlular" do
    KeywordDensity::remove_noise(pathological_possesive).should == pathological_possesive_translate
  end

  it "should translate possesive into singlular" do
    KeywordDensity::remove_noise(pathological_possesive).should == pathological_possesive_translate
  end

  it "should stem keyword" do
    KeywordDensity::make_stem(singularize_keyword).should == stemmed_keyword
  end

  it "should stem simple phrase" do
    KeywordDensity::make_stem(singularize_phrase1).should == stemmed_phrase1
  end

  it "should stem complex phrase" do
    KeywordDensity::make_stem(singularize_phrase2).should == stemmed_phrase2
  end
  
end

describe KeywordDensity, "Processing stemmed words" do
  include DensityTestHelper
  specify "raw density count for one word" do
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_only_stop_words}" )
    empty_keyword.stemmed_words_count.should == {[three_letter_word] => 1}
    empty_keyword.num_stemmed_words.should == 1
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_1_3_letter_word} #{has_only_stop_words}" )
    empty_keyword.stemmed_words_count.should == {[three_letter_word] => 2,[three_letter_word,three_letter_word] => 1}
    empty_keyword.num_stemmed_words.should == 2
  end
  
  specify "raw density count for two words" do
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_only_stop_words} #{three_letter_word2}" )
    empty_keyword.stemmed_words_count.should == {[three_letter_word2] => 1, [three_letter_word] => 1,[three_letter_word, three_letter_word2] => 1}
    empty_keyword.num_stemmed_words.should == 2
    empty_keyword.search_word_counts.should == {}
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_1_3_letter_word} #{has_only_stop_words} #{three_letter_word2}" )
    empty_keyword.stemmed_words_count.should == {[three_letter_word] => 2, [three_letter_word2] => 1,[three_letter_word,three_letter_word] => 1, 
      [three_letter_word,three_letter_word2] => 1,[three_letter_word,three_letter_word,three_letter_word2] => 1}
    empty_keyword.num_stemmed_words.should == 3
  end

  specify "keyword and raw density count for one word" do
    one_kw = KeywordDensity.new has_1_keyword
    one_kw.get_keyword_density("#{keyword1} #{has_only_stop_words}" )
    one_kw.stemmed_words_count.should == {[keyword1] => 1}
    one_kw.num_stemmed_words.should == 1
    one_kw.search_word_counts[keyword1].should == 1
    one_kw.get_keyword_density("#{keyword1} #{keyword1} #{has_only_stop_words}" )
    one_kw.stemmed_words_count.should == {[keyword1] => 2,[keyword1,keyword1] => 1}
    one_kw.num_stemmed_words.should == 2
  end
  
  specify "keyword and raw density count for two words" do
    two_kw = KeywordDensity.new has_2_keywords
    two_kw.get_keyword_density("#{keyword1} #{keyword2} #{has_only_stop_words}" )
    two_kw.stemmed_words_count.should == {[keyword1] => 1, [keyword2] => 1,[keyword1,keyword2] => 1}
    two_kw.num_stemmed_words.should == 2
    two_kw.search_word_counts[keyword1].should == 1
    two_kw.search_word_counts[keyword2].should == 1
    two_kw.get_keyword_density("#{keyword1} #{keyword1} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    two_kw.stemmed_words_count.should == {[keyword1] => 2, [keyword2] => 2,
      [keyword1,keyword1] => 1,[keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword1,keyword2] => 1, [keyword1,keyword2,keyword2] => 1}
    two_kw.num_stemmed_words.should == 4
    two_kw.search_word_counts[keyword1].should == 2
    two_kw.search_word_counts[keyword2].should == 2
  end

  specify "keyword and raw density count for 2 plural words" do
    plural_kw = KeywordDensity.new has_two_plural_keywords
    plural_kw.get_keyword_density("#{keyword1} #{keyword2_plural} #{has_only_stop_words}" )
    plural_kw.stemmed_words_count.should == {[keyword1] => 1, [keyword2] => 1,[keyword1,keyword2] => 1}
    plural_kw.num_stemmed_words.should == 2
    plural_kw.search_word_counts[keyword1_plural].should == 1
    plural_kw.search_word_counts[keyword2_plural].should == 1
    plural_kw.get_keyword_density("#{keyword1} #{keyword1_plural} #{keyword2_plural} #{keyword2} #{has_only_stop_words}" )
    plural_kw.stemmed_words_count.should == {[keyword1] => 2, [keyword2] => 2,
      [keyword1,keyword1] => 1,[keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword1,keyword2] => 1, [keyword1,keyword2,keyword2] => 1}
    plural_kw.num_stemmed_words.should == 4
    plural_kw.search_word_counts[keyword1_plural].should == 2
    plural_kw.search_word_counts[keyword2_plural].should == 2
  end

  specify "keyword and raw density count for multi-word keywords" do
    multi_kw = KeywordDensity.new has_multi_keyword
    multi_kw.get_keyword_density("#{multi_word_keyword} #{keyword2} #{has_only_stop_words}" )
    multi_kw.stemmed_words_count.should == {[keyword1] => 1, [keyword2] => 2,
      [keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword2,keyword2] => 1}
    multi_kw.num_stemmed_words.should == 3
    multi_kw.search_word_counts[multi_word_keyword].should == 1
    multi_kw.search_word_counts[keyword2].should == nil
    multi_kw.get_keyword_density("#{multi_word_keyword} #{multi_word_keyword} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    multi_kw.stemmed_words_count.should == {[keyword1] => 2, [keyword2] => 4,
      [keyword1,keyword2] => 2,[keyword2,keyword1] => 1,[keyword2,keyword2] => 2,
      [keyword1,keyword2,keyword1] => 1,
      [keyword2,keyword1,keyword2] => 1,
      [keyword2,keyword2,keyword2] => 1,
      [keyword1,keyword2,keyword2] => 1
      }
    multi_kw.num_stemmed_words.should == 6
    multi_kw.search_word_counts[multi_word_keyword].should == 2
    multi_kw.search_word_counts[keyword2].should == nil
  end
  
  specify "Change the search words dynamically" do
    multi_kw = KeywordDensity.new has_multi_keyword
    multi_kw.get_keyword_density("#{multi_word_keyword} #{multi_word_keyword} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    multi_kw.num_stemmed_words.should == 6
    multi_kw.search_word_counts[multi_word_keyword].should == 2
    multi_kw.search_word_counts[keyword2].should == nil
    multi_kw.current_search_words = ([keyword2])
    multi_kw.search_word_counts[keyword2].should == 4
  end

  specify "singularize keyword combo maps to same stem" do
    singularize_kw = KeywordDensity.new has_singularize_keyword
    singularize_kw.get_keyword_density("#{keyword1} #{keyword1_plural}")
    singularize_kw.stemmed_words_count.should == {[keyword1] => 2,[keyword1,keyword1] => 1}
    singularize_kw.num_stemmed_words.should == 2
   end

end

describe KeywordDensity, "Processing ordinary words" do
  include DensityTestHelper
  specify "raw density count for one word" do
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_only_stop_words}" )
    empty_keyword.words_count.should == {[three_letter_word] => 1}
    empty_keyword.num_words.should == 1
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_1_3_letter_word} #{has_only_stop_words}" )
    empty_keyword.words_count.should == {[three_letter_word] => 2,[three_letter_word,three_letter_word] => 1}
    empty_keyword.num_words.should == 2
  end
  
  specify "raw density count for two words" do
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_only_stop_words} #{three_letter_word2}" )
    empty_keyword.words_count.should == {[three_letter_word2] => 1, [three_letter_word] => 1,[three_letter_word, three_letter_word2] => 1}
    empty_keyword.num_words.should == 2
    empty_keyword.search_word_counts.should == {}
    empty_keyword.get_keyword_density("#{has_1_3_letter_word} #{has_1_3_letter_word} #{has_only_stop_words} #{three_letter_word2}" )
    empty_keyword.words_count.should == {[three_letter_word] => 2, [three_letter_word2] => 1,[three_letter_word,three_letter_word] => 1, 
      [three_letter_word,three_letter_word2] => 1,[three_letter_word,three_letter_word,three_letter_word2] => 1}
    empty_keyword.num_words.should == 3
  end

  specify "keyword and raw density count for one word" do
    one_kw = KeywordDensity.new has_1_keyword
    one_kw.get_keyword_density("#{keyword1} #{has_only_stop_words}" )
    one_kw.words_count.should == {[keyword1] => 1}
    one_kw.num_words.should == 1
    one_kw.search_word_counts[keyword1].should == 1
    one_kw.get_keyword_density("#{keyword1} #{keyword1} #{has_only_stop_words}" )
    one_kw.words_count.should == {[keyword1] => 2,[keyword1,keyword1] => 1}
    one_kw.num_words.should == 2
  end
  
  specify "keyword and raw density count for two words" do
    two_kw = KeywordDensity.new has_2_keywords
    two_kw.get_keyword_density("#{keyword1} #{keyword2} #{has_only_stop_words}" )
    two_kw.words_count.should == {[keyword1] => 1, [keyword2] => 1,[keyword1,keyword2] => 1}
    two_kw.num_words.should == 2
    two_kw.search_word_counts[keyword1].should == 1
    two_kw.search_word_counts[keyword2].should == 1
    two_kw.get_keyword_density("#{keyword1} #{keyword1} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    two_kw.words_count.should == {[keyword1] => 2, [keyword2] => 2,
      [keyword1,keyword1] => 1,[keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword1,keyword2] => 1, [keyword1,keyword2,keyword2] => 1}
    two_kw.num_words.should == 4
    two_kw.search_word_counts[keyword1].should == 2
    two_kw.search_word_counts[keyword2].should == 2
  end

  specify "keyword and raw density count for 2 plural words" do
    plural_kw = KeywordDensity.new has_two_plural_keywords
    plural_kw.get_keyword_density("#{keyword1} #{keyword2_plural} #{has_only_stop_words}" )
    plural_kw.words_count.should == {[keyword1] => 1, [keyword2] => 1,[keyword1,keyword2] => 1}
    plural_kw.num_words.should == 2
    plural_kw.search_word_counts[keyword1_plural].should == 1
    plural_kw.search_word_counts[keyword2_plural].should == 1
    plural_kw.get_keyword_density("#{keyword1} #{keyword1_plural} #{keyword2_plural} #{keyword2} #{has_only_stop_words}" )
    plural_kw.words_count.should == {[keyword1] => 2, [keyword2] => 2,
      [keyword1,keyword1] => 1,[keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword1,keyword2] => 1, [keyword1,keyword2,keyword2] => 1}
    plural_kw.num_words.should == 4
    plural_kw.search_word_counts[keyword1_plural].should == 2
    plural_kw.search_word_counts[keyword2_plural].should == 2
  end

  specify "keyword and raw density count for multi-word keywords" do
    multi_kw = KeywordDensity.new has_multi_keyword
    multi_kw.get_keyword_density("#{multi_word_keyword} #{keyword2} #{has_only_stop_words}" )
    multi_kw.words_count.should == {[keyword1] => 1, [keyword2] => 2,
      [keyword1,keyword2] => 1,[keyword2,keyword2] => 1,
      [keyword1,keyword2,keyword2] => 1}
    multi_kw.num_words.should == 3
    multi_kw.search_word_counts[multi_word_keyword].should == 1
    multi_kw.search_word_counts[keyword2].should == nil
    multi_kw.get_keyword_density("#{multi_word_keyword} #{multi_word_keyword} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    multi_kw.words_count.should == {[keyword1] => 2, [keyword2] => 4,
      [keyword1,keyword2] => 2,[keyword2,keyword1] => 1,[keyword2,keyword2] => 2,
      [keyword1,keyword2,keyword1] => 1,
      [keyword2,keyword1,keyword2] => 1,
      [keyword2,keyword2,keyword2] => 1,
      [keyword1,keyword2,keyword2] => 1
      }
    multi_kw.num_words.should == 6
    multi_kw.search_word_counts[multi_word_keyword].should == 2
    multi_kw.search_word_counts[keyword2].should == nil
  end
  
  specify "Change the search words dynamically" do
    multi_kw = KeywordDensity.new has_multi_keyword
    multi_kw.get_keyword_density("#{multi_word_keyword} #{multi_word_keyword} #{keyword2} #{keyword2} #{has_only_stop_words}" )
    multi_kw.num_words.should == 6
    multi_kw.search_word_counts[multi_word_keyword].should == 2
    multi_kw.search_word_counts[keyword2].should == nil
    multi_kw.current_search_words = ([keyword2])
    multi_kw.search_word_counts[keyword2].should == 4
  end

  specify "singularize keyword combo maps to same stem" do
    singularize_kw = KeywordDensity.new has_singularize_keyword
    singularize_kw.get_keyword_density("#{keyword1} #{keyword1_plural}")
    singularize_kw.words_count.should == {[keyword1] => 2,[keyword1,keyword1] => 1}
    singularize_kw.num_words.should == 2
   end

end
