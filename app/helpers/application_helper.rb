module ApplicationHelper
  def frontend_asset_tags
    safe_join(
      [
        stylesheet_link_tag("application", "data-turbo-track": "reload"),
        javascript_include_tag("application", type: "module", "data-turbo-track": "reload")
      ],
    )
  end
end
