const std = @import("std");
const string = []const u8;

pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype, isModule: bool) !void {
    //
    return @import("./parse.zig").do(alloc, path, inreader, isModule);
}
