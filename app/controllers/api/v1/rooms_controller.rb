# frozen_string_literal: true

module Api
  module V1
    # Handles actions related to managing hotel rooms such as showing available rooms.
    class RoomsController < ApplicationController
      before_action :authenticate_user!, only: :available
      before_action :authenticate_admin!, only: %i[create update destroy]
      before_action :parse_dates, only: [:available]
      before_action :set_room, only: %i[update destroy]

      def create
        room = Room.new(room_params.merge(hotel_id: params[:hotel_id]))
        if room.save
          render json: room, status: :created
        else
          render json: { error: room.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @room.update(room_params)
          render json: @room, status: :ok
        else
          render json: { error: @room.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @room.destroy
        head :no_content
      end

      def available
        hotel_id = params[:hotel_id]
        @available_rooms = Room.available(hotel_id, @check_in, @check_out)

        render json: @available_rooms, each_serializer: RoomSerializer
      end

      private

      def set_room
        @room = Room.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Room not found' }, status: :not_found
      end

      def room_params
        params.require(:room).permit(:hotel_id, :number, :capacity, :amenities, :image)
      end

      def parse_dates
        result = DateParser.parse_dates(params)
        return render json: result, status: :unprocessable_entity if result.is_a?(Hash) && result[:error]

        @check_in, @check_out = result
      end
    end
  end
end
