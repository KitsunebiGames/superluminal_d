# Superluminal Performance API for D

This is a binding to the Superluminal Performance API headers for D.

You will need to have Superluminal installed for this to work.  
By default the `dynamic` configuration is used, for this configuration you will need to add `version "EnablePerfAPI"` to your dub configuration to enable the performance api. This allows you to turn it off while not profiling.

When the performance API is turned off, all function calls to it will be directed to dummy implementations.

## Example

```d
import superluminal.performance;

void main() {
    PerformanceAPI_Functions perfApi;
    auto module_ = loadAPIFrom("PerformanceAPI.dll", &perfAPI);


    // Add instrumentation event
    {
        perfAPI.beginEvent("My Event", null, PERFORMANCEAPI_DEFAULT_COLOR);

        // Long running code goes here.

        perfAPI.endEvent();
    }
}

```