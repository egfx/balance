class StateHandler::CA < StateHandler::Base
  PHONE_NUMBER = '+18773289677'
  ALLOWED_NUMBER_OF_EBT_CARD_DIGITS = [16]

  def button_sequence(ebt_number)
    waiting_ebt_number = ebt_number.split('').join('ww')
    "wwwwwwwwwwwwwwww1wwwwwwwwwwwwww#{waiting_ebt_number}ww#wwww"
  end

  def transcribe_balance_response(transcription_text, language = :english)
    mg = MessageGenerator.new(language)
    if transcription_text == nil
      return mg.having_trouble_try_again_message
    end
    text_with_dollar_amounts = DollarAmountsProcessor.new.process(transcription_text)
    processed_transcription = process_transcription_for_zero_text(text_with_dollar_amounts)
    puts processed_transcription
    regex_matches = processed_transcription.scan(/(\$\S+)/)
    if processed_transcription.include?("non working card")
      mg.card_number_not_found_message
    elsif regex_matches.count > 0
      ebt_amount = clean_trailing_period(regex_matches[0][0])
      # for now omit other balances since now includes future
      return mg.balance_message(ebt_amount)
    else
      mg.having_trouble_try_again_message
    end
  end

  def max_message_length
    22
  end
end
