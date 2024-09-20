# frozen_string_literal: true

module Api
  module V1
    # Handles reservation-related actions such as listing and creating reservations.
    class ReservationsController < ApplicationController
      before_action :authenticate_user!, only: %i[index create]
      before_action :authenticate_admin!, only: :all_reservations
      before_action :parse_dates, only: [:create]
      before_action :find_room, only: :create
      before_action :check_room_availability, only: :create

      def index
        reservations = current_user.reservations
        render json: {
          past: serialize(reservations.past),
          current: serialize(reservations.current),
          future: serialize(reservations.future)
        }, status: :ok
      end

      def all_reservations
        reservations = Reservation.all
        render json: reservations, each_serializer: ReservationSerializer, status: :ok
      end

      def create
        reservation = @room.reservations.build(reservation_params.merge(user: current_user))

        if reservation.save
          render json: reservation, status: :created
        else
          render json: { error: reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def serialize(resource, serializer = ReservationSerializer)
        ActiveModelSerializers::SerializableResource.new(resource, each_serializer: serializer)
      end

      def reservation_params
        params.require(:reservation).permit(:check_in, :check_out)
      end

      def parse_dates
        result = DateParser.parse_dates(params[:reservation])
        return render json: result, status: :unprocessable_entity if result.is_a?(Hash) && result[:error]

        @check_in, @check_out = result
      end

      def find_room
        @room = Room.find_by(id: params[:room_id])
        render json: { error: 'Room not found' }, status: :not_found unless @room
      end

      def check_room_availability
        return if @room.available?(@check_in, @check_out)

        render json: { error: 'Room is not available for the selected dates' }, status: :unprocessable_entity
      end
    end
  end
end
