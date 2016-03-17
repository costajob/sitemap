module Sitemap
  PROTOCOL = "http"

  class Entity
    def siblings(entities)
      entities.select { |entity| sibling?(entity) }.unshift(self)
    end

    def ==(o)
      return false unless o.instance_of?(self.class)
      instance_variables.all? do |var|
        return false if !o.instance_variable_defined?(var)
        self.instance_variable_get(var) == o.instance_variable_get(var)
      end
    end
  end

  class Category < Entity
    attr_reader :id, :host, :site, :gender

    def initialize(options = {})
      @id = options.fetch(:id)
      @host = options.fetch(:host)
      @site = options.fetch(:site)
      @gender = options.fetch(:gender).downcase
      @name = options.fetch(:name)
    end

    def name
      (@name.gsub!(/\W/, '_') || @name).downcase! || @name
    end

    def loc
      "#{PROTOCOL}://#{@host}/#{@site}/category/#{@gender}/#{name}"
    end

    private

    def sibling?(category)
      category.id == @id && category.host == @host && category.gender == @gender && category.site != @site
    end
  end

  class Sort < Category
    def initialize(options = {})
      super
      @sort = options.fetch(:sort)
    end

    def sort
      (@sort.gsub!(/\W/, '_') || @sort).downcase! || @sort
    end

    def loc
      "#{PROTOCOL}://#{@host}/#{@site}/category/#{@gender}/#{name}/#{sort}"
    end
  end

  class Style < Entity
    attr_reader :id, :host, :site

    def initialize(options = {})
      @id = options.fetch(:id)
      @host = options.fetch(:host)
      @site = options.fetch(:site)
    end

    def loc
      "#{PROTOCOL}://#{@host}/#{@site}/style/#{@id}"
    end

    private

    def sibling?(style)
      style.id == @id && style.host == @host && style.site != @site
    end
  end

  class Store < Entity
    attr_reader :name, :host, :site

    def initialize(options = {})
      @name = options.fetch(:name)
      @host = options.fetch(:host)
      @site = options[:site]
    end

    def loc
      "#{PROTOCOL}://#{@host}/#{@site}/stores/#{@name}"
    end

    private

    def sibling?(store)
      store.name == @name && store.host == @host && store.site != @site
    end
  end

  class Home < Entity
    attr_reader :site

    def initialize(options)
      @host = options.fetch(:host)
      @site = options.fetch(:site)
    end

    def loc
      "#{PROTOCOL}://#{@host}/#{@site}/home"
    end

    def siblings(sites)
      sites.reject { |site| site == self.site }.map! do |site|
        Home::new(:host => @host, :site => site)
      end.unshift(self)
    end
  end
end
