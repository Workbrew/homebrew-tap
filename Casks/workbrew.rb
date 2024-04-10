cask "workbrew" do
  version "0.1.0"
  sha256 "dbb03ee892a86278b85903c28f66dca61440e377bed9eea6e892a0c7b811a7cd"

  def workbrew_api_key
    @workbrew_api_key ||= ENV.fetch("HOMEBREW_WORKBREW_API_KEY") do
      File.read("/opt/workbrew/home/Library/Application Support/com.workbrew.workbrew-agent/api_key")
          .strip
    end
  end

  url "https://console.workbrew.com/downloads/macos?api_key=#{workbrew_api_key}"
  name "Workbrew"
  desc "Installer for Workbrew Agent"
  homepage "https://workbrew.com/"

  pkg "Workbrew-#{version}.pkg"

  preflight do
    next if ENV["USER"] == "workbrew"

    raise <<~EOS
      The Workbrew installer must be run manually the first time.
      This Cask is only used for upgrades. Download it and follow the instructions:
        #{Formatter.url("https://console.workbrew.com/downloads/macos")}
    EOS
  end

  uninstall rmdir: "/opt/workbrew"

  caveats <<~EOS
    `brew uninstall workbrew` will not fully uninstall Workbrew.
    To do so you must manually run:
       sudo /opt/workbrew/sbin/uninstall
  EOS
end
