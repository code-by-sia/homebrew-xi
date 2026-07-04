# typed: false
# frozen_string_literal: true

# Homebrew formula for the Ξ (Xi) programming language toolchain.
#
# This file is the source of truth for the `code-by-sia/homebrew-xi` tap; the
# release workflow regenerates the version/url/sha256 lines via
# `scripts/update-formula.sh` and pushes the result to the tap repo. See
# packaging/homebrew/README.md for the one-time tap setup.
class Xi < Formula
  desc "The Ξ (Xi) programming language toolchain (compiler + REPL)"
  homepage "https://github.com/code-by-sia/xi"
  version "0.0.90"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.90/xi-v0.0.90-macos-arm64.tar.gz"
      sha256 "54d4b10124c0f475f1a831b90c0d4c2dcd9f88ce020a51a94360e7efe07da8d5"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.90/xi-v0.0.90-macos-x86_64.tar.gz"
      sha256 "102cd7847a57efcd91d83219700b81aa9e3259b1c1e8b5c1293d121294d38b2f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.90/xi-v0.0.90-linux-arm64.tar.gz"
      sha256 "4df0256a1ddc77f5aabc3a331568ad571b66c858c3db7624e7da233f4271796e"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.90/xi-v0.0.90-linux-x86_64.tar.gz"
      sha256 "dc24d78095732dde6fd26dc68dd0509d053a3264c8f206c1350eda4e25a298ae"
    end
  end

  def install
    # The tarball expands to a single top-level dir (Homebrew has already cd'd
    # into it). Stash the bundle under libexec and write absolute-path wrappers
    # so xc/xi find the runtime and stdlib regardless of how bin is symlinked.
    libexec.install Dir["*"]

    (bin/"xc").write <<~SH
      #!/bin/sh
      export XC_RUNTIME="${XC_RUNTIME:-#{libexec}/runtime}"
      export XC_STD="${XC_STD:-#{libexec}}"
      exec "#{libexec}/libexec/xc" "$@"
    SH

    (bin/"xi").write <<~SH
      #!/bin/sh
      export XC_RUNTIME="${XC_RUNTIME:-#{libexec}/runtime}"
      export XC_STD="${XC_STD:-#{libexec}}"
      export XC="${XC:-#{bin}/xc}"
      exec "#{libexec}/libexec/xi" "$@"
    SH

    chmod 0755, bin/"xc"
    chmod 0755, bin/"xi"
  end

  def caveats
    <<~EOS
      xc compiles Xi to C and invokes a C compiler to produce native binaries,
      so a working `cc` (clang/gcc) must be on your PATH.
    EOS
  end

  test do
    (testpath/"hello.xi").write <<~XI
      import "std/log.xi"
      async entry (logger: Logger) main(args: String[]) {
          logger.info("brew ok")
      }
      module App {}
    XI
    assert_match "brew ok", shell_output("#{bin}/xi hello.xi")
  end
end
