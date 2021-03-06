require 'fileutils'
require 'hpricot'
require 'forwardable'

require 'www/mechanize/page/link'
require 'www/mechanize/page/meta'
require 'www/mechanize/page/base'
require 'www/mechanize/page/frame'
require 'www/mechanize/headers'

module WWW
  class Mechanize
    # = Synopsis
    # This class encapsulates an HTML page.  If Mechanize finds a content
    # type of 'text/html', this class will be instantiated and returned.
    #
    # == Example
    #  require 'rubygems'
    #  require 'mechanize'
    #
    #  agent = WWW::Mechanize.new
    #  agent.get('http://google.com/').class  #=> WWW::Mechanize::Page
    #
    class Page < WWW::Mechanize::File
      extend Forwardable

      attr_accessor :mech

      def initialize(uri=nil, response=nil, body=nil, code=nil, mech=nil)
        super(uri, response, body, code)
        @mech           ||= mech

        raise Mechanize::ContentTypeError.new(response['content-type']) unless
            content_type() =~ /^text\/html/ 

        @parser = @links = @forms = @meta = @bases = @frames = @iframes = nil
      end

      def title
        @title ||= if parser && search('title').text.length > 0
          search('title').text
        end
      end

      def parser
        @parser ||= body && response ? Hpricot.parse(body) : nil
      end
      alias :root :parser

      # Get the content type
      def content_type
        response['content-type']
      end

      # Search through the page like HPricot
      def_delegator :parser, :search, :search
      def_delegator :parser, :/, :/
      def_delegator :parser, :at, :at

      # Find a form with +name+.  Form will be yielded if a block is given.
      def form(name)
        f = forms.name(name).first
        yield f if block_given?
        f
      end
    
      def links
        @links ||= WWW::Mechanize::List.new(
          %w{ a area }.map do |tag|
            search(tag).map do |node|
              Link.new(node, @mech, self)
            end
          end.flatten
        )
      end

      def forms
        @forms ||= WWW::Mechanize::List.new(
          search('form').map do |html_form|
            form = Form.new(html_form, @mech, self)
            form.action ||= @uri
            form
          end
        )
      end

      def meta
        @meta ||= WWW::Mechanize::List.new(
          search('meta').map do |node|
            next unless node['http-equiv'] && node['content']
            (equiv, content) = node['http-equiv'], node['content']
            if equiv && equiv.downcase == 'refresh'
              if content && content =~ /^\d+\s*;\s*url\s*=\s*'?([^\s']+)/i
                node['href'] = $1
                Meta.new(node, @mech, self)
              end
            end
          end.compact
        )
      end

      def bases
        @bases ||= WWW::Mechanize::List.new(
          search('base').map { |node| Base.new(node, @mech, self) }
        )
      end

      def frames
        @frames ||= WWW::Mechanize::List.new(
          search('frame').map { |node| Frame.new(node, @mech, self) }
        )
      end

      def iframes
        @iframes ||= WWW::Mechanize::List.new(
          search('iframe').map { |node| Frame.new(node, @mech, self) }
        )
      end
    end
  end
end
