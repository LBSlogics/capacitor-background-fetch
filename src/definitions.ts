import { Plugin } from "@capacitor/core/dist/esm/definitions.d";

declare global {
  interface PluginRegistry {
    BackgroundFetch?: BackgroundFetchPlugin;
  }
}

export type FetchResult = "newData" | "noData" | "failed";

export type FetchInterval = "minimum" | "never";

export const FetchReceived = "BACKGROUNDFETCHRECEIVED";

export interface BackgroundFetchPlugin extends Plugin {
  setMinimumBackgroundFetchInterval(options: {
    interval?: FetchInterval;
    seconds?: number;
  }): Promise<void>;
  disableBackgroundFetch(options: {}): Promise<void>;
  fetch(options: {
    address: string;
    headers: { [id: string]: string };
  }): Promise<string>;
  fetchCompleted(options: { result: FetchResult }): Promise<void>;
}
