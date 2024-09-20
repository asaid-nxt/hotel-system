# frozen_string_literal: true

module Api
  module V1
    # HotelsController handles the creation, updating, and deletion of hotel records.
    # This controller ensures that only authenticated admins can perform these actions.
    class HotelsController < ApplicationController
      # Callback to find and set hotel for update and destroy actions.
      # @see set_hotel
      before_action :set_hotel, only: %i[update destroy]
      # Ensures the user is an authenticated admin.
      # Defined in ApplicationController.
      before_action :authenticate_admin!

      # Creates a new hotel.
      # @note Only accessible by an authenticated admin.
      # @return [JSON] the created hotel record or an error message.
      # @example Successful creation
      #   POST /api/v1/hotels, { hotel: { name: 'Hotel XYZ', location: 'City', amenities: 'Pool', image: 'hotel.png' } }
      def create
        hotel = Hotel.new(hotel_params)
        if hotel.save
          render json: hotel, status: :created
        else
          render json: { error: hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Updates an existing hotel record.
      # @note Only accessible by an authenticated admin.
      # @return [JSON] the updated hotel record or an error message.
      # @example Successful update
      #   PATCH /api/v1/hotels/:id, { hotel: { name: 'Updated Name' } }
      def update
        if @hotel.update(hotel_params)
          render json: @hotel, status: :ok
        else
          render json: { error: @hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Deletes an existing hotel record.
      # @note Only accessible by an authenticated admin.
      # @return [nil] Empty response with HTTP 204 No Content status.
      # @example Successful deletion
      #   DELETE /api/v1/hotels/:id
      def destroy
        @hotel.destroy
        head :no_content
      end

      private

      # Finds and sets the hotel based on the provided ID.
      # @raise [ActiveRecord::RecordNotFound] if the hotel is not found.
      # @return [Hotel] the hotel instance.
      def set_hotel
        @hotel = Hotel.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Hotel not found' }, status: :not_found
      end

      # Strong parameters for the hotel object.
      # @return [ActionController::Parameters] the permitted hotel parameters.
      def hotel_params
        params.require(:hotel).permit(:name, :location, :amenities, :image)
      end
    end
  end
end
