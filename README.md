# JIRA Toggl Importer

### Use Toggl? Use JIRA? Tired of copying all of your Toggl time entries into JIRA work logs? This app is for you!

### This is a work in progress. There is currently no UI for this (nor tests - woo!), but it is working in the console.

#### To Use:

##### Set your environment variables
This importer requires certain environment variables to be set. You can set them using any method of your choice.
One simple method is to put the following (with appropriate values) into config/initializers/00_private_envars.rb:

    ENV['TOGGL_TOKEN'] = "your_toggl_token"
    ENV['TOGGL_WORKSPACE_ID'] = "your_toggl_workspace_id"
    ENV['TOGGL_USER_AGENT'] = "your_toggl_user_agent"
    ENV['JIRA_USERNAME'] = "your_jira_username"
    ENV['JIRA_PASSWORD'] = "your_jira_password"
    ENV['DEFAULT_LOG_TAG'] = "Logged"

Here are some notes about how to find the appropriate values for those environment variables:
- `TOGGL_TOKEN`: In your Toggl account, go to your profile page and look for the API token at the bottom.
- `TOGGL_WORKSPACE_ID`: This is a little trickier. Your workspaces usually only show a human-readable name to you in Toggl's UI, and here you need the workspace's machine ID.
  But you can do a curl request to find it like this (replacing `TOGGL_TOKEN` with your token from above):

        curl -v -u TOGGL_TOKEN:api_token \ -X GET https://www.toggl.com/api/v8/workspaces

  Look at the result and find the id given for the workspace you want to use.
- `TOGGL_USER_AGENT`: This is your Toggl username, usually your email.
- `JIRA_USERNAME`: This is your Jira username, which is _not_ an email, but usually your email minus the "@domain.com"

##### Example commands to run in `rails c`:

    since = 9.days.ago.to_time.beginning_of_day
    # How far back you want to log

    time_entries = Toggl::Report.new.fetch(since: since)['data']
    # Get time entries from Toggl

    logger = JIRA::WorkLogger.new(time_entries: time_entries).log_all
    # Log!

##### This app makes some assumptions about your Toggl data:
* JIRA issue keys should be contained within each Toggl time entry, and should be wrapped in brackets. Example: "Worked on Thing 12 [THING-12]"
* If you would like to add a comment to the worklog, just wrap it in curly braces. Example: "Team Meetings: {Quarterly Review} [TEAM-2]"
* Any time entries within the date period specified will be logged, unless they have a tag of "logged."


##### Logging / Debugging
There is some basic logging to console for now to show which ones succeeded and which failed. Eventually, worklog requests that succeed will then be updated with the "logged" tag on Toggl, and worklog requests that fail will give some more helpful info as to why.


License
-------

This program is provided under an MIT open source license, read the [MIT-LICENSE.txt](http://github.com/supremebeing7/jira_toggl_importer/blob/master/LICENSE.txt) file for details.


Copyright
---------

Copyright (c) 2016 Mark J. Lehman
