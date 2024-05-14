# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'ostruct'
require 'openssl'

require 'dotenv'
Dotenv.load

module ChipRails
  class Configuration
    attr_accessor :webhook_key, :api_key, :brand_id, :base_url

    def initialize
      @webhook_key = ENV['CHIP_WEBHOOOK_KEY']
      @api_key = ENV['CHIP_API_KEY']
      @brand_id = ENV['CHIP_BRAND_ID']
      @base_url = 'https://gate.chip-in.asia/api/v1/'
    end

    def validate!
      raise 'ChipRails configuration: webhook_key is missing' unless @webhook_key
      raise 'ChipRails configuration: api_key is missing' unless @api_key
      raise 'ChipRails configuration: brand_id is missing' unless @brand_id
    end
  end
end

module ChipRails
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      configuration.validate!
      config_methods
    end

    def config_methods
      Configuration.instance_methods(false).each do |attribute|
        define_singleton_method(attribute) do
          configuration.send(attribute)
        end
      end
    end

    def make_request(method, path, body: nil)
      uri = URI(configuration.base_url + path)

      case method
      when :get
        request = Net::HTTP::Get.new(uri, default_headers)
      when :post
        request = Net::HTTP::Post.new(uri, default_headers)
        request.body = body.to_json
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      handle_response(response)
    end

    def verify_signature(data, signature, public_key)
      decoded_signature = Base64.decode64(signature)
      rsa_public = OpenSSL::PKey::RSA.new(public_key)
      rsa_public.verify(OpenSSL::Digest.new('SHA256'), decoded_signature, data)
    end

    private
      def handle_response(response)
        case response
        when Net::HTTPSuccess
          begin
            JSON.parse(response.body, object_class: OpenStruct)
          rescue JSON::ParserError
            OpenStruct.new(error: 'Invalid JSON response')
          end
        else
          begin
            error_details = JSON.parse(response.body)
            OpenStruct.new(error: error_details, code: response.code)
          rescue JSON::ParserError
            OpenStruct.new(error: response.message, code: response.code)
          end
        end
      end

      def default_headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{configuration.api_key}"
        }
      end
  end

  class Billing
    def self.create(billing_details)
      ChipRails.make_request(:post, 'billing_templates/', body: billing_details)
    end

    def self.retrieve(billing_id)
      ChipRails.make_request(:get, "billing_templates/#{billing_id}/")
    end

    def self.list
      ChipRails.make_request(:get, 'billing_templates/')
    end

    def self.add_subscriber(billing_id, subscriber_details)
      ChipRails.make_request(:post, "billing_templates/#{billing_id}/add_subscriber/", body: subscriber_details)
    end

    def self.list_client(billing_id)
      ChipRails.make_request(:get, "billing_templates/#{billing_id}/clients/")
    end

    def self.retrieve_billing_template_client(billing_id, billing_template_client_id)
      ChipRails.make_request(:get, "billing_templates/#{billing_id}/clients/#{billing_template_client_id}/")
    end
  end

  class Client
    def self.list
      ChipRails.make_request(:get, 'clients/')
    end

    def self.list_find(params)
      ChipRails.make_request(:get, "clients/?q=#{params}")
    end

    def self.find_by_email(params)
      ChipRails.make_request(:get, "clients/?q=#{params}")
    end

    def self.create(client_details)
      ChipRails.make_request(:post, 'clients/', body: client_details)
    end

    def self.retrieve(client_id)
      ChipRails.make_request(:get, "clients/#{client_id}/")
    end
  end

  class Purchase
    def self.create(purchase_details)
      ChipRails.make_request(:post, 'purchases/', body: purchase_details)
    end

    def self.retrieve(purchase_id)
      ChipRails.make_request(:get, "purchases/#{purchase_id}/")
    end
  end

  class Webhook
    def self.create
      ChipRails.make_request(:post, 'webhooks/', body: webhook_details)
    end

    def self.retrieve(webhook_id)
      ChipRails.make_request(:get, "webhooks/#{webhook_id}")
    end
  end

  class PublicKey
    def self.retrieve
      ChipRails.make_request(:get, 'public_key/')
    end
  end

  class Error < StandardError; end
end
