module HttpCanvasHelper
  class HttpCanvasAuthorizedRequest
    def initialize(options, end_point, query)
      @end_point = end_point
      @bearer_token = "Bearer #{options.token}"
      @url = options.canvas_url
      @query = query.to_query
    end

    def send_request
      url = URI.parse("#{@url}#{@end_point}")
      req = Net::HTTP::Get.new(url.to_s)
      req.add_field 'Authorization', @bearer_token
      res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
        http.request(req)
      }
      JSON.parse(res.body, object_class: JsonResponse)
    end

    def send_request_with_link_headers
      url = URI.parse("#{@url}#{@end_point}?#{@query}")
      req = Net::HTTP::Get.new(url.to_s)
      req.add_field 'Authorization', @bearer_token
      res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
        http.request(req)
      }

      bookmarks = parse_bookmarks(res['Link'])

      [
        JSON.parse(res.body, object_class: JsonResponse),
        bookmarks
      ]
    end

    def parse_bookmarks(bookmark)
      bookmarks = Hash.new()

      if bookmark
        bookmark_list = bookmark.split(',')

        def start_bookmark(bookmark)
          bookmark.index('<') + 1
        end

        def end_bookmark(bookmark)
          bookmark.index('>') - 1
        end

        def parse_url(url)
          uri    = URI.parse(url)
          params = CGI.parse(uri.query)
          params['page'].first
        end

        bookmark_previous = bookmark_list.find { |e| e.include? "previous" }
        if bookmark_previous
          bookmark = parse_url(bookmark_previous.slice(start_bookmark(bookmark_previous) , end_bookmark(bookmark_previous)))
          bookmarks['previous'] = bookmark
        end

        bookmark_next = bookmark_list.find { |e| e.include? "next" }
        if bookmark_next
          bookmark = parse_url(bookmark_next.slice(start_bookmark(bookmark_next) , end_bookmark(bookmark_next)))
          bookmarks['next'] = bookmark
        end

        bookmark_current = bookmark_list.find { |e| e.include? "current" }
        if bookmark_current
          bookmark = parse_url(bookmark_current.slice(start_bookmark(bookmark_current) , end_bookmark(bookmark_current)))
          bookmarks['current'] = bookmark
        end
      end

      bookmarks
    end
  end

end
