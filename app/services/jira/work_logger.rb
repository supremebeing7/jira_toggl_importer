module JIRA
  class WorkLogger
    include HTTParty

    attr_accessor :username, :password, :time_entries

    base_uri 'https://hranswerlink.atlassian.net/rest/api/2'

    def initialize(username:, password:, time_entries:)
      @username = username
      @password = password
      @time_entries = time_entries
    end

    def log_all
      time_entries.each do |entry|
        log(entry)
      end
    end

    private

    def log(entry)
binding.pry
      issue_key = parse_issue_key(entry)
      payload = build_payload(entry)
      # @TODO fix this - still doesn't connect properly -- getting this error:
      # {"errorMessages"=>
      # ["Unexpected character ('c' (code 115)): expected a valid value (number, String, array, object, 'true', 'false' or 'null')\n at [Source: org.apache.catalina.connector.CoyoteInputStream@11d429d; line: 1, column: 2]"]}
      # The 'c' is from 'comment' in the payload
      self.class.post("/issue/#{issue_key}/worklog", basic_auth: auth, headers: headers, body: payload)
    end

    def auth
      {
        username: username,
        password: password
      }
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def build_payload(entry)
      JIRA::PayloadBuilder.new(
        start: entry['start'],
        duration_in_seconds: entry['dur'],
        comment: comment(entry)
      ).build
    end

    # @TODO figure out how to capture both of this in one .match call with one set of regex
    def parse_issue_key(entry)
      matches = entry['description'].match(/(\[(?<issue_key>[^\]]*)\])/)
      matches['issue_key'] if matches.present?
    end

    def comment(entry)
      matches = entry['description'].match(/(\{(?<comment>[^\}]*)\})/)
      matches['comment'] if matches.present?
    end
  end
end
