module NinjaPlugin
  def self.included(base)
    base.class_eval do
      include Cinch::Plugin
      hook :pre, :method => :localize!
    end
    NinjaBot.known_plugins << base
  end

  def usage
    ""
  end

  def shorten_url(url)
    begin
      Googl.shorten(url).short_url
    rescue Exception
      return url
    end
  end

  def parse_url(url)
    xhtml = Nokogiri::HTML(open(url)) rescue nil
    if xhtml.nil? && url !~ /^http/
      url.insert(0, "http://")
      xhtml = Nokogiri::HTML(open(url))
    end

    content = ""
    if /https?:\/\/([a-z]*\.)?twitter.com\/(\w+)\/status(es)?\/(\d+)/ =~ url
      xhtml.xpath('//span[@class="entry-content"]').each do |tweet|
        content = tweet.content.gsub(/([\n\t])+{1,}/, " ").strip if tweet.content
      end
    elsif /https?:\/\/identi.ca\/notice\/(\d+)/ =~ url
      xhtml.xpath('//p[@class="entry-content"]').each do |tweet|
        content = tweet.content.gsub(/([\n\t])+{1,}/, " ").strip if tweet.content
      end
    else
      xhtml.xpath("//head/title").each do |title|
        content = title.content.gsub(/([\n\t])+{1,}/, " ").strip if title.content
      end
    end

    content
  end

  def localize!(m = nil)
    NinjaBot.localize!
  end
end
