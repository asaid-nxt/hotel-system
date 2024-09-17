class DateParser
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
