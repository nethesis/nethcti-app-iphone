fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### notif
```
fastlane notif
```

### voipiu
```
fastlane voipiu
```


----

## iOS
### ios tests
```
fastlane ios tests
```
All ios specific lanes

Execute automatic tests and produce a code coverage report.
### ios prepare_version
```
fastlane ios prepare_version
```
Prepare the build number for the next build to deploy.
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight.
### ios beta_rebranding
```
fastlane ios beta_rebranding
```
Push a new beta build to Testflight without incrementing the build number.

Only use to publish apps for rebranding, after having incremented the main build number.

If you push without incrementing build number, it will be rejected.
### ios release
```
fastlane ios release
```


----

## Android
### android tests
```
fastlane android tests
```
All Android specific lanes

Push a new Beta build to Play Store Console

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
