module Events
  module Steps
    class PersonalisedUpdates < ::Wizard::Step
      attribute :degree_status_id, :integer
      attribute :consideration_journey_stage_id, :integer
      attribute :address_postcode
      attribute :preferred_teaching_subject_id

      validates :degree_status_id, inclusion: { in: :degree_status_option_ids }
      validates :consideration_journey_stage_id, inclusion: { in: :journey_stage_option_ids }
      validates :address_postcode, postcode: { allow_blank: true }
      validates :preferred_teaching_subject_id, inclusion: { in: :teaching_subject_option_ids }

      before_validation if: :address_postcode do
        self.address_postcode = address_postcode.to_s.strip.presence
      end

      def skipped?
        !@store["subscribe_to_mailing_list"]
      end

      def degree_status_options
        @degree_status_options ||=
          GetIntoTeachingApiClient::TypesApi.new.get_qualification_degree_status
      end

      def degree_status_option_ids
        degree_status_options.map(&:id).map(&:to_i)
      end

      def journey_stage_options
        @journey_stage_options ||=
          GetIntoTeachingApiClient::TypesApi.new.get_candidate_journey_stages
      end

      def journey_stage_option_ids
        journey_stage_options.map(&:id).map(&:to_i)
      end

      def teaching_subject_options
        @teaching_subject_options ||=
          GetIntoTeachingApiClient::TypesApi.new.get_teaching_subjects
      end

      def teaching_subject_option_ids
        teaching_subject_options.map(&:id)
      end
    end
  end
end