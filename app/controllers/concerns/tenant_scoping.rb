module TenantScoping
  extend ActiveSupport::Concern

  included do
    around_action :in_scoped_transaction
    before_action :set_current_user_guc
    before_action :load_current_organization
    before_action :set_current_organization_guc
    helper_method :current_organization, :available_organizations, :current_membership, :available_projects
  end

  private
    # Wraps every action in a transaction so SET LOCAL for Postgres GUCs
    # (driving RLS) lasts exactly the lifetime of the request. The transaction
    # is opened before the before_action chain runs, so each of the SET LOCAL
    # calls below lands inside it.
    def in_scoped_transaction(&block)
      ApplicationRecord.transaction(&block)
    end

    # Run as soon as authentication has populated Current.user. Having the
    # user GUC available is a prerequisite for load_current_organization,
    # because RLS on memberships uses it to let a user see their own rows.
    def set_current_user_guc
      return unless Current.user
      ApplicationRecord.connection.execute(
        "SET LOCAL app.current_user_id = #{Current.user.id.to_i}"
      )
    end

    def load_current_organization
      return unless Current.user

      membership = current_user_membership_for(session[:current_organization_id]) ||
                   Current.user.memberships.includes(:organization).order(:created_at).first

      Current.organization = membership&.organization
      session[:current_organization_id] = Current.organization&.id
    end

    def set_current_organization_guc
      return unless Current.organization
      ApplicationRecord.connection.execute(
        "SET LOCAL app.current_organization_id = #{Current.organization.id.to_i}"
      )
    end

    def current_user_membership_for(organization_id)
      return nil if organization_id.blank?
      Current.user.memberships.includes(:organization).find_by(organization_id: organization_id)
    end

    def current_organization
      Current.organization
    end

    def current_membership
      return nil unless Current.user && Current.organization
      @current_membership ||= Current.user.memberships.find_by(organization: Current.organization)
    end

    def available_organizations
      Current.user&.organizations&.order(:name) || Organization.none
    end

    def available_projects
      return Project.none unless Current.organization
      @available_projects ||= Project.ordered.to_a
    end
end
