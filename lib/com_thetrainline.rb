require 'time'
require_relative 'trainline_service'

class ComTheTrainline
  def self.find(from, to, departure_at)
    TrainlineService.new(from, to, departure_at).call
  end
end
