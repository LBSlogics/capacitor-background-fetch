import { Plugin } from "@capacitor/core/dist/esm/definitions.d";
declare global {
    interface PluginRegistry {
        BackgroundFetch?: BackgroundFetchPlugin;
    }
}
declare type FetchResult = "newData" | "noData" | "failed";
declare type FetchInterval = "minimum" | "never";
export declare const FetchReceived = "BACKGROUNDFETCHRECEIVED";
export interface BackgroundFetchPlugin extends Plugin {
    setMinimumBackgroundFetchInterval(options: {
        interval: FetchInterval;
        seconds: number;
    }): Promise<void>;
    disableBackgroundFetch(options: {}): Promise<void>;
    fetchCompleted(options: {
        result: FetchResult;
    }): Promise<void>;
}
export {};
