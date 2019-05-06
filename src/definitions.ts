declare global {
  interface PluginRegistry {
    BackgroundFetch?: BackgroundFetchPlugin;
  }
}

export enum FetchResult {
  newData = "newData",
  noData = "noData",
  failed = "failed"
}

export enum FetchInterval {
  minimum = "minimum",
  never = "never"
}

export const FetchReceived = "BACKGROUNDFETCHRECEIVED";

export interface BackgroundFetchPlugin {
  setMinimumBackgroundFetchInterval(options: {
    interval: FetchInterval;
    seconds: number;
  }): Promise<void>;
  disableBackgroundFetch(options: {}): Promise<void>;
  fetchCompleted(options: { result: FetchResult }): Promise<void>;
}
