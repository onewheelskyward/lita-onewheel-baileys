require 'rest-client'
require 'nokogiri'
require 'sanitize'

module Lita
  module Handlers
    class OnewheelBaileys < Handler
      route /^taps$/i,
            :taps_list,
            command: true,
            help: {'taps' => 'Display the current taps at baileys.'}

      route /^taps ([<>\w.]+)$/i,
            :taps_deets,
            command: true,
            help: {'taps 4' => 'Display the tap 4 deets, including prices.'}

      def taps_list(response)
        beers = get_baileys
        reply = "Bailey's taps: "
        beers.each do |tap, datum|
          reply += "#{tap}) "
          reply += datum[:brewery] + ' '
          reply += datum[:name] + '  '
        end
        reply = reply.strip.sub /,\s*$/, ''

        Lita.logger.info "Replying with #{reply}"
        response.reply reply
      end

      def taps_deets(response)
        beers = get_baileys
        beers.each do |tap, datum|
          query = response.matches[0][0].strip
          # Search directly by tap number OR full text match.
          Lita.logger.info "Adding tap #{tap} to the list.  #{query.match(/^\d+$/) and tap == query} or #{datum[:search].match(/#{query}/i)}"
          if (query.match(/^\d+$/) and tap == query) or (datum[:search].match(/#{query}/i))
            send_response(tap, datum, response)
          end
          if (abv_matches = query.match(/([><]\d+\.*\d*)/))
            Lita.logger.info "abv_matches #{abv_matches[0]}"
            Lita.logger.info "#{datum[:abv].to_f} >= #{abv_matches[0].to_f} == #{datum[:abv].to_f >= abv_matches[0].to_f}"
            if abv_matches[0] =~ />/ and datum[:abv].to_f >= abv_matches[0].to_f
              send_response(tap, datum, response)
            end
          end
        end
      end

      def send_response(tap, datum, response)
        reply = "Bailey's tap #{tap}) "
        reply += "#{datum[:brewery]} "
        reply += "#{datum[:beer]}"
        reply += "#{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        reply += "#{datum[:prices]}, "
        reply += "#{datum[:remaining]}"
        response.reply reply
      end

      def get_baileys
        response = RestClient.get('http://www.baileystaproom.com/draft-list/')
        response.gsub! '<div id="responsecontainer"">', ''
        parse_response response
      end

      def parse_response(response)
        gimme_what_you_got = {}
        noko = Nokogiri.HTML response
        noko.css('div#boxfielddata').each do |m|
          # gimme_what_you_got
          tap_info = {}
          # Lita.logger.info "span first: #{m.css('span').first}"
          tap = get_tap_name(m)
          remaining = m.attributes['title']
          # Lita.logger.info "brewery first: #{m.css('span a').first}"
          if m.css('span a').first
            brewery = m.css('span a').first.children.to_s.gsub(/\n/, '')
            brewery.gsub! /RBBA/, ''
            brewery.strip!
          end
          beer_name = m.css('span i').first.children.to_s
          if beer_desc_matchdata = m.to_s.gsub(/\n/, '').match(/(<br\s*\/*>)(.+%) /)
            beer_desc = beer_desc_matchdata[2].gsub(/\s+/, ' ').strip
            if (abv_matches = beer_desc.match(/\d+\.\d+%/))
              # Lita.logger.info "#{abv_matches.inspect}"
              abv = abv_matches.to_s.sub '%', ''
              Lita.logger.info "ABV: #{abv}"
            end
          end
          prices_str = m.css('div#prices').children.to_s.strip
          prices = Sanitize.clean(prices_str).gsub(/We're Sorry/, '').gsub(/Inventory Restriction/, '').gsub(/Inventory Failure/, '').gsub('Success!', '').gsub(/\s+/, ' ').strip
          full_text_search = "#{tap.sub /\d+/, ''} #{brewery} #{beer_name} #{beer_desc.gsub /\d+\.*\d*%*/, ''}"

          gimme_what_you_got[tap] = {
              remaining: remaining,
              brewery: brewery.to_s,
              name: beer_name,
              desc: beer_desc.to_s,
              abv: abv,
              prices: prices,
              search: full_text_search
          }
        end
        gimme_what_you_got
      end

      def get_tap_name(m)
        m.css('span').first.children.first.to_s.match(/[\w ]+\:/).to_s.sub /\:$/, ''
      end

      Lita.register_handler(self)
    end
  end
end
