/*
    This binding is released under the BSD 2-clause license
    
    ---------------------------------------------------------------------------

    BSD 2-Clause License

    Copyright (c) 2024, Kitsunebi Games
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    ---------------------------------------------------------------------------

    The Superluminal Performance API is additionally released under the following license.
    BSD LICENSE

    Copyright (c) 2019-2020 Superluminal. All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in
        the documentation and/or other materials provided with the
        distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module superluminal.performance;
import core.sys.windows.windef : HMODULE;

version(EnablePerformanceAPI) enum EnablePerfAPI = true;
else enum EnablePerfAPI = false;

version(SuperluminalStatic) enum PerfAPIStatic = true;
else enum PerfAPIStatic = false;

version(Windows) {
    enum PERFORMANCEAPI_ENABLED = EnablePerfAPI;
    alias ModuleHandle = HMODULE;
} else {
    enum PERFORMANCEAPI_ENABLED = false;
    alias ModuleHandle = void*;
}

enum PERFORMANCEAPI_MAJOR_VERSION = 3;
enum PERFORMANCEAPI_MINOR_VERSION = 0;
enum PERFORMANCEAPI_VERSION = ((PERFORMANCEAPI_MAJOR_VERSION << 16) | PERFORMANCEAPI_MINOR_VERSION);


/**
    Helper function to create an uint color from 3 RGB values. The R, G and B values must be in range [0, 255].
    The resulting color can be passed to the BeginEvent function.
*/
enum PERFORMANCEAPI_MAKE_COLOR(ubyte R, ubyte G, ubyte B) = (
    (cast(uint)R << 24) | 
    (cast(uint)G << 16) | 
    (cast(uint)B << 8) | 
    cast(uint)0xFF
);

enum PERFORMANCEAPI_MAKE_COLOR(ubyte R, ubyte G, ubyte B, ubyte A) = (
    (cast(uint)R << 24) | 
    (cast(uint)G << 16) | 
    (cast(uint)B << 8) | 
    (cast(uint)A)
);

/**
    Use this define if you don't care about the color of an event and just want to use the default
*/
enum PERFORMANCEAPI_DEFAULT_COLOR = 0xFFFFFFFF;

/**
    Helper struct that is used to prevent calls to EndEvent from being optimized to jmp instructions as part of tail call optimization.
    You don't ever need to do anything with this as user of the API.
*/
struct PerformanceAPI_SuppressTailCallOptimization {
    long[3] suppressTailCall;
}

extern(C) @nogc nothrow:

