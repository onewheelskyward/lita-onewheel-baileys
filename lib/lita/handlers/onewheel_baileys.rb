require 'rest-client'

module Lita
  module Handlers
    class OnewheelBaileys < Handler
      route /^taps$/i,
            :taps_list,
            help: {'taps' => 'Dusplay the current taps at baileys.'}

      route /^taps (\d+)$/i,
            :taps_deets,
            help: {'taps' => 'Dusplay the current taps at baileys.'}

      def taps_list(response)
        api = get_baileys
        reply = ''
        api['data'].each do |datum|
          reply += "#{datum.first} #{datum[1]['beer'].strip}, " #{datum[1]['style'].strip},"
        end
        reply = reply.sub /, $/, ''
        response.reply reply
      end

      def taps_deets(response)
        api = get_baileys
      end

      def get_baileys
        JSON.parse RestClient.get('http://visualizeapi.com/api/baileys')
      end

      Lita.register_handler(self)
    end
  end
end
