class ContactsController < ApplicationController
  before_filter :get_contact, :except => [:index, :new, :create]

  def index
    @user= user
    @contacts = current_user.contacts
  end

  def new 
    @contact = Contact.new
  end
 
  def create
    @user = user
    @contact = @user.contacts.build(contact_params)
    if @contact.save
      redirect_to user_contacts_url(@user.id)
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update 
    if @contact.update_attributes(contact_params)
      redirect_to user_contacts_url(user.id), notice: 'contact was successfully updated.'
    else 
      render action: "edit"
    end
  end

  def destroy
      @contact.destroy
      redirect_to user_contacts_url(user.id) 
  end

  private

  def contact_params
    params.require(:contact).permit(:name,:number, :email)
  end

  def user
    current_user
  end

  def get_contact
    @contact = Contact.find(params[:id])
  end
end