# Capacitor Background Fetch

[![npm](https://img.shields.io/npm/v/capacitor-background-fetch.svg)](https://www.npmjs.com/package/capacitor-background-fetch)
iOS Background Fetch Plugin to be used with Ionic/Capacitor.

## Supported Platforms

- iOS

## Installation

- `npm i capacitor-background-fetch`
- `npx cap update`
- `pod install` in your iOS project folder

## Usage

#### Prequists

Background Fetch was introduced in iOS version `7`, so be sure to target devices with at least version 7.

##### Capabilities

- Go to the `Application Settings` > `Capabilities`
  -- Activate `Background Modes`
  -- Tick `Background fetch`
  <image>
- Open `Info.plist` and add:

```
<key>UIBackgroundModes</key>
 <array>
	<string>fetch</string>
 </array>
```

##### App Delegate

Add following AppDelegate function to your `AppDelegate` or add the `NotificationCenter` post call to your existing `performFetchWithCompletionHandler` function

```
func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NotificationCenter.default.post(name: NSNotification.Name(BackgroundNotifications.FetchReceived.name()), object: completionHandler)
  }
```

#### Ionic/Typescript

##### Import Background Fetch

```
import { Plugins } from '@capacitor/core';
const { BackgroundFetch } = Plugins;

import { FetchReceived } from 'capacitor-background-fetch';
```

##### Activate Background Fetch

```
BackgroundFetch.setMinimumBackgroundFetchInterval({
    interval: 'minimum',
    seconds: 0
});
```

##### Listen for Background Fetch Events

```
BackgroundFetch.addListener(FetchReceived, () => {
    // Do something in the Background

    // Call the completionHandler on iOS
    BackgroundFetch.fetchCompleted({
        result: 'newData' // 'noData' or 'failed'
    });
});
```

##### Deactivate Background Fetch

```
BackgroundFetch.disableBackgroundFetch({});
```

or

```
BackgroundFetch.setMinimumBackgroundFetchInterval({
    interval: 'never',
    seconds: 0
});
```

## API

#### setMinimumBackgroundFetchInterval

Sets the minimum background fetch interval but does not garantee that iOS will give you a fetch event after this interval. iOS does decide on its own, based on the users application usage, whenever it is best for your application to receive a fetch.

```
setMinimumBackgroundFetchInterval(options: {
    interval: FetchInterval;
    seconds: number;
}): Promise<void>;
```

**options**:

- `interval: FetchInterval`: either 'never' to deactivate or 'minimum' to the suggested minimum interval
- `seconds: number`: if no interval is available it takes the given amount of seconds as interval for longer intervals

**returns**: `Promise<void>`

#### disableBackgroundFetch

Disables background fetch if it is not used anymore. Same as calling `setMinimumBackgroundFetchInterval` with an interval of `never`.

```
disableBackgroundFetch(options: {}): Promise<void>;
```

**options**: none
**returns**: `Promise<void>`

#### fetchCompleted

Tells iOS that the fetch has completed and what was the outcome of the fetch.
This function needs to be called within approximatly 30 seconds after the fetch event was received otherwise iOS will kill your application.

**Note** This function can only be called once per fetch event! As soon as this function is called iOS will kill suspend the application again and no further background execution is possible. So if more tasks should be executed during one background fetch you need to start them all from one `FetchReceived` event and wait for their completion before calling `fetchCompleted`. **But** keep in mind that iOS will only give you about 30 seconds before killing your application.

```
fetchCompleted(options: { result: FetchResult }): Promise<void>;
```

**options**:

- `result: FetchResult`:
  -- `newData`: to indicate the fetch was successful and new data could be loaded
  -- `noData`: to indicate that no data could be loaded
  -- `failed`: to indicate that the fetch was failed

**returns**: `Promise<void>`

#### Plugin events

##### FetchReceived

**String representation**: BACKGROUNDFETCHRECEIVED
**Data**: None
**Triggered**: When a Background Fetch was initiated by the AppDelegate
