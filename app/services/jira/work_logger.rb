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
        log(entry) unless is_logged?(entry)
      end
    end

    private

    def is_logged?(entry)
      entry['tags'].include?('logged')
    end

    def log(entry)
      issue_key = parse_issue_key(entry)
      payload = build_payload(entry)
      p "Logging #{human_readable_duration(parse_duration(entry))}"
      p "starting on #{parse_start(entry)}"
      p "to #{parse_issue_key(entry)}"
      p "with comment #{parse_comment(entry)}" unless parse_comment(entry).nil?
      response = self.class.post("/issue/#{issue_key}/worklog", basic_auth: auth, headers: headers, body: payload)
      if response.success?
        p "Success"
        # @TODO update each Toggl entry with a tag "logged"
      else
        p "Failed"
        # @TODO Tell me why it failed
      end
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
        start: parse_start(entry),
        duration_in_seconds: parse_duration(entry),
        comment: parse_comment(entry)
      ).build
    end

    def parse_start(entry)
      DateTime.strptime(entry['start'], "%FT%T%:z").strftime("%FT%T.%L%z")
    end

    def parse_duration(entry)
      entry['dur']/1000 # Toggl sends times in milliseconds
    end

    def human_readable_duration(seconds)
      total_minutes = seconds/60
      hours = total_minutes/60
      remaining_minutes = total_minutes - hours * 60
      "#{hours}h #{remaining_minutes}m"
    end

    # @TODO figure out how to capture both of this in one .match call with one set of regex
    def parse_issue_key(entry)
      matches = entry['description'].match(/(\[(?<issue_key>[^\]]*)\])/)
      matches['issue_key'] if matches.present?
    end

    def parse_comment(entry)
      matches = entry['description'].match(/(\{(?<comment>[^\}]*)\})/)
      matches['comment'] if matches.present?
    end
  end
end
