module Talk::Api
  class Finder
    # what to achieve?

    # create new message
    # - find conversation to use (latest by default)
    #   - if no conversation, create one with a default dialog
    #   - if conversation has no dialog
    #     - find_or_initialize_by(state: state)

    def find_or_create_user_property_conversation
      user_property_conversation ? user_property_conversation : create_user_property_conversation
    end

    # def create_user_property_conversation
    #   @user_property_conversation ||= property_conversations.create_with_dialog(tenant: tenant, landlord: landlord)
    # end

    def user_property_conversations
      @user_property_conversations ||= property_conversations.between(tenant, landlord)
    rescue 
      []
    end 
  end
end