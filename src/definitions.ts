declare global {
  interface PluginRegistry {
    BackgroundFetch?: BackgroundFetchPlugin;
  }
}

type FetchResult = "newData" | "noData" | "failed";

type FetchInterval = "minimum" | "never";

export const FetchReceived = "BACKGROUNDFETCHRECEIVED";

export interface BackgroundFetchPlugin {
  setMinimumBackgroundFetchInterval(options: {
    interval: FetchInterval;
    seconds: number;
  }): Promise<void>;
  disableBackgroundFetch(options: {}): Promise<void>;
  fetchCompleted(options: { result: FetchResult }): Promise<void>;
}
