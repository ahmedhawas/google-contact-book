require 'google/api_client'
require 'google/google_contacts_fetcher'
require "active_support/core_ext/hash/slice"

class GoogleService
  def initialize(account)
    @access_token = account.access_token

    @client = ::Google::APIClient.new({ application_name: "Contact Book"})    
    @client.authorization.access_token = @access_token
  end

  def get_all_contacts()
    # Get google contacts using custom library
    contacts = Google::Contacts.new(@client).contacts
    truncated_google_contacts = contacts.map {|e| e.slice(*[:emails,:phone_numbers, :full_name]) }[0..20]
  end
end