module HttpCanvasHelper

  class HttpCanvasAuthorizedRequest
    def initialize(options, end_point)
      @end_point = end_point
      @bearer_token = "Bearer #{options.token}"
      @url = options.canvas_url
    end

    def send_request
      url = URI.parse("#{@url}#{@end_point}")
      req = Net::HTTP::Get.new(url.to_s)
      req.add_field 'Authorization', @bearer_token
      res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
        http.request(req)
      }
      JSON.parse(res.body, object_class: OpenStruct)
    end

    def send_request_with_link_headers
      url = URI.parse("#{@url}#{@end_point}")
      req = Net::HTTP::Get.new(url.to_s)
      req.add_field 'Authorization', @bearer_token
      res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
        http.request(req)
      }

      links = Hash.new()

      if res['Link']
        link_list = res['Link'].split(',')

        def start_link(link)
          link.index('<') + 1
        end

        def end_link(link)
          link.index('>') - 1
        end

        link_previous = link_list.find { |e| e.include? "previous" }
        if link_previous
          links['previous'] = link_previous.slice(start_link(link_previous) , end_link(link_previous))
        end

        link_next = link_list.find { |e| e.include? "next" }
        if link_next
          links['next'] = link_next.slice(start_link(link_next) , end_link(link_next))
        end

        link_current = link_list.find { |e| e.include? "current" }
        if link_current
          links['current'] = link_current.slice(start_link(link_current) , end_link(link_current))
        end
      end

      [
        JSON.parse(res.body, object_class: OpenStruct),
        links
      ]
    end
  end

end
