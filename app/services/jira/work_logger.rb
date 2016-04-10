module JIRA
  class WorkLogger
    include HTTParty

    attr_accessor :issue_key, :time_entries

    base_uri 'https://hranswerlink.atlassian.net/rest/api/2'

    def initialize(issue_key, time_entries)
      @issue_key = issue_key
      @time_entries = time_entries
    end

    def log
      time_entries.each do |entry|
        self.class.post("/issue/#{issue_key}/worklog", payload(entry))
      end
    end

    private

    def payload(entry)

      JIRA::PayloadBuilder.new(entry)
    end
  end
end
