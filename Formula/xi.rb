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
  version "0.0.86"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.86/xi-v0.0.86-macos-arm64.tar.gz"
      sha256 "952504302bc20c830a1000e1c61e2527aec141de7b5626f748239eb17b6492ea"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.86/xi-v0.0.86-macos-x86_64.tar.gz"
      sha256 "a85d86ac081a5393339d7827035f0c4a7667b3fe4e797406bb803aaf05213a49"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.86/xi-v0.0.86-linux-arm64.tar.gz"
      sha256 "c1a6652a311756a91846ba501c0c1b98d47bc450ba67a09c44ebdc3367e60a67"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.86/xi-v0.0.86-linux-x86_64.tar.gz"
      sha256 "e81a7d7aa683cd8021b1843d1b9fbd7035ea7f4708a73653477bcd1bacd742e0"
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
