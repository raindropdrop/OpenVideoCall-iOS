# Open Video Call iOS for Swift

*其他语言版本： [简体中文](README.md)*

The Open Video Call iOS for Swift Sample App is an open-source demo that will help you get video chat integrated directly into your iOS applications using the Agora Video SDK.

With this sample app, you can:

- Join / leave channel
- Mute / unmute audio
- Enable / disable video
- Switch camera
- Send message to channel
- Setup resolution, frame rate and bit rate
- Enable encryption
- Enable / disable black and white filter

This demo is written in **Swift**, you can find **Objective-C** version here: [OpenVideoCall-iOS-Objective-C](https://github.com/AgoraIO/OpenVideoCall-iOS-Objective-C)

A tutorial demo can be found here: [Agora-iOS-Tutorial-Swift-1to1](https://github.com/AgoraIO/Agora-iOS-Tutorial-Swift-1to1)

Agora Video SDK supports iOS / Android / Windows / macOS etc. You can find demos of these platform here:

- [OpenVideoCall-Android](https://github.com/AgoraIO/OpenVideoCall-Android)
- [OpenVideoCall-Windows](https://github.com/AgoraIO/OpenVideoCall-Windows)
- [OpenVideoCall-macOS](https://github.com/AgoraIO/OpenVideoCall-macOS)

## Running the App
First, create a developer account at [Agora.io](https://dashboard.agora.io/signin/), and obtain an App ID. Update "KeyCenter.swift" with your App ID.

```
static let AppId: String = "Your App ID"
```

Next, download the **Agora Video SDK** from [Agora.io SDK](https://www.agora.io/en/blog/download/). Unzip the downloaded SDK package and copy the files in **libs** folder

- AgoraRtcEngineKit.framework
- AgoraRtcCryptoLoader.framework
- libcrypto.a

to the "OpenVideoCall" folder in project.

Finally, Open OpenVideoCall.xcodeproj, connect your iPhone／iPad device, setup your development signing and run.

## Developer Environment Requirements
* XCode 8.0 +
* Real devices (iPhone or iPad)
* iOS simulator is NOT supported

## Connect Us

- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can fire bugs about this demo at [issue](https://github.com/AgoraIO/OpenVideoCall-iOS/issues)

## License

The MIT License (MIT).
