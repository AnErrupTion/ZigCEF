const std = @import("std");
const interop = @import("interop.zig");

const zero = std.mem.zeroes;

const cefLogSeverityDebug = interop.cef.LOGSEVERITY_DEBUG;
const CefApp = interop.cef.cef_app_t;
const CefMainArgs = interop.cef.cef_main_args_t;
const CefSettings = interop.cef.cef_settings_t;
const CefWindowInfo = interop.cef.cef_window_info_t;
const CefBrowserSettings = interop.cef.cef_browser_settings_t;
const CefClient = interop.cef.cef_client_t;
const cefExecuteProcess = interop.cef.cef_execute_process;
const cefInitialize = interop.cef.cef_initialize;
const cefBrowserHostCreateBrowser = interop.cef.cef_browser_host_create_browser;
const cefRunMessageLoop = interop.cef.cef_run_message_loop;
const cefShutdown = interop.cef.cef_shutdown;

pub fn main() !void {
    // Initialize CEF with arguments
    {
        const allocator = std.heap.page_allocator;

        const args = try std.process.argsAlloc(allocator);
        defer std.process.argsFree(allocator, args);

        const c_args = try interop.convertArray(u8, allocator, args);
        defer allocator.free(c_args);

        const main_args = CefMainArgs{
            .argc = @intCast(args.len),
            .argv = interop.toCPointer(u8, c_args),
        };

        var app = zero(CefApp);

        const code = cefExecuteProcess(&main_args, &app, null);
        if (code >= 0) std.process.exit(@intCast(code));

        var settings = zero(CefSettings);
        settings.size = @sizeOf(CefSettings);
        settings.log_severity = cefLogSeverityDebug;
        settings.no_sandbox = 1;

        _ = cefInitialize(&main_args, &settings, &app, null);
    }

    // Create window and browser
    {
        var window_info = zero(CefWindowInfo);
        window_info.window_name = interop.toCefString("ZigCEF");

        const url = interop.toCefString("https://html.duckduckgo.com");

        var browser_settings = zero(CefBrowserSettings);
        browser_settings.size = @sizeOf(CefBrowserSettings);

        var client = zero(CefClient);
        _ = cefBrowserHostCreateBrowser(&window_info, &client, &url, &browser_settings, null, null);
    }

    // Run message loop until exit signal received, then shut down
    cefRunMessageLoop();
    cefShutdown();
}
