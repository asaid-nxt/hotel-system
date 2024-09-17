class DateParser
  def self.parse_dates(params)
    check_in = params[:check_in]
    check_out = params[:check_out]

    begin
      parsed_check_in = check_in.present? ? Date.parse(check_in) : nil
      parsed_check_out = check_out.present? ? Date.parse(check_out) : nil
    rescue ArgumentError
      return { error: 'Invalid date format' }
    end

    return { error: 'check-in and check-out dates are required' } if parsed_check_in.nil? || parsed_check_out.nil?

    [parsed_check_in, parsed_check_out]
  end
end
