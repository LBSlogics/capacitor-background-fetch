declare global {
    interface PluginRegistry {
        BackgroundFetch?: BackgroundFetchPlugin;
    }
}
export declare enum FetchResult {
    newData = "newData",
    noData = "noData",
    failed = "failed"
}
export declare enum FetchInterval {
    minimum = "minimum",
    never = "never"
}
export declare const FetchReceived = "BACKGROUNDFETCHRECEIVED";
export interface BackgroundFetchPlugin {
    setMinimumBackgroundFetchInterval(options: {
        interval: FetchInterval;
        seconds: number;
    }): Promise<void>;
    disableBackgroundFetch(options: {}): Promise<void>;
    fetchCompleted(options: {
        result: FetchResult;
    }): Promise<void>;
}
