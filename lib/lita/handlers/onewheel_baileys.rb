require 'rest-client'

module Lita
  module Handlers
    class OnewheelBaileys < Handler
      route /^taps$/i,
            :taps_list,
            command: true,
            help: {'taps' => 'Display the current taps at baileys.'}

      route /^taps (\d+)$/i,
            :taps_deets,
            command: true,
            help: {'taps 4' => 'Display the tap 4 deets, including prices.'}

      def taps_list(response)
        api = get_baileys
        reply = ''
        api['data'].each do |datum|
          # tap num #{datum.first}
          unless datum[1]['brewery'].nil?
            reply += datum[1]['brewery'].strip + ' '
          end
          reply += datum[1]['beer'] + ', '
        end
        reply = reply.strip.sub /,\s*$/, ''

        response.reply reply
      end

      def taps_deets(response)
        api = get_baileys
        api['data'].each do |datum|
          if datum[0] == response.matches[0][0]
            response.reply "#{datum[1]['brewery'].strip} #{datum[1]['beer']} #{datum[1]['style'].strip}, #{datum[1]['fill'] * 100}% full.  Served in a #{datum[1]['glass']} glass.  #{datum[1]['prices'][0]}/#{datum[1]['prices'][1]}"
          end
        end
      end

      def get_baileys
        JSON.parse RestClient.get('http://visualizeapi.com/api/baileys')
      end

      Lita.register_handler(self)
    end
  end
end
