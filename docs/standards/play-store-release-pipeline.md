# Android Play Store Internal Testing Release Pipeline Standard

Standardized architecture for automated Play Store Internal Testing releases across Shir0o mobile applications (e.g. `bible-read`, `attd`).

## 1. Core Architecture

The release pipeline consists of four integrated components:

```
┌─────────────────────────┐
│ Conventional Commit PR  │ (Enforced by PR title lint)
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│     release-please      │ (Updates pubspec/manifest, CHANGELOG.md, creates tag & GitHub Release)
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ GitHub Actions release  │ (Derives versionCode, builds signed AAB/APK, extracts sanitized notes)
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│     fastlane supply     │ (Uploads draft AAB + versionCode.txt changelog to Internal Track)
└─────────────────────────┘
```

1. **release-please**: Single source of truth for semantic versioning, `CHANGELOG.md` updates, version tags (`vX.Y.Z`), and GitHub Release creation.
2. **Deterministic `versionCode`**: Derived in CI from the semver tag using the formula `major * 10000 + minor * 100 + patch`. No manual incrementing in source control.
3. **Automated Release Notes Sanitization**: Extracts the current version's section from `CHANGELOG.md`, strips markdown issue links and commit hashes, normalizes bullets to `•`, clamps text to <= 500 characters (Play Console character ceiling), and writes to `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`.
4. **fastlane supply**: Uploads the signed AAB to Google Play internal testing track with `release_status: "draft"` and `metadata_path: "fastlane/metadata/android"`. The maintainer reviews release notes and promotes to production with a manual click in Google Play Console.

---

## 2. Fastlane Supply Configuration

The app's `fastlane/Fastfile` must define the `play_upload` lane:

```ruby
lane :play_upload do |options|
  aab_path = options[:aab_path] || ENV["FASTLANE_AAB_PATH"] || DEFAULT_AAB_PATH

  unless File.exist?(aab_path)
    UI.user_error!("AAB not found at #{aab_path}.")
  end

  upload_to_play_store(
    package_name: APP_PACKAGE_NAME,
    track: "internal",
    aab: aab_path,
    json_key: "fastlane/play-supply-credentials.json",
    release_status: "draft",
    metadata_path: "fastlane/metadata/android",
    skip_upload_metadata: false,
    skip_upload_changelogs: false,
    skip_upload_images: true,
    skip_upload_screenshots: true,
    validate_only: false,
  )
end
```

---

## 3. Release Notes Extraction Specification

Play Console enforces a strict 500-character limit per locale and does not render markdown links nicely. Before calling `play_upload`, the release workflow runs the standard ruby extraction block:

```bash
mkdir -p fastlane/metadata/android/en-US/changelogs
CHANGELOG_DEST="fastlane/metadata/android/en-US/changelogs/${VERSION_CODE}.txt"

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

  cleaned = body.gsub(/\s*\(\[[^\]]+\]\([^)]+\)\)/, "")
  cleaned = cleaned.gsub(/\[([^\]]+)\]\([^)]+\)/, "\\1")
  cleaned = cleaned.gsub(/\*\*([^*]+)\*\*/, "\\1")
  cleaned = cleaned.gsub(/\*([^*]+)\*/, "\\1")
  cleaned = cleaned.gsub(/^###?\s+(.+)$/, "\\1:")
  cleaned = cleaned.gsub(/^\s*[\*\-]\s+/, "\u2022 ")
  cleaned = cleaned.lines.map(&:rstrip).join("\n")
  cleaned = cleaned.gsub(/\n{3,}/, "\n\n").strip

  if cleaned.length > 500
    cleaned = cleaned[0...497] + "..."
  end

  if cleaned.empty?
    cleaned = "Bug fixes and improvements."
  end

  File.write(ARGV[0], cleaned)
' "$CHANGELOG_DEST"
```

---

## 4. Required GitHub Secrets

| Secret | Purpose |
| :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded upload keystore (`~/.keystores/upload-key.keystore`) |
| `KEY_ALIAS` | Keystore key alias |
| `KEY_PASSWORD` | Password for keystore private key |
| `STORE_PASSWORD` | Password for keystore storage |
| `PLAY_SUPPLY_JSON_KEY` | Google Play service account JSON key with release permissions |
| `RELEASE_PLEASE_TOKEN` | PAT with repo scope allowing release-please to push tags and trigger workflows |

---

## 5. Templates

Ready-to-use templates for adopting this standard in other apps are located in:
- `templates/play-store/release-flutter.yml`
- `templates/play-store/Fastfile.android`
- `templates/play-store/extract-release-notes.sh`
