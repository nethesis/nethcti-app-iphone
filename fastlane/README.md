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
Test notif
### voipiu
```
fastlane voipiu
```


----

## iOS
### ios prepare_development
```
fastlane ios prepare_development
```
All ios specific lanes

Prepare local environment for development.

Install development certificates and provisioning profiles.

Add new devices to devices.txt list if you need them for testing.
### ios tests
```
fastlane ios tests
```
Execute automatic tests and produce a code coverage report.

Be sure to have installed on your machine all devices defined in *devices array*.
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

### ios clean_ipa
```
fastlane ios clean_ipa
```

### ios commit_version
```
fastlane ios commit_version
```


----

## Android
### android tests
```
fastlane android tests
```
All Android specific lanes

Run unit tests for gradle builds

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
