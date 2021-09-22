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

If you don't have development certificates yet set `readonly` options to `false`. Do this only if you know what are you doing, since this lane invalidate and create certificates again.

After this action has finished, the obtained certificates and provisioning profile have to be manually linked to the project from linphone project windown inside xCode.
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

If is the first time of match certifications before submitting a version to Testflight, you have to generate new match certificates manually with the command `bundle exec fastlane run match type:appstore --env appstore`.
### ios release
```
fastlane ios release
```

### ios after_deployment
```
fastlane ios after_deployment
```

### ios clean_ipa
```
fastlane ios clean_ipa
```
Clean all useless .ipa files.
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
