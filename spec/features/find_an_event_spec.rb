require "rails_helper"

RSpec.feature "Finding an event", type: :feature do
  include_context "stub types api"

  let(:events) do
    11.times.collect do |index|
      start_at = Time.zone.today.at_beginning_of_month + index.days
      build(:event_api, name: "Event #{index + 1}", start_at: start_at)
    end
  end
  let(:events_by_type) { events.group_by { |event| event.type_id.to_s.to_sym } }
  let(:event) { events.last }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
      receive(:upcoming_teaching_events_indexed_by_type) { events_by_type }
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
      receive(:search_teaching_events_indexed_by_type) { events_by_type }
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
      receive(:get_teaching_event) { event }
  end

  scenario "Finding an event by the list of featured events" do
    visit events_path

    expect(page).to have_text "Search for events"
    expect(page).to have_css "h3", text: "Train to Teach Events"

    click_on(event.name)

    expect(page).to have_css "h1", text: event.name
    click_on "Sign up for this event", match: :first
  end

  scenario "Finding an event by type" do
    visit events_path

    expect(page).to have_text "Search for events"

    select "Train to Teach Event"
    click_on "Update results"

    expect(page).not_to have_css "h2", text: "Organized by Get into Teaching"

    click_on(event.name)

    expect(page).to have_css "h1", text: event.name
    click_on "Sign up for this event", match: :first
  end

  let(:event_category_slug) { "train-to-teach-events" }
  scenario "Navigating events by page" do
    visit event_category_events_path(event_category_slug)

    expect(page).to have_css("h2", text: "Search for Train to Teach Events")

    expect(page).to have_link("2", href: event_category_events_path(event_category_slug, page: 2))
    expect(page).to have_link("Next ›", href: event_category_events_path(event_category_slug, page: 2))

    # there are 11 events and 9 per page
    expect(page).to have_css(".event-box", count: 9)

    click_on("2")
    expect(page).to have_css(".event-box", count: 2)
    expect(page).to have_link("‹ Prev", href: event_category_events_path(event_category_slug))
  end
end
