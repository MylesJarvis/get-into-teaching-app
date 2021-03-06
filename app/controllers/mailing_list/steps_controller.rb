module MailingList
  class StepsController < ApplicationController
    include WizardSteps
    self.wizard_class = MailingList::Wizard

    before_action :set_step_page_title, only: [:show]
    before_action :set_completed_page_title, only: [:completed]

  private

    def step_path(step = params[:id], urlparams = {})
      mailing_list_step_path step, urlparams
    end
    helper_method :step_path

    def wizard_store
      ::Wizard::Store.new session_store
    end

    def session_store
      session[:mailinglist] ||= {}
    end

    def set_step_page_title
      @page_title = "Sign up for email updates"
      unless @current_step.nil?
        @page_title += ", #{@current_step.title.downcase} step"
      end
    end

    def set_completed_page_title
      @page_title = "You've signed up"
    end
  end
end
