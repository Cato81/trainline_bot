# frozen_string_literal: true

class ParseJourneys
  attr_reader :journeys, :alternatives, :fares, :legs, :carriers, 
              :transportation_modes, :locations, :fare_types, :sections

  def initialize(response)
    @journeys = response.dig('data', 'journeySearch', 'journeys')
    @alternatives = response.dig('data', 'journeySearch', 'alternatives')
    @fares = response.dig('data', 'journeySearch', 'fares')
    @sections = response.dig('data', 'journeySearch', 'sections')
    @legs = response.dig('data', 'journeySearch', 'legs')
    @carriers = response.dig('data', 'carriers')
    @locations = response.dig('data', 'locations')
    @fare_types = response.dig('data', 'fareTypes')
    @transportation_modes = response.dig('data', 'transportModes')
  end

  def parse
    journeys.map { |_, journey| segment(journey) }
  end

  private

  def segment(journey)
    departure_at = DateTime.parse(journey['departAt'])
    arrival_at = DateTime.parse(journey['arriveAt'])
    
    journey_legs_ids = journey['legs']
    journey_section_ids = journey['sections']
    
    {
      departure_station: find_station_name(journey_legs_ids, 'departureLocation'),
      departure_at: departure_at,
      arrival_station: find_station_name(journey_legs_ids, 'arrivalLocation'),
      arrival_at: arrival_at,
      service_agencies: find_carriers_names(journey_legs_ids),
      duration_in_minutes: calculate_duration_in_minutes(departure_at, arrival_at),
      changeover: count_transfers(journey_legs_ids),
      products: find_transportation_modes(journey_legs_ids),
      fares: collect_fares(journey_section_ids)
    }
  end

  def fare(alternative)
    {
      name: find_fare_name(alternative),
      price_in_cents: calculate_price_in_cents(alternative),
      currency: alternative.dig('fullPrice', 'currencyCode'),
      comfort_class: set_comfort_class(alternative)
    }
  end

  def calculate_duration_in_minutes(departure_at, arrival_at)
    (arrival_at.to_time - departure_at.to_time).to_i / 60
  end

  def find_station_name(journey_legs_ids, location)
    itinerary = location.split('Location').first
    journey_departure_id = itinerary == 'departure' ? journey_legs_ids.first : journey_legs_ids.last
    location_id = legs.dig(journey_departure_id, location)
    locations.dig(location_id, 'name')
  end

  def find_carriers_names(journey_legs_ids)
    journey_carrier_ids = extract_ids_from_object(:legs, journey_legs_ids, 'carrier').uniq

    carriers.each_with_object([]) do |(carrier_id, carrier), carrier_names|
      carrier_names << carrier['name'] if journey_carrier_ids.include?(carrier_id)
    end
  end

  def find_transportation_modes(journey_legs_ids)
    journey_transport_mode_ids = extract_ids_from_object(:legs, journey_legs_ids, 'transportMode').uniq

    transportation_modes.each_with_object([]) do |(transportation_mode_id, transportation_mode), modes|
      modes << transportation_mode['mode'] if journey_transport_mode_ids.include?(transportation_mode_id)
    end
  end

  def count_transfers(journey_legs_ids)
    journey_legs_ids.count - 1
  end

  def extract_ids_from_object(object_name, object_ids, extraction_key)
    object = instance_variable_get("@#{object_name}")
    filtered_objects = object.select { |object_id, _| object_ids.include?(object_id) }
    filtered_objects.map { |_, obj| obj[extraction_key] }
  end

  def collect_fares(journey_section_ids)
    return [] if journey_section_ids.empty?

    journey_alternative_ids = extract_ids_from_object(:sections, journey_section_ids, 'alternatives').flatten
    journey_alternatives = alternatives.select { |alternative_id, _| journey_alternative_ids.include?(alternative_id) } 

    journey_alternatives.map do |_, alternative|
      fare(alternative)
    end
  end

  def find_fare_name(alternative)
    alternative_fare_id = alternative['fares'].first
    fare_type_id = fares.dig(alternative_fare_id, 'fareType')
    fare_types.dig(fare_type_id, 'name')
  end

  def calculate_price_in_cents(alternative)
    price = alternative.dig('fullPrice', 'amount')

    (price * 100).round.to_s
  end

  def set_comfort_class(alternative)
    fare_id = alternative['fares'].first
    fare_leg = fares.dig(fare_id, 'fareLegs').first
    travel_class = fare_leg.dig('travelClass', 'name')

    travel_class == 'First' ? 1 : 2
  end
end
