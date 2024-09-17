# frozen_string_literal: true

module Api
  module V1
    class ReservationsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_room, only: :create
      before_action :check_room_availability, only: :create

      def create
        reservation = @room.reservations.build(reservation_params.merge(user: current_user))

        if reservation.save
          render json: reservation, status: :created
        else
          render json: { error: reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def reservation_params
        params.require(:reservation).permit(:check_in, :check_out)
      end

      def find_room
        @room = Room.find_by(id: params[:room_id])
        render json: { error: 'Room not found' }, status: :not_found unless @room
      end

      def check_room_availability
        return if @room.available?(reservation_params[:check_in], reservation_params[:check_out])

        render json: { error: 'Room is not available for the selected dates' }, status: :unprocessable_entity
      end
    end
  end
end
