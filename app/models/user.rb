class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :contacts
  # after_create :create_google_account

  def account_service
    # to create a google service client for google api
    GoogleService.new(self)
  end

  def find_google_contacts
    fresh_token
    google_service = account_service 
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          password: Devise.friendly_token[0,20],
          access_token: access_token.credentials.token,
          refresh_token: access_token.credentials.refresh_token,
          expires_at: Time.at(access_token.credentials.expires_at).to_datetime
        )
        # byebug
        # The user is a google contact, fetch their contacts
        google_service = user.account_service
        google_contacts = google_service.get_all_contacts()
        google_contacts.each do |google_contact|
          if google_contact[:emails][:other]
            email = google_contact[:emails][:other][:address] || ""
          else
            email = ""
          end
          number = google_contact[:phone_numbers][:work] || ""
          name = google_contact[:full_name] || ""
          contact = user.contacts.build({name: name, number: number, email: email})
          contact.save
        end
      end
    end
  end

  # Access token refresh. Google needs to be refreshed every 60 minutes.
  def fresh_token
    refresh! if expired?
    access_token
  end

  private 

  def to_params
    {'refresh_token' => refresh_token,
    'client_id' => Rails.application.secrets.google_client_id,
    'client_secret' =>  Rails.application.secrets.google_client_secret,
    'grant_type' => 'refresh_token'}
  end
 
  def request_token_from_google
    url = URI("https://accounts.google.com/o/oauth2/token")
    Net::HTTP.post_form(url, self.to_params)
  end
  def refresh!
    response = request_token_from_google
    data = JSON.parse(response.body)
    self.update_attributes(
    access_token: data['access_token'],
    expires_at: Time.now + (data['expires_in'].to_i).seconds)
  end
 
  def expired?
    expires_at < Time.now
  end
end
