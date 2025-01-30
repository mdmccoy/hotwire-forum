# frozen_string_literal: true

module TurboStreamConcern
  extend ActiveSupport::Concern

  included do
    after_create_commit { broadcast_prepend_to(self.class.to_s.downcase.pluralize) }
    after_update_commit { broadcast_replace_to(self.class.to_s.downcase.pluralize) }
    after_destroy_commit { broadcast_remove_to(self.class.to_s.downcase.pluralize) }
  end
end
