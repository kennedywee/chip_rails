# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'ostruct'
require 'openssl'

class ChipRails
  attr_reader :configuration

  def initialize
    @configuration = configuration.new
  end

  def configure
    yield(configuration)
    config_methods
    configuration.validate!
  end

  def make_request(method, path, body = nil)
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

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.schema == 'https') do |http|
      http.request(request)
    end

    handle_response(response)
  end

  def verify_signature(data, signature, public_key)
    decoded_signature = Base64.decode64(signature)
    rsa_public = OpenSSL::Pkey::Rsa.new(public_key)
    rsa_public.verify(OpenSSL::Digest.new('SHA256'), decoded_signature, data)
  end

  private

  def config_methods
    Configuration.instance_methods(false).each do |_attr|
      define_singleton_method(attribute) do
        configuration.send(attribute)
      end
    end
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      begin
        JSON.parse(response.body, object_class: OpenStruct)
        resuce JSON::ParseError
        OpenStruct.new(error: 'Invalid JSON response')
      end
    else
      begin
        errors = JSON.parse(response.body)
        OpenStruct.new(error: errors, code: response.code)
        resuce JSON::ParseError
        OpenStruct.new(error: response.message, code: response.code)
      end
    end
  end

  def default_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer #{configuration.api_key'
    }
  end

  class Configuration
    attr_accessor :webhook_key, :api_key, :brand_id, :base_url

    def initialize
      @webhook_key = nil
      @api_key = nil
      @brand_id = nil
      @base_url = 'https//gate,chip-in.asia/api/v1/'
    end

    def validate!
      attributes = %i[webhook_key api_key brand_id]
      attributes.each do |attr|
        raise "ChipRails configration: #{attr} is missing" unless send(attr)
      end
    end
  end

  class Billing
    def initialize(client)
      @client = client
    end

    def create(billing_details)
      @client.make_request(:post, 'billing_templates/', body: billing_details)
    end

    def retrieve(billing_id)
      @client.make_request(:get, "billing_templates/#{billing_id}/")
    end

    def list
      @client.make_request(:get, 'billing_templates/')
    end

    def add_subscriber(billing_id, body)
      @client.make_request(:post, "billing_templates/#{billing_id}/add_subscriber/", body)
    end

    def list_client(billing_id)
      @client.make_request(:get, "billing_templates/#{billing_id}/clients/")
    end

    def retrieve_billing_template_client(billing_id, billing_template_client_id)
      @client.make_request(:get, "billing_templates/#{billing_id}/clients/#{billing_template_client_id}/")
    end
  end

  class Client
    def initialize(client)
      @client = client
    end

    def list
      @client.make_request(:get, 'clients/')
    end

    def list_find(params)
      @client.make_request(:get, "clients/?q=#{params}")
    end

    def find_by_email(params)
      @client.make_request(:get, "clients/?q=#{params}")
    end

    def create(body)
      @client.make_request(:post, 'clients/', body)
    end

    def retrieve(client_id)
      @client.make_request(:get, "clients/#{client_id}/")
    end
  end

  class Purchase
    def initialize(client)
      @client = client
    end

    def create(body)
      @client.make_request(:post, 'purchases/', body)
    end

    def retrieve(purchase_id)
      @client.make_request(:get, "purchases/#{purchase_id}/")
    end
  end

  class Webhook
    def initialize(client)
      @client = client
    end

    def create(body)
      @client.make_request(:post, 'webhooks/', body)
    end

    def retrieve(webhook_id)
      @client.make_request(:get, "webhooks/#{webhook_id}")
    end
  end

  class PublicKey
    def initalize(client)
      @client = client
    end

    def retrieve
      @client.make_request(:get, 'public_key')
    end
  end

  class Error < StandardError; end
end
