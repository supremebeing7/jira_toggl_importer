== README

# Use Toggl? User JIRA? Tired of copying all of your Toggl time entries into JIRA work logs? This app is for you!

### This is a work in progress. There is currently no UI for this (nor tests - woo!), but it is working in the console.

Example commands to run in `rails c`:

since = 9.days.ago.to_time.beginning_of_day
# How far back you want to log

time_entries = Toggl::Report.new(token: your_token, workspace_id: your_workspace_id, user_agent: your_email_address_used_to_sign_in).fetch(since: since)['data']
# Get time entries from Toggl

logger = JIRA::WorkLogger.new(username: your_jira_username, password: your_jira_password, time_entries: time_entries).log_all
# Log!

Helpful notes:
* `your_jira_username` does not include "@domain.com"

This app makes some assumptions about your Toggl data:
* JIRA issue keys should be contained within each Toggl time entry, and should be wrapped in brackets. Example: "Worked on Thing 12 [THING-12]"
* If you would like to add a comment to the worklog, just wrap it in curly braces. Example: "Team Meetings: {Quarterly Review} [TEAM-2]"
* Any time entries within the date period specified will be logged, unless they have a tag of "logged."

There is some basic logging to console for now to show which ones succeeded and which failed. Eventually, worklog requests that succeed will then be updated with the "logged" tag on Toggl, and worklog requests that fail will give some more helpful info as to why.
