# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_dates

      def available
        hotel_id = params[:hotel_id]
        @available_rooms = Room.available(hotel_id, @check_in, @check_out)

        render json: @available_rooms
      end

      private

      def require_dates
        begin
          @check_in = params[:check_in]&.to_date
          @check_out = params[:check_out]&.to_date
        rescue ArgumentError
          render json: { error: 'Invalid date format' }, status: :unprocessable_entity and return
        end

        if @check_in.blank? || @check_out.blank?
          render json: { error: 'Check-in and check-out dates are required' }, status: :bad_request
        end
      end
    end
  end
end
