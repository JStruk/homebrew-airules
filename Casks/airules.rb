cask "airules" do
  version "0.1.1"
  sha256 "3e1f4a03e86c2390263d627e5fdddb10c9a2e8339751b2166823d6464c184e1a"

  url "https://github.com/jstruk/airules/releases/download/v#{version}/airules-#{version}-universal-macos.zip"
  name "airules"
  desc "Synchronize global AI coding rules across local projects"
  homepage "https://github.com/jstruk/airules"

  depends_on macos: :ventura

  app "airules.app"
  binary "#{appdir}/airules.app/Contents/MacOS/airules"

  caveats <<~EOS
    airules is currently unsigned and not notarized. On first launch, macOS may
    block it. Open Applications in Finder, Control-click airules, choose Open,
    then confirm Open once. Future launches work normally.
  EOS
end
