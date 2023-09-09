const std = @import("std");
const zero = std.mem.zeroes;

pub const cef = @cImport({
    @cInclude("include/capi/cef_base_capi.h");
    @cInclude("include/capi/cef_app_capi.h");
    @cInclude("include/capi/cef_client_capi.h");
    @cInclude("include/capi/cef_browser_capi.h");
});

pub fn toCefString(text: []const u8) cef.cef_string_t {
    var cef_str = zero(cef.cef_string_t);
    _ = cef.cef_string_utf8_to_utf16(text.ptr, text.len, &cef_str);
    return cef_str;
}

pub fn convertArray(comptime T: type, allocator: std.mem.Allocator, array: [][:0]T) ![][*]T {
    var result = try allocator.alloc([*]T, array.len);
    var i: usize = 0;
    while (i < array.len) : (i += 1) result[i] = @as([*]T, @ptrCast(array[i].ptr));
    return result;
}

pub inline fn toCPointer(comptime T: type, array: [][*]T) [*][*c]T {
    return @as([*][*c]T, @ptrCast(array.ptr));
}
