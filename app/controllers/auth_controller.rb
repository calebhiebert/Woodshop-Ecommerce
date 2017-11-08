class AuthController < ApplicationController
  before_action :province, only: [:register]
  before_action :location, only: [:register]

  def register
    input = params.permit(:first_name, :last_name, :email, :password,
                          :password_confirmation, :address, :postal_code)

    if @province.nil?
      render json: { error: 'Invalid province code' }, status: :not_found
      return
    end

    if @location.nil?
      render json: { error: 'Location required' }
      return
    end

    if input[:password].empty?
      render json: { error: 'Password is required' },
             status: :unprocessable_entity
      return
    end

    if input[:password] != input[:password_confirmation]
      render json: { error: 'Passwords do not match' },
             status: :unprocessable_entity
      return
    end

    password_hash = BCrypt::Password.create(input[:password])

    user = User.new(first_name: input[:first_name],
                    last_name: input[:last_name],
                    email: input[:email],
                    password_digest: password_hash,
                    is_admin: false)

    if user.save
      render json: user
    else
      render json: user.errors
    end

    # location = Location.new(address: input[:address],
    #                         postal_code: input[:postal_code],
    #                         province: province)

    # render json: user
  end

  private

  def province
    prov = params.permit(:province_code)
    @province = Province.where(province_code: prov[:province_code]).first
  end

  def location
    if !@province.nil?
      loc = params.permit(:address, :postal_code)
      @location = Location.new(address: loc[:address], postal_code: loc[:postal_code], province: @province)
    else
      @location = nil
    end
  end
end