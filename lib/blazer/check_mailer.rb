module Blazer
  class CheckMailer < ActionMailer::Base
    include ActionView::Helpers::TextHelper

    require "csv"

    default from: Blazer.from_email if Blazer.from_email
    layout false

    def state_change(check, state, state_was, rows_count, error, columns, rows, column_types, check_type)
      @check = check
      @state = state
      @state_was = state_was
      @rows_count = rows_count
      @error = error
      @columns = columns
      @rows = rows
      @column_types = column_types
      @check_type = check_type

      timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
      filename = "report-#{timestamp}.csv"
      attachments[filename] = {
        mime_type: "text/csv",
        content: CSV.generate do |csv|
          csv << columns
          rows.each { |row| csv << row }
        end
      }

      mail to: check.emails, reply_to: check.emails, subject: "Check #{state.titleize}: #{check.query.name}"
    end

    def failing_checks(email, checks)
      @checks = checks
      # add reply_to for mailing lists
      mail to: email, reply_to: email, subject: "#{pluralize(checks.size, "Check")} Failing"
    end
  end
end
