module RSpec
  module Apib
    class Configuration < Struct.new(
      :dest_file, :pre_docs, :post_docs, :request_header_blacklist,
      :request_param_blacklist, :record_types, :inclusion_policy
    )
      def initialize
        self.pre_docs   = []
        self.post_docs  = []
        self.request_header_blacklist = %w(host accept cookie)
        self.request_param_blacklist  = %i(controller action)
        self.record_types = %i(request)
        self.inclusion_policy = :optin
      end

      def dest_file
        super || File.join(Rails.root.to_s, 'apiary.apib')
      end

      def pre_docs=(value)
        super([value].flatten)
      end

      def post_docs=(value)
        super([value].flatten)
      end

      def record_types=(value)
        super([value].flatten)
      end

      def inclusion_policy=(value)
        super(value)
      end
    end
  end
end
