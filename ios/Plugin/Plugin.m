#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(BackgroundFetch, "BackgroundFetch",
           CAP_PLUGIN_METHOD(setMinimumBackgroundFetchInterval, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(disableBackgroundFetch, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(fetchCompleted, CAPPluginReturnPromise);
)
