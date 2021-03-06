module Events
  class SearchComponent < ViewComponent::Base
    BLANK_MONTH_TEXT = "All months".freeze

    attr_accessor :search, :path, :include_type, :heading, :allow_blank_month

    def initialize(search, path, include_type: true, heading: "Search for events", allow_blank_month: false)
      @search            = search
      @path              = path
      @include_type      = include_type
      @heading           = heading
      @allow_blank_month = allow_blank_month
    end

    def input_field_classes(field)
      error_class = "search-for-events__content__error"

      %w[search-for-events__content__input].tap do |classes|
        classes << error_class if search.errors[field].any?
      end
    end

    def month_args
      if allow_blank_month
        { include_blank: BLANK_MONTH_TEXT }
      else
        {}
      end
    end

    def error_messages
      search.errors.messages.values.flatten
    end
  end
end
