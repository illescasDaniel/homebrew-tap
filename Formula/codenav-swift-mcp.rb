require "open3"

class CodenavSwiftMcp < Formula
  desc "Compiler-accurate code navigation for Swift codebases, as an MCP server"
  homepage "https://github.com/illescasDaniel/codenav-swift-mcp"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.2.3/codenav-swift-mcp-0.2.3-macos-arm64.tar.gz"
      sha256 "033d8cab903f7f5a4823a0e490519e69dbb934e579baec272375d09dae184b3e"
    end

    on_intel do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.2.3/codenav-swift-mcp-0.2.3-macos-x86_64.tar.gz"
      sha256 "4274ef13f106c6cdba0c43c27112fb52e8cfed8a258403f083a30a2e272c13d7"
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
