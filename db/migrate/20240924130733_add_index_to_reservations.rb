class AddIndexToReservations < ActiveRecord::Migration[7.1]
  def change
    add_index :reservations, %i[check_in check_out]
  end
end
