require "open3"

class CodenavSwiftMcp < Formula
  desc "Compiler-accurate code navigation for Swift codebases, as an MCP server"
  homepage "https://github.com/illescasDaniel/codenav-swift-mcp"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.1.1/codenav-swift-mcp-0.1.1-macos-arm64.tar.gz"
      sha256 "f41451f167cb58e3c0cf0aa943564c261a636293d1561b8cde7cd35db8183c8c"
    end

    on_intel do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.1.1/codenav-swift-mcp-0.1.1-macos-x86_64.tar.gz"
      sha256 "0a3d3301b471e82a3e39c7e0b98c2cc58ab58de0f2492c05c328b8424144ff46"
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
