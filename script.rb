
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


record :src, @src
record :dest, @dest
record :contact_time, Time.now

GREETING_MSG = @settings['GREETING'] || ""
AWAY_MSG = @settings['AWAY_MSG'] || ""
NOT_AT_DESK_MSG = @settings['NOT_AT_DESK'] || "I'm not at my desk. Sorry."
SIGNATURE_MSG = @settings['SIGNATURE'] || ""
FINDME_MSG = @settings['FINDME_MESSAGE'] || "Please wait a moment."

AWAY_STATUS = @settings['AWAY_STATUS'] || "false"
NAME_STATUS = @settings['NAME_STATUS'] || "true"
ALT_CONTACT_STATUS = @settings['ALT_CONTACT_STATUS'] || "true"
REASON_FOR_CALL_STATUS = @settings['REASON_FOR_CALL_STATUS'] || "true"

TESTING = (@dest == "13393685161" ? true : false)

if AWAY_STATUS == "true"
  say AWAY_MSG
  ask :wants_to_take_note, "Would you like to leave a message?", :as => :boolean
  if wants_to_take_note then
    record :note, take_note("Please leave your message. Use a single period to end note taking.")
  end
  say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
else
  say GREETING_MSG

  ask :name, "May we please have your name?", :as => :text if NAME_STATUS == "true"

  if ALT_CONTACT_STATUS == "true"
    ask :alt_contact_better, "Is there a better number to reach you at?", :as => :boolean
    if alt_contact_better then
      ask :alt_contact, "What number would be better to contact you on?", :as => :text
    end
  end

  if REASON_FOR_CALL_STATUS == "true"
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
      ask :wants_to_take_note, "Would you like to leave a message?", :as => :boolean
      if wants_to_take_note then
        record :note, take_note("Please leave your message. Use a single period to end note taking.")
      end
    end
  end
  say SIGNATURE_MSG unless SIGNATURE_MSG.empty?
end

