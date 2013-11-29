module Nugrant
  module Helper
    module Env
      ##
      # A namer is a lambda taking as argument an array of segments
      # that should return a string representation of those segments.
      # How the segments are transformed to a string is up to the
      # namer. By using various namer, we can change how a bag key
      # is transformed into and environment variable name. This is
      # like the strategy pattern.
      #
      module Namer

        ##
        # Returns the default namer, which join segments together
        # using a character and upcase the result.
        #
        # @param `char` The character used to join segments together, default to `"_"`.
        #
        # @return A lambda that will simply joins segment using the `char` argument
        #         and upcase the result.
        #
        def self.default(char = "_")
          lambda do |segments|
            segments.join(char).upcase()
          end
        end

        ##
        # Returns the prefix namer, which add a prefix to segments
        # and delegate its work to another namer.
        #
        # @param prefix The prefix to add to segments.
        # @param delegate_namer A namer that will be used to transform the prefixed segments.
        #
        # @return A lambda that will simply add prefix to segments and will call
        #         the delegate_namer with those new segments.
        #
        def self.prefix(prefix, delegate_namer)
          lambda do |segments|
            delegate_namer.call([prefix] + segments)
          end
        end
      end
    end
  end
end
