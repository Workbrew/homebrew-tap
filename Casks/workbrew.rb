cask "workbrew" do
  version "0.2.0"
  sha256 "fb2ab31cfcf74294ff562cfef9f6e21222ab77699895a4ec93a6a0331ea7b50a"

  def workbrew_api_key
    @workbrew_api_key ||= ENV.fetch("HOMEBREW_WORKBREW_API_KEY") do
      api_key_directory = Pathname.new("/opt/workbrew/home/Library/Application Support/com.workbrew.workbrew-agent")
      if (device_api_key_file = api_key_directory/"device_api_key").exist?
        device_api_key_file.read.strip
      else
        (api_key_directory/"api_key").read.strip
      end
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
