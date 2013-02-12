class PropertyDialogStateValidator < ActiveModel::EachValidator
  # implement the method called during validation
  # record is a dialog - the type determines which states it allows
  def validate_each(record, attribute, value)
    @dialog = record
    unless valid_dialog_state? value
      record.errors[attribute] << "must be a valid property dialog state, one of: #{valid_dialog_states}, was: #{value}"
    end
  end

  def self.valid_personal_states
    ['interested', 'rejected', 'meeting', 'deal', 'accepted']
  end

  def self.valid_system_states
    ['info', 'warning', 'error', 'contract']
  end

  protected

  attr_reader :dialog

  def valid_dialog_state? value
    valid_dialog_states.include? value
  end

  def valid_dialog_states
    clazz.send(states)
  end

  def type
    dialog.type || :system
  end

  def states
    "valid_#{type}_states"
  end

  def clazz
    PropertyDialogStateValidator
  end
end

