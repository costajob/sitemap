require 'builder'
require 'zlib'

module Sitemap
  class Base
    XMLNS = "http://www.sitemaps.org/schemas/sitemap/0.9".freeze

    attr_reader :name

    def initialize(name: "sitemap.xml", parent: :urlset, nodes: [], out: "", indent: 2)
      @name = name
      @parent = parent
      @nodes = nodes
      @out = out
      @indent = indent
    end

    def render
      header
      body
      close
    end

    def compress(path)
      Zlib::GzipWriter.open(path) do |gz|
        gz.write(self.render)
      end
    end

    private 

    def doc
      @doc ||= Builder::XmlMarkup.new(:target => @out, :indent => @indent)
    end

    def header
      doc.instruct!
    end

    def body
      doc.__send__(@parent, :xmlns => XMLNS) do
        @nodes.to_a.map! do |node|
          node.render(doc)
        end
      end
    end

    def close
      @out.close if @out.respond_to?(:close)
      @out
    end
  end
end
