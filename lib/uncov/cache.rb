# frozen_string_literal: true

# A caching helper for methods
module Uncov::Cache
  protected

  def cache(key)
    @cache ||= {}
    return @cache[key] if @cache.key?(key)

    @cache[key] = yield
  end
end
