class Airules < Formula
  desc "Synchronize global AI coding rules across local projects"
  homepage "https://github.com/jstruk/airules"
  url "https://github.com/jstruk/airules/releases/download/v0.1.0/airules-0.1.0.tar.gz"
  sha256 "632bb693bdc1096f6fa64bddce7d4ba8f0149c094d02b4927f95568cf2ebc91f"
  license "MIT"

  depends_on "rust" => :build
  depends_on macos: :ventura

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "13.0"
    system "cargo", "install", *std_cargo_args(path: "src-tauri"), "--offline"
  end

  test do
    require "digest"
    require "json"
    require "socket"

    assert_match "airules #{version}", shell_output("#{bin}/airules --version")
    assert_match "Usage:", shell_output("#{bin}/airules --help")

    config = testpath/"cli-config"
    project = testpath/"project"
    project.mkpath
    cd project do
      output = shell_output("#{bin}/airules --config-dir #{config} init")
      assert_match "Registered project:", output
      assert_match "Next: airules sync --append", output
      assert_path_exists config/"projects.json"
      refute_path_exists project/"AGENTS.md"
    end

    lifecycle_config = testpath/"lifecycle-config"
    lifecycle_config.mkdir(0700)
    runtime = nil
    socket = nil
    pid = nil
    begin
      ENV["AIRULES_TAURI_SMOKE"] = "1"
      system bin/"airules", "--config-dir", lifecycle_config
      ENV.delete("AIRULES_TAURI_SMOKE")

      identity = Digest::SHA256.hexdigest(lifecycle_config.realpath.to_s)
      runtime = Pathname("/tmp")/"airules-#{Process.uid}"/identity
      socket = runtime/"instance.sock"
      state_path = lifecycle_config/"tauri-smoke-ready.json"
      deadline = Time.now + 8
      sleep 0.05 until (socket.socket? && state_path.exist?) || Time.now >= deadline
      assert_predicate socket, :socket?
      state = JSON.parse(state_path.read)
      pid = Integer(state.fetch("pid"))
      assert state.fetch("initialized")
      assert_equal "tauri", state.fetch("runtime")
      refute state.fetch("visible")

      UNIXSocket.open(socket.to_s) { |connection| connection.write("quit\n") }
      sleep 0.05 while process_alive?(pid) && Time.now < deadline
      refute process_alive?(pid), "resident lifecycle process #{pid} did not quit"
      refute_path_exists socket
    ensure
      ENV.delete("AIRULES_TAURI_SMOKE")
      UNIXSocket.open(socket.to_s) { |connection| connection.write("quit\n") } if socket&.socket?
      if pid
        cleanup_deadline = Time.now + 2
        sleep 0.05 while process_alive?(pid) && Time.now < cleanup_deadline
        if process_alive?(pid)
          Process.kill("TERM", pid)
          cleanup_deadline = Time.now + 2
          sleep 0.05 while process_alive?(pid) && Time.now < cleanup_deadline
        end
        Process.kill("KILL", pid) if process_alive?(pid)
      end
      rm_r runtime if runtime&.directory? && (pid.nil? || !process_alive?(pid))
    end
  end

  private

  def process_alive?(pid)
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH
    false
  end
end
