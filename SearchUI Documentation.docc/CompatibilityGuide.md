# Compatibility Guide

What does SDK support

## Overview 

Mapbox Search SDK works with:
- iOS 11 or newer on any supported iOS powered device including iPad.
- iOS or Mac Catalyst.

    It's not possible to run SDK on watchOS or tvOS. macOS support is limited to [Mac Catalyst](https://developer.apple.com/mac-catalyst/).
- Swift 4.2 or newer.
- Xcode 12.5 or newer is recommended for [Swift Package Manager](https://developer.apple.com/documentation/swift_packages) integration.
    For non-SPM integration Xcode 11.3 is a minimal requirement.
- Mapbox Account token with `DOWNLOADS:READ` permission in user NetRC file is required for dependency managers functionality.

> Important: Token should be populated in password field inside `~/.netrc` file for `api.mapbox.com` host.

## Integration with the other Mapbox SDKs

To make integration with Mapbox Maps SDK or Mapbox Navigation SDK simple, it is highly recommended 
to keep Mapbox Search SDK updated. Mapbox SDKs has Mapbox Common SDK in common so it's extremely important
to have the same Common SDK version.


## See Also

- <doc:GettingStarted>
