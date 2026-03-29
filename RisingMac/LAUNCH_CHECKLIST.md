# RisingMac — Launch Checklist

## Pre-Submission (1–2 weeks before)

### ✅ App Metadata
- [ ] App Store listing drafted (`Marketing/APPSTORE.md`)
- [ ] Tagline finalized: "Every goal, one step closer."
- [ ] App description written (calm fintech tone, greens/whites aesthetic)
- [ ] Keywords researched and entered in App Store Connect
- [ ] Category selected: Finance
- [ ] Pricing set: Free (or paid tier if applicable)

### ✅ Screenshots
- [ ] 5 screenshots captured at 1280×720 (macOS App Store minimum)
- [ ] All text clearly legible (colorblind-safe palette verified)
- [ ] Screenshots show real content (not placeholder data)
- [ ] Screenshot 1: Goals Dashboard with progress rings
- [ ] Screenshot 2: Goal Detail with deposit history
- [ ] Screenshot 3: Add Deposit sheet
- [ ] Screenshot 4: Statistics view
- [ ] Screenshot 5: Menu bar extra
- [ ] Optional: 5" retina screenshots at 2560×1440

### ✅ Preview Video
- [ ] 30-second video recorded
- [ ] Shows goal creation → deposit → progress animation
- [ ] Voiceover recorded (optional) or text captions included
- [ ] Exported as .mov or .mp4 (H.264, max 500MB)

### ✅ Accessibility Audit
- [ ] VoiceOver labels on all interactive elements
- [ ] Progress bars use patterns + color (not color alone)
- [ ] Charts have axis labels
- [ ] High contrast text (WCAG AA compliant)
- [ ] All images have alt text / accessibility labels
- [ ] Tested with VoiceOver navigation

### ✅ Legal
- [ ] Privacy Policy written and hosted
- [ ] Terms of Service written and hosted
- [ ] Privacy nutrition label filled in App Store Connect
- [ ] Sandbox entitlement enabled
- [ ] App Sandbox entitlement (com.apple.security.app-sandbox) — required for Mac App Store
- [ ] Hardened Runtime enabled (for notarization)

---

## Build & Code Signing (1 week before)

### ✅ Certificates & Profiles
- [ ] Apple Developer account active (paid membership)
- [ ] Mac App Store Distribution certificate created
- [ ] Developer ID Application certificate created (for notarization)
- [ ] Provisioning profile for Mac App Store created
- [ ] App ID registered in App Store Connect

### ✅ Entitlements
- [ ] `com.apple.security.app-sandbox` = true
- [ ] `com.apple.security.network.client` = false (no network needed)
- [ ] `com.apple.security.files.user-selected.read-write` = true
- [ ] Hardened Runtime = YES

### ✅ Build
- [ ] `xcodegen generate` runs clean
- [ ] Build succeeds: `xcodebuild -scheme RisingMac -configuration Release -destination 'platform=macOS,arch=arm64' build CODE_SIGN_IDENTITY="-" 2>&1 | grep -E "error:|BUILD" | tail -5`
- [ ] No compiler warnings in Release build
- [ ] Code signed with distribution certificate
- [ ] Notarized with `xcrun notarytool` (if distributing outside MAS)
- [ ] App bundle validated with `xcrun stapler validate`

### ✅ App Store Connect
- [ ] App created in App Store Connect
- [ ] Bundle ID matches project
- [ ] Version number set (e.g., 1.0.0)
- [ ] Build uploaded via Xcode or Transporter
- [ ] Build appears in "App Store Connect → App → Builds"

---

## Submission (Day of)

### ✅ App Store Connect Form
- [ ] Platform: macOS selected
- [ ] New version created (e.g., 1.0)
- [ ] All metadata fields filled:
  - [ ] Name: RisingMac
  - [ ] Subtitle: Smart Savings Goals for macOS
  - [ ] Description
  - [ ] Keywords
  - [ ] Category: Finance
  - [ ] Pricing
  - [ ] Privacy Policy URL
  - [ ] Screenshots uploaded
  - [ ] Preview video uploaded
- [ ] Age rating completed
- [ ] Copyright field filled

### ✅ Review Notes
- [ ] Added notes for reviewer about:
  - How to test menu bar (click the icon in menu bar)
  - How to create a goal
  - How to add a deposit
  - That all data is local (no server needed to test)

---

## Post-Submission

### ✅ After Approval
- [ ] Release version set to "Automatically release after approval" or manual
- [ ] Release notes written for this version
- [ ] Marketing materials ready (Twitter, blog post, etc.)
- [ ] Monitor App Store Connect for any issues

### ✅ Post-Launch
- [ ] Monitor crash reports in App Store Connect
- [ ] Monitor user reviews
- [ ] Push bug fixes quickly if issues found
- [ ] Consider announcing on:
  - [ ] Twitter/X
  - [ ] Product Hunt
  - [ ] Hacker News
  - [ ] Relevant subreddits (r/macapps, r/finance, etc.)

---

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 | TBD | Initial submission |
