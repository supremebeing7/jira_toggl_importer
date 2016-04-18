module Toggl
  class Report
    include HTTParty

    attr_accessor :token, :workspace_id, :user_agent

    base_uri 'https://toggl.com/reports/api/v2'

    def initialize(token:, workspace_id:, user_agent:)
      @token = token
      @workspace_id = workspace_id
      @user_agent = user_agent
    end

    def fetch(since: Time.now.beginning_of_week(:saturday))
      self.class.get('/details', basic_auth: auth, query: query(since))
    end

    private

    def auth
      {
        username: token,
        password: "api_token"
      }
    end

    def query(since)
      {
        workspace_id: workspace_id,
        user_agent: user_agent,
        since: since
      }
    end
  end
end
