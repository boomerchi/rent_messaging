class ConversationValidator < ActiveModel::Validator
  attr_reader :conversation

  def validate(record)
    @conversation = record

    unless exactly_two_accounts?
      record.errors[:base] << "The conversation can only be set up between two different accounts, has: #{total_count}"
    end
    clear!
  end

  protected

  def clear!
    @conversation = nil
    @total_count = nil
  end    

  def count account
    conversation.send(account) ? 1 : 0
  end

  def total *accounts
    accounts.flatten.inject(0) {|res, account| res += count(account) }
  end

  def total_count
    @total_count ||= total(:system, :tenant, :landlord)
  end

  def exactly_two_accounts?
    total_count == 2
  end
end