static if (PERFORMANCEAPI_ENABLED && PerfAPIStatic) {
	/**
	    Set the name of the current thread to the specified thread name. 

	    @param inThreadName The thread name as an UTF8 encoded string.
	 */
	void PerformanceAPI_SetCurrentThreadName(const(char)* inThreadName);

	/**
	    Set the name of the current thread to the specified thread name. 

	    @param inThreadName The thread name as an UTF8 encoded string.
	    @param inThreadNameLength The length of the thread name, in characters, excluding the null terminator.
	 */
	void PerformanceAPI_SetCurrentThreadName_N(const(char)* inThreadName, ushort inThreadNameLength);

	/**
	    Begin an instrumentation event with the specified ID and runtime data
	 *
	    @param inID    The ID of this scope as an UTF8 encoded string. The ID for a specific scope must be the same over the lifetime of the program (see docs at the top of this file)
	    @param inData  [optional] The data for this scope as an UTF8 encoded string. The data can vary for each invocation of this scope and is intended to hold information that is only available at runtime. See docs at the top of this file.
	                              Set to null if not available.
	    @param inColor [optional] The color for this scope. The color for a specific scope is coupled to the ID and must be the same over the lifetime of the program
	                              Set to PERFORMANCEAPI_DEFAULT_COLOR to use default coloring.

	 */
	void PerformanceAPI_BeginEvent(const(char)* inID, const(char)* inData, uint inColor);

	/**
	    Begin an instrumentation event with the specified ID and runtime data, both with an explicit length.
	 
	    It works the same as the regular BeginEvent function (see docs above). The difference is that it allows you to specify the length of both the ID and the data,
	    which is useful for languages that do not have null-terminated strings.

	    Note: both lengths should be specified in the number of characters, not bytes, excluding the null terminator.
	 */
	void PerformanceAPI_BeginEvent_N(const(char)* inID, ushort inIDLength, const(char)* inData, ushort inDataLength, uint inColor);

	/**
	    Begin an instrumentation event with the specified ID and runtime data

	    @param inID    The ID of this scope as an UTF16 encoded string. The ID for a specific scope must be the same over the lifetime of the program (see docs at the top of this file)
	    @param inData  [optional] The data for this scope as an UTF16 encoded string. The data can vary for each invocation of this scope and is intended to hold information that is only available at runtime. See docs at the top of this file.
	 						      Set to null if not available.
	    @param inColor [optional] The color for this scope. The color for a specific scope is coupled to the ID and must be the same over the lifetime of the program
	                              Set to PERFORMANCEAPI_DEFAULT_COLOR to use default coloring.
	 */
	void PerformanceAPI_BeginEvent_Wide(const(wchar)* inID, const(wchar)* inData, uint inColor);

	/**
	    Begin an instrumentation event with the specified ID and runtime data, both with an explicit length.
	 
	    It works the same as the regular BeginEvent_Wide function (see docs above). The difference is that it allows you to specify the length of both the ID and the data,
	    which is useful for languages that do not have null-terminated strings.

	    Note: both lengths should be specified in the number of characters, not bytes, excluding the null terminator.
	 */
	void PerformanceAPI_BeginEvent_Wide_N(const(wchar)* inID, ushort inIDLength, const(wchar)* inData, ushort inDataLength, uint inColor);

	/**
	    End an instrumentation event. Must be matched with a call to BeginEvent within the same function
	    Note: the return value can be ignored. It is only there to prevent calls to the function from being optimized to jmp instructions as part of tail call optimization.
	 */
	PerformanceAPI_SuppressTailCallOptimization PerformanceAPI_EndEvent();

	/**
	    Call this function when a fiber starts running

	    @param inFiberID    The currently running fiber
	 */
	void PerformanceAPI_RegisterFiber(ulong inFiberID);

	/**
	    Call this function before a fiber ends

	    @param inFiberID    The currently running fiber
	 */
	void PerformanceAPI_UnregisterFiber(ulong inFiberID);

	/**
	    The call to the Windows SwitchFiber function should be surrounded by BeginFiberSwitch and EndFiberSwitch calls. For example:
	    
	    | PerformanceAPI_BeginFiberSwitch(currentFiber, otherFiber);
	    | SwitchToFiber(otherFiber);
	    | PerformanceAPI_EndFiberSwitch(currentFiber);

	    @param inCurrentFiberID    The currently running fiber
	    @param inNewFiberID		  The fiber we're switching to
	 */
	void PerformanceAPI_BeginFiberSwitch(ulong inCurrentFiberID, ulong inNewFiberID);

	/**
	    The call to the Windows SwitchFiber function should be surrounded by BeginFiberSwitch and EndFiberSwitch calls
	    	
	     | PerformanceAPI_BeginFiberSwitch(currentFiber, otherFiber);
	     | SwitchToFiber(otherFiber);
	     | PerformanceAPI_EndFiberSwitch(currentFiber);
	 *
	    @param inFiberID    The fiber that was running before the call to SwitchFiber (so, the same as inCurrentFiberID in the BeginFiberSwitch call)
	 */
	void PerformanceAPI_EndFiberSwitch(ulong inFiberID);
} else {
	pragma(inline, true) void PerformanceAPI_SetCurrentThreadName(const(char)* inThreadName) {}
	pragma(inline, true) void PerformanceAPI_SetCurrentThreadName_N(const(char)* inThreadName, ushort inThreadNameLength) {}
	pragma(inline, true) void PerformanceAPI_BeginEvent(const(char)* inID, const(char)* inData, uint inColor) {}
	pragma(inline, true) void PerformanceAPI_BeginEvent_N(const(char)* inID, ushort inIDLength, const(char)* inData, ushort inDataLength, uint inColor) {}
	pragma(inline, true) void PerformanceAPI_BeginEvent_Wide(const(wchar)* inID, const(wchar)* inData, uint inColor) {}
	pragma(inline, true) void PerformanceAPI_BeginEvent_Wide_N(const(wchar)* inID, ushort inIDLength, const(wchar)* inData, ushort inDataLength, uint inColor) {}
	pragma(inline, true) void PerformanceAPI_EndEvent() {}

	pragma(inline, true) void PerformanceAPI_RegisterFiber(ulong inFiberID) {}
	pragma(inline, true) void PerformanceAPI_UnregisterFiber(ulong inFiberID) {}
	pragma(inline, true) void PerformanceAPI_BeginFiberSwitch(ulong inCurrentFiberID, ulong inNewFiberID) {}
	pragma(inline, true) void PerformanceAPI_EndFiberSwitch(ulong inFiberID) {}
}

alias PerformanceAPI_SetCurrentThreadName_Func = void function(const(char)* inThreadName);
alias PerformanceAPI_SetCurrentThreadName_N_Func = void function(const(char)* inThreadName, ushort inThreadNameLength);
alias PerformanceAPI_BeginEvent_Func = void function(const(char)* inID, const(char)* inData, uint inColor);
alias PerformanceAPI_BeginEvent_N_Func = void function(const(char)* inID, ushort inIDLength, const(char)* inData, ushort inDataLength, uint inColor);
alias PerformanceAPI_BeginEvent_Wide_Func = void function(const(wchar)* inID, const(wchar)* inData, uint inColor);
alias PerformanceAPI_BeginEvent_Wide_N_Func = void function(const(wchar)* inID, ushort inIDLength, const(wchar)* inData, ushort inDataLength, uint inColor);
alias PerformanceAPI_EndEvent_Func = PerformanceAPI_SuppressTailCallOptimization function();

