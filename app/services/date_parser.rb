# frozen_string_literal: true

# The DateParser class provides functionality for parsing and validating date parameters.
# It includes a class method to handle the conversion of date strings into Date objects
# and ensures that both check-in and check-out dates are provided and valid.
#
# @example
#   DateParser.parse_dates(check_in: '2024-09-01', check_out: '2024-09-10')
#   # => [#<Date: 2024-09-01>, #<Date: 2024-09-10>]
#
# @example
#   DateParser.parse_dates(check_in: '2024-09-01')
#   # => { error: 'check-in and check-out dates are required' }
#
# @example
#   DateParser.parse_dates(check_in: 'invalid-date', check_out: '2024-09-10')
#   # => { error: 'Invalid date format' }
#
class DateParser
  # Parses and validates check-in and check-out dates from the provided parameters.
  #
  # @param params [Hash] a hash containing `:check_in` and `:check_out` keys with date values as strings or Date objects
  # @option params [String, Date] :check_in the check-in date
  # @option params [String, Date] :check_out the check-out date
  #
  # @return [Array<Date, Date> | Hash] an array containing parsed Date objects if both dates are valid, or
  #   a hash with an error message if dates are missing or invalid
  #
  # @raise [ArgumentError] if the provided date strings are in an invalid format
  #
  def self.parse_dates(params)
    check_in = params[:check_in]
    check_out = params[:check_out]

    return { error: 'check-in and check-out dates are required' } if check_in.nil? || check_out.nil?

    begin
      parsed_check_in = check_in.is_a?(Date) ? check_in : Date.parse(check_in)
      parsed_check_out = check_out.is_a?(Date) ? check_out : Date.parse(check_out)
    rescue ArgumentError
      return { error: 'Invalid date format' }
    end

    [parsed_check_in, parsed_check_out]
  end
end
