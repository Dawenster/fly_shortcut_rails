class DonationsController < ApplicationController
  def donate
    respond_to do |format|
      # Get the credit card details submitted by the form
      token = params[:stripeToken][:id]
      amount = params[:amount]
      email = params[:stripeToken][:email]

      # Create the charge on Stripe's servers - this will charge the user's card
      begin
        customer = Stripe::Customer.create(
          :card => token,
          :email => email
        )

        charge = Stripe::Charge.create(
          :customer    => customer.id,
          :amount      => amount,
          :description => email,
          :currency    => 'usd'
        )
        message = "Successful payment!"
        success = true
      rescue Stripe::CardError => e
        flash[:error] = e.message
        message = "ERROR: #{e.message}"
        success = false
      end
      format.json { render :json => { :success => success, :message => message } }
    end
  end
end