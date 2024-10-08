# frozen_string_literal: true

require 'logger'
require_relative 'api_client'
require_relative 'parse_journeys'

class TrainlineService
  attr_reader :from, :to, :departure_at, :logger

  def initialize(from, to, departure_at)
    @from = from
    @to = to
    @departure_at = departure_at
    @logger = Logger.new(STDOUT)
  end

  def call
    search_journey
  rescue ApiClient::APIError => e
    logger.error "#{e.message}"
    logger.debug "#{e.backtrace.join("\n")}"
    nil
  end

  private

  def search_journey
    response = ApiClient.journeys('/api/journey-search/', body)
    ParseJourneys.new(response).parse
  end

  def body
    {
      passengers: [],
      transitDefinitions:
      [
        {
          direction: "outward",
          origin: find_location_code(from),
          destination: find_location_code(to),
          journeyDate: {
            type: "departAfter",
            time: departure_at
          }
        }
      ],
      type: 'single',
      transportModes: [
        'mixed'
      ],
    }
  end

  def find_location_code(location)
    response = ApiClient.locations('/api/locations-search/v2/search', { searchTerm: location, locale: 'en-US' })
    response['searchLocations'].first['code']
  end
end
