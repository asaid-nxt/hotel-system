# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      before_action :authenticate_user!
      before_action :parse_dates

      def available
        hotel_id = params[:hotel_id]
        @available_rooms = Room.available(hotel_id, @check_in, @check_out)

        render json: @available_rooms, each_serializer: RoomSerializer
      end

      private

      def parse_dates
        result = DateParser.parse_dates(params)
        return render json: result, status: :unprocessable_entity if result.is_a?(Hash) && result[:error]

        @check_in, @check_out = result
      end
    end
  end
end
