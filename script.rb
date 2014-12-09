#!/usr/bin/env ruby
require File.expand_path('../../lib/script_conversation', __FILE__)

def take_note(instructions, termination_char)
  additional_notes = String.new
  ask :note, instructions, :as => :text
  additional_notes << note
  note.strip!
  while note != termination_char
    ask :note, "Still note taking. #{NOTE_HELP_MSG}", :as => :text
    additional_notes << note
    note.strip!
  end
  hide :note
  additional_notes
end

def ask_and_take_note(note_field, note_collection_msg, note_help_msg, note_termination_char)
  ask :wants_to_take_note, note_collection_msg, :as => :boolean
  if wants_to_take_note then
    record note_field, take_note(note_help_msg, note_termination_char)
  end
end


conversation do
  record :src, @src
  record :dest, @dest
  record :contact_time, Time.now


  WELCOME_MSG = @settings['WELCOME_MSG'] || ""
  SECOND_MSG = @settings['SECOND_MSG'] || ""
  EMAIL_TITLE = @settings['EMAIL_TITLE'] || "Your information"
  EMAIL_BODY = @settings['EMAIL_BODY'] || WELCOME_MSG + SECOND_MSG
  unless @settings['INTEREST_LIST'].nil?
    INTEREST_LIST = @settings['INTEREST_LIST'].split
  else
    INTEREST_LIST = ['sales', 'press', 'support', 'other']
  end
  INTEREST_MSG = @settings['INTEREST_PROMPT'] || "What is your interest?"
  LIVE_OFFER_MSG = @settings['LIVE_OFFER_MSG'] || ""
  SIGNATURE_MSG = @settings['SIGNATURE_MSG'] || ""
  FINDME_MSG = @settings['FINDME_MSG'] || ""
  NOTE_COLLECTION_MSG = @settings['NOTE_COLLECTION_MSG'] || "Would you like to leave a note?"
  NOTE_HELP_MSG = @settings['NOTE_HELP_MSG'] || "Send a message with a single period to end note taking."
  NOTE_TERMINATION_CHAR = @settings['NOTE_TERMINATION_CHAR'] || "."
  NOT_AT_DESK_MSG = @settings['NOT_AT_DESK_MSG'] || ""

  AWAY = @settings['AWAY'] == "true"
  OFFER_LIVE = @settings['OFFER_LIVE'] == "true"
  COLLECT_NOTE = @settings['COLLECT_NOTE'] != "false"

  say WELCOME_MSG
  say SECOND_MSG unless SECOND_MSG.empty?

  ask :wants_email, "Would it be more convenient for you to receive this in an email? (y/n)", :as => :boolean
  if wants_email then
    ask :email_address, "May we please have your email?", :as => :email
    if email_address then
      email(email_address, EMAIL_TITLE, EMAIL_BODY)
    end
  end
  ask :contact_me, "Are you interested in having someone contact you? (y/n)", :as => :boolean
  if contact_me then
    ask :name, "May we have your name?", :as => :text
    ask :interest, INTEREST_MSG, :as => :select, :collection => INTEREST_LIST
    ask_and_take_note(:note, NOTE_COLLECTION_MSG, NOTE_HELP_MSG, NOTE_TERMINATION_CHAR) if COLLECT_NOTE
  end

  if AWAY
    say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
    next
  end

  if OFFER_LIVE
    ask :wants_to_chat, LIVE_OFFER_MSG, :as => :boolean
    if wants_to_chat
      # Here is where  you might ask for name, reason and alt contact
      script_response = human!(FINDME_MSG)
      timed_out = script_response == "script_timed_out"

      if timed_out then
        say NOT_AT_DESK_MSG
        ask :text_back, "Can we text you when we come back? (y/n)", :as => :boolean
        if text_back then
          say "Thank you. We will be with you as soon as we can."
          begin
            # loop this until the script_response does not time out
            # scripts can end because they've been requested to, or they are too long hanging around.
            script_response = human!("")
          end until script_response != "script_timed_out"
        end
      end
    end
  end

  say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
end
