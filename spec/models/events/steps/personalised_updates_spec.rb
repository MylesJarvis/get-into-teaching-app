require "rails_helper"

describe Events::Steps::PersonalisedUpdates do
  include_context "wizard step"
  include_context "stub types api"

  it_behaves_like "a wizard step"

  context "attributes" do
    it { is_expected.to respond_to :address_postcode }
    it { is_expected.to respond_to :degree_status_id }
    it { is_expected.to respond_to :consideration_journey_stage_id }
    it { is_expected.to respond_to :preferred_teaching_subject_id }
  end

  context "validations" do
    it { is_expected.to allow_value("TE571NG").for :address_postcode }
    it { is_expected.to allow_value("TE57 1NG").for :address_postcode }
    it { is_expected.to allow_value(" TE57 1NG ").for :address_postcode }
    it { is_expected.to allow_value("").for :address_postcode }
    it { is_expected.not_to allow_value("unknown").for :address_postcode }

    it { is_expected.to allow_value(subject.degree_status_option_ids.first).for :degree_status_id }
    it { is_expected.to allow_value(subject.degree_status_option_ids.last).for :degree_status_id }
    it { is_expected.not_to allow_value(nil).for :degree_status_id }
    it { is_expected.not_to allow_value("12345").for :degree_status_id }

    it { is_expected.to allow_value(subject.journey_stage_option_ids.first).for :consideration_journey_stage_id }
    it { is_expected.to allow_value(subject.journey_stage_option_ids.last).for :consideration_journey_stage_id }
    it { is_expected.not_to allow_value(nil).for :consideration_journey_stage_id }
    it { is_expected.not_to allow_value("12345").for :consideration_journey_stage_id }

    it { is_expected.to allow_value(subject.teaching_subject_option_ids.first).for :preferred_teaching_subject_id }
    it { is_expected.to allow_value(subject.teaching_subject_option_ids.last).for :preferred_teaching_subject_id }
    it { is_expected.not_to allow_value(nil).for :preferred_teaching_subject_id }
    it { is_expected.not_to allow_value("12345").for :preferred_teaching_subject_id }
  end

  context "data cleaning" do
    it "cleans the postcode" do
      subject.address_postcode = "  TE57 1NG "
      subject.valid?
      expect(subject.address_postcode).to eq("TE57 1NG")
      subject.address_postcode = "  "
      subject.valid?
      expect(subject.address_postcode).to be_nil
    end
  end

  context "skipped?" do
    let(:mailing_list) { nil }
    let(:backingstore) { { "subscribe_to_mailing_list" => mailing_list } }

    context "with mailing_list question not answered" do
      it { is_expected.to be_skipped }
    end

    context "with mailing_list question answered as yes" do
      let(:mailing_list) { true }
      it { is_expected.not_to be_skipped }
    end

    context "with mailing_list question answered as no" do
      let(:mailing_list) { false }
      it { is_expected.to be_skipped }
    end
  end
end