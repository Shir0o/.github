#!/usr/bin/env bash
# Extract, sanitize, and clamp latest release notes from CHANGELOG.md into fastlane changelog file
set -euo pipefail

DEST_FILE="${1:-}"
if [ -z "$DEST_FILE" ]; then
  echo "Usage: $0 <destination_file_path>"
  exit 1
fi

mkdir -p "$(dirname "$DEST_FILE")"

ruby -e '# encoding: utf-8
  changelog = File.exist?("CHANGELOG.md") ? File.read("CHANGELOG.md", encoding: "utf-8") : ""
  tag = ENV["GITHUB_REF_NAME"] || ""
  ver = tag.sub(/^v/, "").split("-").first || ""

  pattern = if !ver.empty?
    /^##\s+\[?v?#{Regexp.escape(ver)}\]?[^\n]*\n(.*?)(?=^##\s+\[?v?[0-9]|\Z)/m
  else
    /^##\s+\[?v?[0-9]+\.[0-9]+\.[0-9]+[^\]\n]*\]?[^\n]*\n(.*?)(?=^##\s+\[?v?[0-9]|\Z)/m
  end

  match = changelog.match(pattern)
  body = match ? match[1].strip : ""

  # Strip Markdown commit links and issue links: e.g. ([#123](...)) or ([abc](...))
  cleaned = body.gsub(/\s*\(\[[^\]]+\]\([^)]+\)\)/, "")
  cleaned = cleaned.gsub(/\[([^\]]+)\]\([^)]+\)/, "\\1")
  # Strip bold/italic formatting
  cleaned = cleaned.gsub(/\*\*([^*]+)\*\*/, "\\1")
  cleaned = cleaned.gsub(/\*([^*]+)\*/, "\\1")

  # Convert markdown headings (### Features) to plain titles with colon
  cleaned = cleaned.gsub(/^###?\s+(.+)$/, "\\1:")

  # Standardize bullet points using unicode bullet
  cleaned = cleaned.gsub(/^\s*[\*\-]\s+/, "\u2022 ")

  # Clean trailing spaces and excess blank lines
  cleaned = cleaned.lines.map(&:rstrip).join("\n")
  cleaned = cleaned.gsub(/\n{3,}/, "\n\n").strip

  # Enforce 500-char Play Store limit
  if cleaned.length > 500
    cleaned = cleaned[0...497] + "..."
  end

  if cleaned.empty?
    cleaned = "Bug fixes and improvements."
  end

  File.write(ARGV[0], cleaned)
  puts "Generated release notes for #{ARGV[0]} (#{cleaned.length} chars):"
  puts cleaned
' "$DEST_FILE"
