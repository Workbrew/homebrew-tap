cask "workbrew" do
  version "0.2.6"
  sha256 "30570b0308dadabbeacdf086953e0e5a66c2ba3b92afc5f4920a581c48b849ee"

  url "https://console.workbrew.com/downloads/macos?version=#{version}"
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
