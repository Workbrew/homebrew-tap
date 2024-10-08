cask "workbrew" do
  version "0.9.5"
  sha256 "fe6215ced3181a8881d6e707d68184392832b4463164132bde8fe31d4d99d2e4"

  url "https://console.workbrew.com/downloads/macos?version=#{version}"
  name "Workbrew"
  desc "Installer for Workbrew Agent"
  homepage "https://workbrew.com/"

  disable! date: "2024-09-17", because: "Workbrew cask is no longer supported."

  auto_updates true

  pkg "Workbrew-#{version}.pkg"

  preflight do
    if ENV["USER"] != "workbrew"
      raise <<~EOS
        The Workbrew Installer must be run manually the first time.
        This Cask is only used for upgrades. Download it and follow the instructions:
          #{Formatter.url("https://console.workbrew.com")}
      EOS
    end

    workbrew_directory = Pathname.new("/opt/workbrew")
    workbrew_api_key_directory = workbrew_directory/"home/Library/Application Support/com.workbrew.workbrew-agent"
    next if %w[device_api_key api_key].any? { |file| (workbrew_api_key_directory/file).exist? }

    raise <<~EOS
      The Workbrew Installer must have its API key setup before installation.
      Download it and follow the instructions:
        #{Formatter.url("https://console.workbrew.com")}
    EOS
  end

  postflight do
    next if ENV["HOMEBREW_WORKBREW_AGENT_DAEMON_MODE"].present?
    next if ENV["GITHUB_ACTIONS"].present?

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
