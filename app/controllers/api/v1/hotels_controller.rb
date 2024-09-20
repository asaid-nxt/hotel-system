# frozen_string_literal: true

module Api
  module V1
    # HotelsController handles the creation, updating, and deletion of hotel records.
    class HotelsController < ApplicationController
      before_action :set_hotel, only: %i[update destroy]
      before_action :authenticate_admin!

      def create
        hotel = Hotel.new(hotel_params)
        if hotel.save
          hotel.image.attach(params[:image]) if params[:image].present?
          render json: hotel, status: :created
        else
          render json: { error: hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @hotel.update(hotel_params)
          render json: @hotel, status: :ok
        else
          render json: { error: @hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @hotel.destroy
        head :no_content
      end

      private

      def set_hotel
        @hotel = Hotel.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Hotel not found' }, status: :not_found
      end

      def hotel_params
        params.require(:hotel).permit(:name, :location, :amenities, :image)
      end
    end
  end
end
