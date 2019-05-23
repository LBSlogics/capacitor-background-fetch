import { Plugin } from "@capacitor/core/dist/esm/definitions.d";

declare global {
  interface PluginRegistry {
    BackgroundFetch?: BackgroundFetchPlugin;
  }
}

export type FetchResult = "newData" | "noData" | "failed";

export type FetchInterval = "minimum" | "never";

export type HttpMethod = "GET" | "POST";

export type HttpResponse = {
  code: number;
  response: string;
};

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
    httpMethod?: HttpMethod;
    body?: string;
  }): Promise<HttpResponse>;
  fetchCompleted(options: { result: FetchResult }): Promise<void>;
}
