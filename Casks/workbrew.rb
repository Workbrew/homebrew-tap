cask "workbrew" do
  version "0.1.6"
  sha256 "5cf92c3ebec721358d26697bb599a90a7a79a8a8cc2ef2a9a60cd1cfbaf05302"

  def workbrew_api_key
    @workbrew_api_key ||= ENV.fetch("HOMEBREW_WORKBREW_API_KEY") do
      File.read("/opt/workbrew/home/Library/Application Support/com.workbrew.workbrew-agent/api_key")
          .strip
    end
  end

  url "https://console.workbrew.com/downloads/macos?api_key=#{workbrew_api_key}&version=#{version}"
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

  postflight do
    next if ENV["HOMEBREW_WORKBREW_AGENT_DAEMON_MODE"].present?

    ohai "Restarting Workbrew Agent"
    launchdaemon = "/Library/LaunchDaemons/com.workbrew.workbrew-agent.plist"
    system_command "/bin/launchctl", args: ["bootout",   "system", launchdaemon], sudo: true
    system_command "/bin/launchctl", args: ["bootstrap", "system", launchdaemon], sudo: true
  end

  uninstall rmdir: "/opt/workbrew"

  caveats <<~EOS
    `brew uninstall workbrew` will not fully uninstall Workbrew.
    To do so you must manually run:
       sudo /opt/workbrew/sbin/uninstall
  EOS
end
