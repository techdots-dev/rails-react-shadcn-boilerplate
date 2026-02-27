module ApplicationHelper
  def frontend_asset_tags
    safe_join(
      [
        (stylesheet_link_tag("application", "data-turbo-track": "reload") if built_asset_exists?("application.css")),
        (javascript_include_tag("application", type: "module", "data-turbo-track": "reload") if built_asset_exists?("application.js"))
      ].compact
    )
  end

  private

  def built_asset_exists?(filename)
    Rails.root.join("app/assets/builds", filename).exist?
  end
end