alias PerformanceAPI_RegisterFiber_Func = void function(ulong inFiberID);
alias PerformanceAPI_UnregisterFiber_Func = void function(ulong inFiberID);
alias PerformanceAPI_BeginFiberSwitch_Func = void function(ulong inCurrentFiberID, ulong inNewFiberID);
alias PerformanceAPI_EndFiberSwitch_Func = void function(ulong inFiberID);

/**
    Struct containing an instance of the performance API functions when dynamically linked.
*/
struct PerformanceAPI_Functions {
    // NOTE: The C/C++ headers has these as pointers, but in D functions are already a reference type.
    // As such it's not needed here.

	PerformanceAPI_SetCurrentThreadName_Func	setCurrentThreadName;
	PerformanceAPI_SetCurrentThreadName_N_Func	setCurrentThreadNameN;
	PerformanceAPI_BeginEvent_Func              beginEvent;
	PerformanceAPI_BeginEvent_N_Func            beginEventN;
	PerformanceAPI_BeginEvent_Wide_Func         beginEventWide;
	PerformanceAPI_BeginEvent_Wide_N_Func       beginEventWideN;
	PerformanceAPI_EndEvent_Func                endEvent;
	PerformanceAPI_RegisterFiber_Func           registerFiber;
	PerformanceAPI_UnregisterFiber_Func         unregisterFiber;
	PerformanceAPI_BeginFiberSwitch_Func        beginFiberSwitch;
	PerformanceAPI_EndFiberSwitch_Func          endFiberSwitch;
}

/**
    Entry point for the PerformanceAPI when used through a DLL. You can get the actual function from the DLL through
    GetProcAddress and then cast it to this function pointer. The name of the function exported from the DLL is "PerformanceAPI_GetAPI".

    A convenience function to find & call this function from the PerformanceAPI dll is provided in a separate header, PerformanceAPI_loader.h (PerformanceAPI_LoadFrom)
    
    @param inVersion The version of the header that's used to request the function table. Always specify PERFORMANCEAPI_VERSION for this argument (defined at the top of this file). 
                     Note: the version of the header and DLL must match exactly; if it doesn't an error will be returned.
    @param outFunctions Pointer to a PerformanceAPI_Functions struct that will be filled with the correct function pointers to use the API

    @return 0 if there was an error (version mismatch), 1 on success
 */
alias PerformanceAPI_GetAPI_Func = int function(int inVersion, PerformanceAPI_Functions* outFunctions) nothrow;


/**
    Loads the Superluminal Performance API from the specified DLL.

    This function automatically converts D UTF-8 text to UTF-16, without the GC.
*/
pragma(inline, true)
ModuleHandle loadAPIFrom(string inPathToDLL, PerformanceAPI_Functions* outFunctions) nothrow {    
    
    // Reset the handles.
    *outFunctions = PerformanceAPI_Functions.init;

    // Return no module handle if no name was specified.
    if (inPathToDLL.length == 0)
        return ModuleHandle.init;

    version(Windows) {
        import core.sys.windows.winnls : CP_UTF8, MultiByteToWideChar;
        import core.sys.windows.winnt : WCHAR;
        import core.sys.windows.core : LoadLibraryW, GetProcAddress;
        import core.stdc.stdlib : malloc, free;
        
        // Get required length of buffer.
        auto pLengthUTF16 = MultiByteToWideChar(CP_UTF8, 0, inPathToDLL.ptr, cast(int)inPathToDLL.length, null, 0);
        if (pLengthUTF16 == 0)
            return ModuleHandle.init;

        // Allocate UTF-16 buffer
        auto buf = cast(wchar*)malloc(pLengthUTF16+1 * wchar.sizeof);
        scope(exit) free(buf);
        if (!buf)
            return ModuleHandle.init;
        
        pLengthUTF16 = MultiByteToWideChar(CP_UTF8, 0, inPathToDLL.ptr, cast(int)inPathToDLL.length, buf, pLengthUTF16);
        if (pLengthUTF16 == 0)
            return ModuleHandle.init;

        // Null terminator is important!
        buf[pLengthUTF16] = '\0';

        // Now we get to loading it.
        ModuleHandle module_ = LoadLibraryW(buf);
        if (!module_)
            return ModuleHandle.init;
        
        // Try loading the PerformanceAPI_GetAPI function
        auto getAPIFunc = cast(PerformanceAPI_GetAPI_Func)GetProcAddress(module_, "PerformanceAPI_GetAPI");
        if (!getAPIFunc) {
            unloadAPI(module_); // @suppress(dscanner.unused_result)
            return ModuleHandle.init;
        }

        // Finally try loading the functions
        if (getAPIFunc(PERFORMANCEAPI_VERSION, outFunctions) == 0) {
            unloadAPI(module_); // @suppress(dscanner.unused_result)
            return ModuleHandle.init;
        }

        return module_;
    } else {
        return ModuleHandle.init;
    }
}

/**
    Unloads the specified Superluminal Performance API handle.

    Returns whether this operation succeeded.
*/
pragma(inline, true)
bool unloadAPI(ref ModuleHandle handle) nothrow {
    version(Windows) {
        import core.sys.windows.core : FreeLibrary;
        if (handle) {
            return cast(bool)FreeLibrary(handle);
        }
        return false;
    } else {
        return true;
    }
}