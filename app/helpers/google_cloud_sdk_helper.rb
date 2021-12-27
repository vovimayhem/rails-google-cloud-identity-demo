# frozen_string_literal: true

#= GoogleCloudSdkHelper
#
# Retrieves the correct project id from several possible environment variables
module GoogleCloudSdkHelper
  def self.project_id
    # Giving env vars priority over the JSON keyfile, as the project in the
    # keyfile might not match the project (i.e. service account comes from a
    # different project)
    ENV['GOOGLE_CLOUD_PROJECT'] ||
      ENV['GOOGLE_PROJECT_ID'] ||
      ENV['GCP_PROJECT'] ||
      ENV['GCLOUD_PROJECT'] ||
      project_id_from_app_credentials
  end

  # rubocop:disable Lint/SuppressedException
  def self.project_id_from_app_credentials
    return unless defined?(Google::Auth)

    Google::Auth.get_application_default&.project_id
  rescue RuntimeError
  end
  # rubocop:enable Lint/SuppressedException

  def google_cloud_meta_tags
    [
      google_cloud_project_meta_tag,
      google_cloud_firebase_api_key_meta_tag
    ].join("\n    ").html_safe
  end

  def google_cloud_project_meta_tag
    return unless (project = GoogleCloudSdkHelper.project_id).present?

    tag.meta name: 'google-cloud-project',
             content: project,
             escape_attributes: false
  end

  def google_cloud_firebase_api_key_meta_tag
    return unless (api_key = ENV['GOOGLE_CLOUD_FIREBASE_API_KEY']).present?

    tag.meta name: 'google-cloud-firebase-api-key',
             content: api_key,
             escape_attributes: false
  end
end
