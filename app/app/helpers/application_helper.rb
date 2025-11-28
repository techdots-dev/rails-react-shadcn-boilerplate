module ApplicationHelper
  require "json"

  def vite_asset_tags(entry = "frontend/entrypoints/application.jsx")
    if Rails.env.development?
      safe_join(
        [
          javascript_include_tag("http://localhost:5173/@vite/client", type: "module", crossorigin: "anonymous"),
          javascript_include_tag("http://localhost:5173/#{entry}", type: "module", crossorigin: "anonymous"),
        ],
      )
    else
      tags = vite_stylesheets(entry).map do |href|
        stylesheet_link_tag(href, "data-turbo-track": "reload")
      end
      if (path = vite_asset_path(entry))
        tags << javascript_include_tag(path, type: "module", "data-turbo-track": "reload")
      end

      safe_join(tags)
    end
  end

  private

  def vite_manifest
    @vite_manifest ||= begin
      manifest_path = Rails.root.join("public", "vite", "manifest.json")
      JSON.parse(manifest_path.read) if manifest_path.exist?
    end
  end

  def vite_asset_path(entry)
    return unless (manifest = vite_manifest)

    if (file = manifest.dig(entry, "file"))
      "/vite/#{file}"
    end
  end

  def vite_stylesheets(entry)
    return [] unless (manifest = vite_manifest)

    Array(manifest.dig(entry, "css")).map { |href| "/vite/#{href}" }
  end
end
