class Message < ActiveRecord::Base

  after_save :update_conversation_read_status, :update_conversation_response_time

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation

  validates_presence_of :sender_id
  validate :content_or_action_present

  # Message must always have either content, action or both
  def content_or_action_present
    errors.add(:base, "Message needs to have either action or content.") if content.blank? && action.blank?
  end

  def update_conversation_read_status
    conversation.update_attribute(:last_message_at, created_at)
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end
  end

  def update_conversation_response_time
    conversation = self.conversation

    if !conversation.response_time
      messages = conversation.messages.order(:created_at)

      conversation_initiator = conversation.initiator
      conversation_responder = conversation.responder

      initial_message = messages.where(:sender_id => conversation_initiator).first
      if initial_response = messages.where(:sender_id => conversation_responder).first
        conversation.update_attribute(:response_time, initial_response.created_at - initial_response.created_at)
      else
        conversation.response_time = nil
      end
    end
  end

end
