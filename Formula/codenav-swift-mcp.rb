require "open3"

class CodenavSwiftMcp < Formula
  desc "Compiler-accurate code navigation for Swift codebases, as an MCP server"
  homepage "https://github.com/illescasDaniel/codenav-swift-mcp"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.2.2/codenav-swift-mcp-0.2.2-macos-arm64.tar.gz"
      sha256 "f1bf9dcacf49dff778c04d80f064d161e1a1425c370cac3aef3af73af0d763f6"
    end

    on_intel do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.2.2/codenav-swift-mcp-0.2.2-macos-x86_64.tar.gz"
      sha256 "ca1cd176dbce7610bc089fd19d3f985c9c1a4c5f76811823da67a848bb0859b8"
    end
  end

  def install
    bin.install "codenav-swift-mcp"
  end

  def caveats
    <<~EOS
      codenav-swift-mcp needs a Swift toolchain (Xcode or swift.org) at runtime for sourcekit-lsp.
      Register it with Claude Code:
        claude mcp add codenav-swift --scope user -- codenav-swift-mcp
    EOS
  end

  test do
    assert_path_exists bin/"codenav-swift-mcp"
    init = {
      jsonrpc: "2.0", id: 1, method: "initialize",
      params: { protocolVersion: "2025-03-26", capabilities: {}, clientInfo: { name: "brew", version: "0" } }
    }
    env = { "CODENAV_SWIFT_WORKSPACE" => testpath.to_s }
    Open3.popen3(env, bin/"codenav-swift-mcp") do |stdin, stdout, _stderr, wait_thr|
      stdin.puts JSON.generate(init)
      assert_match "codenav-swift", stdout.gets
    ensure
      Process.kill("TERM", wait_thr.pid)
    end
  end
end
