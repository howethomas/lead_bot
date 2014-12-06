#!/usr/bin/env ruby
require File.expand_path('../../lib/script_conversation', __FILE__)

def take_note(instructions)
  additional_notes = String.new
  ask :note, instructions, :as => :text
  additional_notes << note
  note.strip!
  while note != "."
    ask :note, "Still note taking. Send a message with a single period when you are done.", :as => :text
    additional_notes << note
    note.strip!
  end
  hide :note
  additional_notes
end


conversation do
  record :src, @src
  record :dest, @dest
  record :contact_time, Time.now

  WELCOME_MSG = @settings['WELCOME_MSG'] || ""
  AWAY_MSG = @settings['AWAY_MSG'] || ""
  NOT_AT_DESK_MSG = @settings['NOT_AT_DESK'] || ""
  SIGNATURE_MSG = @settings['SIGNATURE'] || ""
  FINDME_MSG = @settings['FINDME_MESSAGE'] || ""

  AWAY = @settings['AWAY'] == "true"
  COLLECT_NAME = @settings['COLLECT_NAME'] != "false"
  COLLECT_ALTERNATE_CONTACT = @settings['COLLECT_ALTERNATE_CONTACT'] != "false"
  COLLECT_REASON = @settings['COLLECT_REASON'] != "false"

  if AWAY
    say AWAY_MSG
    ask :wants_to_take_note, "Would you like to leave a message?(y/n)", :as => :boolean
    if wants_to_take_note then
      record :note, take_note("Please leave your message. Use a single period to end note taking.")
    end
    say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
  else
    say WELCOME_MSG

    ask :name, "May we please have your name?", :as => :text if COLLECT_NAME

    if COLLECT_ALTERNATE_CONTACT
      ask :alt_contact_better, "Is there a better number to reach you at?(y/n)", :as => :boolean
      if alt_contact_better then
        ask :alt_contact, "What number would be better to contact you on?", :as => :text
      end
    end

    if COLLECT_REASON
      record :reason_for_contact, take_note("How can we help you? Use a single period to end note taking.")
    end

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
      else
        ask :wants_to_take_note, "Would you like to leave a message?(y/n)", :as => :boolean
        if wants_to_take_note then
          record :note, take_note("Please leave your message. Use a single period to end note taking.")
        end
      end
    end
    say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
  end
end

