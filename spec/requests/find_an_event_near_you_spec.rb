require "rails_helper"

describe "Find an event near you" do
  include_context "stub types api"

  NO_EVENTS_REGEX = /no events that match your search criteria/.freeze

  let(:events) do
    5.times.collect do |index|
      start_at = Time.zone.today.at_beginning_of_month + index.days
      build(:event_api, name: "Event #{index + 1}", start_at: start_at)
    end
  end
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::TeachingEventsApi).to \
      receive(:search_teaching_events) { events }
  end

  subject { response }

  context "when landing on the page initially" do
    before { get events_path }

    it { is_expected.to have_http_status :success }

    it "displays the first 3 events categorised and under 'all events'" do
      expect(response.body.scan(/Event [1-3]/).count).to eq(6)
    end

    it "displays >3 events only under 'all events'" do
      expect(response.body.scan(/Event [4-5]/).count).to eq(2)
    end

    context "when there are no results" do
      let(:events) { [] }

      it "displays the no results message" do
        expect(response.body).to match(NO_EVENTS_REGEX)
      end
    end

    context "when there are events of different types" do
      let(:events) do
        GetIntoTeachingApiClient::Constants::EVENT_TYPES.values.map do |type_id|
          build(:event_api, start_at: DateTime.now, type_id: type_id)
        end
      end

      it "presents the types in the correct order" do
        headings = response.body.scan(/<h3>(.*)<\/h3>/).flatten
        expected_headings = [
          "Train to Teach Events",
          "Online Events",
          "Application Workshops",
          "School or University Events",
        ]

        expect(headings & expected_headings).to eq(expected_headings)
      end
    end
  end

  context "when searching for an event by type" do
    let(:type_id) { GetIntoTeachingApiClient::Constants::EVENT_TYPES["Train to Teach Event"] }
    before { get search_events_path(events_search: { type: type_id, month: "2020-07" }) }

    it "displays all events of that type" do
      expect(response.body.scan(/Event \d/).count).to eq(events.count)
    end

    context "when there are no results" do
      let(:events) { [] }

      it "displays the no results message" do
        expect(response.body).to match(NO_EVENTS_REGEX)
      end
    end
  end
end
