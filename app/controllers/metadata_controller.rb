class MetadataController < ApplicationController
  layout false
  skip_before_action :preload_json, :check_xhr, :redirect_to_login_if_required

  def manifest
    render json: default_manifest.to_json
  end

  def opensearch
    render file: "#{Rails.root}/app/views/metadata/opensearch.xml"
  end

  private

  def default_manifest
    logo = SiteSetting.large_icon_url.presence || SiteSetting.logo_small_url.presence || SiteSetting.apple_touch_icon_url.presence
    file_info = get_file_info(logo)

    manifest = {
      name: SiteSetting.title,
      short_name: SiteSetting.title,
      display: 'standalone',
      orientation: 'natural',
      start_url: "#{Discourse.base_uri}/",
      share_target: {
        url_template: 'new-topic?title={title}&body={text}%0A%0A{url}'
      },
      background_color: "##{ColorScheme.hex_for_name('secondary')}",
      theme_color: "##{ColorScheme.hex_for_name('header_background')}",
      icons: [
        {
          src: logo,
          sizes: file_info[:size],
          type: file_info[:type]
        }
      ]
    }

    if SiteSetting.native_app_install_banner
      manifest = manifest.merge(
        prefer_related_applications: true,
        related_applications: [
          {
            platform: "play",
            id: "com.discourse"
          }
        ]
      )
    end

    manifest
  end

  def get_file_info(filename)
    type = MiniMime.lookup_by_filename(filename)&.content_type || "image/png"
    upload = Upload.find_by_url(filename)
    { size: "#{upload&.width || 512}x#{upload&.height || 512}", type: type }
  end

end
