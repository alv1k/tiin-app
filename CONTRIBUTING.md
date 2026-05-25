# Contributing

Every contribution to tiin_vpnApp is welcome, whether it is reporting a bug, submitting a fix, proposing new features, or just asking a question. To make contributing to tiin_vpnApp as easy as possible, you will find more details for the development flow in this documentation. [Basic tutorial on how to contribute to tiin_vpnApp](https://tiin_vpn.com/app/How-to-contribute-to-this-project/)

Please note, we have a [Code of Conduct](https://github.com/tiin_vpn/tiin_vpn-app/blob/main/CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

- [Feedback, Issues and Questions](#feedback-issues-and-questions)
- [Adding new Features](#adding-new-features)
- [Development](#development)
  - [Working with the Go Code](#working-with-the-go-code)
  - [Working with the Flutter Code](#working-with-the-flutter-code)
    - [Setting up the Environment](#setting-up-the-environment)
    - [Run Release Build on a Device](#run-release-build-on-a-device)
- [Release](#release)
- [Collaboration and Contact Information](#collaboration-and-contact-information)

## Feedback, Issues and Questions

If you encounter any issue, or you have an idea to improve, please:

- Search through [existing open and closed GitHub Issues](https://github.com/tiin_vpn/tiin_vpn-app/issues) for the answer first. If you find a relevant topic, please comment on the issue.
- If none of the issues are relevant, please add a new [issue](https://github.com/tiin_vpn/tiin_vpn-app/issues/new/choose) following the templates and provide as much relevant information as possible.

## Adding new Features

When contributing a complex change to the tiin_vpn repository, please discuss the change you wish to make within a GitHub issue with the owners of this repository before making the change.


## Development

### Adding Feature / Fix bug in Core:
Please follow our [Go Core Development repository](https://github.com/tiin_vpn/tiin_vpn-next-core/main/CONTRIBUTING.m).

### Working with the Flutter Code
tiin_vpn uses [Flutter](https://flutter.dev), make sure that you have the correct version installed before starting development. You can use the following commands to check your installed version:

```shell
$ flutter --version

# example response
Flutter 3.13.4 вЂў channel stable вЂў https://github.com/flutter/flutter.git
Framework вЂў revision 367f9ea16b (4 weeks ago) вЂў 2023-09-12 23:27:53 -0500
Engine вЂў revision 9064459a8b
Tools вЂў Dart 3.1.2 вЂў DevTools 2.25.0
```


We recommend using [Visual Studio Code](https://docs.flutter.dev/development/tools/vs-code) extensions for development.

#### Setting up the Environment

We have extensive use of code generation in the form of [freezed](https://github.com/rrousselGit/freezed), [riverpod](https://github.com/rrousselGit/riverpod), etc. So it's generate these before running the code. Execute the following make commands in order:
Assuming you have not built the `tiin_vpn-core` and want to use [existing releases](https://github.com/tiin_vpn/tiin_vpn-next-core/releases), you should run the following command (based on your target platform):


- `make windows-prepare`
- `make linux-prepare` 
- `make macos-prepare`
- `make ios-prepare`
- `make android-prepare`


##### build the `tiin_vpn-core` from source (Optional)
If you want to build the `tiin_vpn-core` from source after `make prepare`, use:
- `make build-windows-libs`
- `make build-linux-libs` 
- `make build-macos-libs`
- `make build-ios-libs`
- `make build-android-libs`

#### Run Release Build on a Device

To run the release build on a device for testing, we have to get the Device ID first by running the following command:

```shell
$ flutter devices

# example response
3 connected devices:

2211143G (mobile) вЂў 35492ae2 вЂў android-arm64  вЂў Android 13 (API 33)
Windows (desktop) вЂў windows  вЂў windows-x64    вЂў Microsoft Windows [Version 10.0.22000.2482]
Chrome (web)      вЂў chrome   вЂў web-javascript вЂў Google Chrome 117.0.5938.149
```

Then we can use one of the listed devices and execute the following command to build and run the app on this device:

```shell
flutter run
# or
flutter run --device-id=35492ae2
```

## Release

We use [flutter_distributor](https://github.com/leanflutter/flutter_distributor) for packaging. [GitHub action](https://github.com/tiin_vpn/tiin_vpn-app/blob/main/.github/workflows/build.yml) is triggered on every release tag and will create a new GitHub release.
After setting up the environment, use the following make commands to build the release version:

- `make windows-release`
- `make linux-release`
- `make macos-release`
- `make android-release`
- `make ios-release`

## Collaboration and Contact Information

We need your collaboration in order to develop this project. If you have experience in these areas, please do not hesitate to contact us.

- Flutter Developing
- Swift Developing
- Go Developing

<div align=center>
</br>

[![Email](https://img.shields.io/badge/Email-contribute@tiin_vpn.com-005FF9?style=flat-square&logo=mail.ru)](mailto:contribute@tiin_vpn.com)
[![Telegram Channel](https://img.shields.io/endpoint?label=Channel&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Ftiin_vpn&color=blue)](https://telegram.dog/tiin_vpn)
[![Telegram Group](https://img.shields.io/endpoint?color=neon&label=Support%20Group&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Ftiin_vpn_board)](https://telegram.dog/tiin_vpn_board)
[![Youtube](https://img.shields.io/youtube/channel/views/UCxrmeMvVryNfB4XL35lXQNg?label=Youtube&style=flat-square&logo=youtube)](https://www.youtube.com/@tiin_vpn)
[![Twitter](https://img.shields.io/twitter/follow/tiin_vpn_com?color=%231DA1F2&logo=twitter&logoColor=1DA1F2&style=flat-square)](https://twitter.com/intent/follow?screen_name=tiin_vpn_com)

</div>
