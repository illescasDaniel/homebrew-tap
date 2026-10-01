require "open3"

class CodenavSwiftMcp < Formula
  desc "Compiler-accurate code navigation for Swift codebases, as an MCP server"
  homepage "https://github.com/illescasDaniel/codenav-swift-mcp"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.1.3/codenav-swift-mcp-0.1.3-macos-arm64.tar.gz"
      sha256 "0d76c5e261f6519f9f85d8a916cb0487670a5b4c2c20ba5749a98d6ef1a0b017"
    end

    on_intel do
      url "https://github.com/illescasDaniel/codenav-swift-mcp/releases/download/v0.1.3/codenav-swift-mcp-0.1.3-macos-x86_64.tar.gz"
      sha256 "b5239a5d9797f4cec394d86c6da17e6cd0096e75adca52274349f7b79265c393"
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
