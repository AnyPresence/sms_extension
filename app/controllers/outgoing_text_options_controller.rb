class OutgoingTextOptionsController < ApplicationController
  def index
    @outgoing_text_options = current_account.outgoing_text_options.all
  end
end
