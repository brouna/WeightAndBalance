WeightAndBalance
================

Adam's Weight and Balance iOS app: enter the people, fuel and baggage on board and see whether the
aircraft is within its gross weight, baggage, fuel and CG envelope limits.

Version 4 is a rewrite of the original Objective-C app (versions 1–3, iOS 7) in Swift and SwiftUI.

Requirements
------------

- Xcode 16 or later (the project uses folder-synchronized groups)
- iOS 17 or later on device
- Swift 6 language mode

Project layout
--------------

```
WeightandBalance.xcodeproj   iOS app project (bundle ID com.abroun.WeightandBalance)
WeightandBalance/
  App/                       App entry point
  Model/                     Models, calculation, persistence, legacy-data migration (no UI code)
  Views/                     SwiftUI screens
  Resources/                 Asset catalog, bundled aircraft types, privacy manifest
Package.swift                Builds Model/ as a library so it can be tested with `swift test`
Tests/                       Model tests (Swift Testing) and legacy archive fixtures
Docs/                        User documentation and screenshots from version 2
```

Every file under `WeightandBalance/` is part of the app target automatically. Add new files there
in Xcode or on disk; there is no file list to update in the project.

Building and testing
--------------------

Open `WeightandBalance.xcodeproj`, choose your development team under Signing & Capabilities, and
run.

The model layer has unit tests that run on macOS or Linux without a simulator:

```
swift test
```

Data and migration from version 3
---------------------------------

The app saves to `Application Support/library.json`.

Versions 1–3 saved `aircraft.archive` and `types.v2.archive` (`NSKeyedArchiver`) in the Documents
folder. On first launch, version 4 reads those files, converts them, and writes `library.json`. The
old files are left in place. `LegacyArchive.swift` does the conversion. The tests cover it with the
types archive that shipped in version 3 and a generated aircraft archive
(`Tests/WeightAndBalanceCoreTests/Fixtures/make_legacy_aircraft_archive.py`).

`Resources/DefaultTypes.json` holds the aircraft types offered on a fresh install. It was converted
from version 3's `initialtypes.v2.archive`, and a test checks the two still match.
