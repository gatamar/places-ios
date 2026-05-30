# places-ios

This is a test assignment app, the SwiftUI's Places App.

For the Wikipedia tweak app, see [my Wiki's fork branch](todo-link-to-PR-or-branch).

## Architecture

+ `MVVM` with more-or-less clear separation between layers is used
+ `Services`/`Repositories` use async/await
+ instead of `Published`+`Combine`, Apple-recommended `Observation` framework is used for ViewModels
+ `Observation` is used even for `LocationRepositoryImpl`, because it's a simple approach; for a better reactiveness I could use AsyncStream/Combine/~~ReactiveSwift~~ (in the order of preference).
+ dependencies are declared at the app's root; they are injected explicitly into each View/ViewModel which needs them; SwiftUI's `Environment` should probably have been used, but I haven't found an elegant way to properly pass those from a `View` to `ViewModel`, given `ViewModel`'s are owned and created by `View`s in this app.

## The Deeplink Scheme

`wikipedia://places` scheme is reused, with `WMFCoord` query item name introduced.
`Places` app's `Location` is passed as a URL-encoded `WMFCoord` query item value.

That logic is contained in `PlacesDeeplinkFormatter`, and `PlacesDeeplinkFormatterTests` show a deeplink example. 

## Accessibility

### Dynamic Type

TBD

### Dark Mode

TBD

### VoiceOver

TBD

### VoiceControl

TBD

## Known tech/UX debt

TBD