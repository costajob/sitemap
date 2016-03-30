module Sitemap
  class Repository
    def initialize(options = {})
      @sites = options.fetch(:sites) { [] }
    end

    def entities(klass)
      []
    end

    def paths
      []
    end

    def host
      "www.example.com"
    end
  end
end
