# frozen_string_literal: true

module Api
  module V1
    # Handles reservation-related actions such as listing and creating reservations.
    #
    # This controller has endpoints for listing a user's reservations, fetching all
    # reservations (admin only), and creating new reservations. It includes authentication
    # and room availability checks.
    class ReservationsController < ApplicationController
      before_action :authenticate_user!, only: %i[index create]
      before_action :authenticate_admin!, only: :all_reservations
      before_action :parse_dates, only: [:create]
      before_action :find_room, only: :create
      before_action :check_room_availability, only: :create

      # GET /api/v1/reservations
      #
      # Lists reservations for the current user categorized into past, current, and future reservations.
      #
      # @return [JSON] the list of the current user's reservations grouped into past, current, and future.
      def index
        reservations = current_user.reservations
        render json: {
          past: serialize(reservations.past),
          current: serialize(reservations.current),
          future: serialize(reservations.future)
        }, status: :ok
      end

      # GET /api/v1/reservations/all_reservations
      #
      # Fetches all reservations in the system. Only accessible by admins.
      #
      # @return [JSON] list of all reservations.
      def all_reservations
        reservations = Reservation.all
        render json: reservations, each_serializer: ReservationSerializer, status: :ok
      end

      # POST /api/v1/reservations
      #
      # Creates a new reservation for the current user in a specific room, after validating the
      # room's availability for the given check-in and check-out dates.
      #
      # @return [JSON] the created reservation or an error message if the reservation couldn't be created.
      def create
        reservation = @room.reservations.build(reservation_params.merge(user: current_user))

        if reservation.save
          render json: reservation, status: :created
        else
          render json: { error: reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Serializes a resource using the provided serializer.
      #
      # @param resource [ActiveRecord::Relation, Array] the resource to serialize.
      # @param serializer [ActiveModel::Serializer] the serializer class to use (defaults to ReservationSerializer).
      # @return [ActiveModelSerializers::SerializableResource] the serialized resource.
      def serialize(resource, serializer = ReservationSerializer)
        ActiveModelSerializers::SerializableResource.new(resource, each_serializer: serializer)
      end

      # Strong parameters for reservation creation.
      #
      # @return [ActionController::Parameters] the permitted reservation parameters.
      def reservation_params
        params.require(:reservation).permit(:check_in, :check_out)
      end

      # Parses check-in and check-out dates from the request parameters.
      #
      # @return [void] sets @check_in and @check_out instance variables or renders an error if the parsing fails.
      def parse_dates
        result = DateParser.parse_dates(params[:reservation])
        return render json: result, status: :unprocessable_entity if result.is_a?(Hash) && result[:error]

        @check_in, @check_out = result
      end

      # Finds the room based on the room_id parameter.
      #
      # @return [void] sets @room or renders a not found error if the room doesn't exist.
      def find_room
        @room = Room.find_by(id: params[:room_id])
        render json: { error: 'Room not found' }, status: :not_found unless @room
      end

      # Checks if the room is available for the selected dates.
      #
      # @return [void] proceeds if available or renders an error if the room is not available.
      def check_room_availability
        return if @room.available?(@check_in, @check_out)

        render json: { error: 'Room is not available for the selected dates' }, status: :unprocessable_entity
      end
    end
  end
end
