# frozen_string_literal: true

module Api
  module V1
    # Handles actions related to managing hotel rooms such as creating, updating, deleting, and
    # showing available rooms.
    class RoomsController < ApplicationController
      # Ensures the user is authenticated for the available action.
      before_action :authenticate_user!, only: :available
      # Ensures the user is an authenticated admin for create, update, and destroy actions.
      # Custom method defined in ApplicationController.
      before_action :authenticate_admin!, only: %i[create update destroy]
      # Parses the check-in and check-out dates for the available action.
      # @see parse_dates
      before_action :parse_dates, only: [:available]
      # Finds and sets the room for update and destroy actions.
      # @see set_room
      before_action :set_room, only: %i[update destroy]

      # Creates a new room.
      # @note Only accessible by an authenticated admin.
      # @return [JSON] the created room record or an error message.
      # @example Successful creation
      #   POST /api/v1/hotels/:hotel_id/rooms, { room: { number: 101, capacity: 2, amenities: 'WiFi' } }
      def create
        room = Room.new(room_params.merge(hotel_id: params[:hotel_id]))
        if room.save
          render json: room, status: :created
        else
          render json: { error: room.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Updates an existing room record.
      # @note Only accessible by an authenticated admin.
      # @return [JSON] the updated room record or an error message.
      # @example Successful update
      #   PATCH /api/v1/rooms/:id, { room: { number: 102 } }
      def update
        if @room.update(room_params)
          render json: @room, status: :ok
        else
          render json: { error: @room.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Deletes an existing room record.
      # @note Only accessible by an authenticated admin.
      # @return [nil] Empty response with HTTP 204 No Content status.
      # @example Successful deletion
      #   DELETE /api/v1/rooms/:id
      def destroy
        @room.destroy
        head :no_content
      end

      # Shows available rooms for a specific hotel based on check-in and check-out dates.
      # @note Only accessible by an authenticated user.
      # @return [JSON] a list of available rooms.
      # @example Fetching available rooms
      #   GET /api/v1/hotels/:hotel_id/rooms/available?check_in=2023-09-15&check_out=2023-09-20
      def available
        hotel_id = params[:hotel_id]
        @available_rooms = Room.available(hotel_id, @check_in, @check_out)

        render json: @available_rooms, each_serializer: RoomSerializer
      end

      private

      # Finds and sets the room based on the provided ID.
      # @raise [ActiveRecord::RecordNotFound] if the room is not found.
      # @return [Room] the room instance.
      def set_room
        @room = Room.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Room not found' }, status: :not_found
      end

      # Strong parameters for the room object.
      # @return [ActionController::Parameters] the permitted room parameters.
      def room_params
        params.require(:room).permit(:hotel_id, :number, :capacity, :amenities, :image)
      end

      # Parses the check-in and check-out dates from the request parameters.
      # @return [Array<Date>, Hash] an array with check-in and check-out dates or an error message.
      # @example Parsing dates
      #   parse_dates #=> [Date.new(2023, 9, 15), Date.new(2023, 9, 20)]
      # @raise [ActionController::UnprocessableEntity] if date parsing fails.
      def parse_dates
        result = DateParser.parse_dates(params)
        return render json: result, status: :unprocessable_entity if result.is_a?(Hash) && result[:error]

        @check_in, @check_out = result
      end
    end
  end
end
