const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const Parser = @This();
const buf_size = 64;
const t = @import("./types.zig");
const tracer = @import("tracer");

any: extras.AnyReader,
arena: std.mem.Allocator,
temp: std.ArrayListUnmanaged(u8) = .{},
idx: usize = 0,
end: bool = false,
line: usize = 1,
col: usize = 1,
extras: std.ArrayListUnmanaged(u32) = .{},
string_bytes: std.ArrayListUnmanaged(u8) = .{},
strings_map: std.StringArrayHashMapUnmanaged(t.StringIndex) = .{},

pub fn init(allocator: std.mem.Allocator, any: extras.AnyReader) Parser {
    return .{
        .any = any,
        .arena = allocator,
    };
}

pub fn deinit(ore: *Parser) void {
    ore.temp.deinit(ore.arena);
}

pub fn avail(ore: *Parser) usize {
    return ore.temp.items.len - ore.idx;
}

pub fn slice(ore: *Parser) []const u8 {
    return ore.temp.items[ore.idx..];
}

pub fn eat(ore: *Parser, comptime test_s: string) !void {
    if (test_s.len == 1) {
        _ = try ore.eatByte(test_s[0]);
        return;
    }
    try ore.peekAmt(test_s.len);
    if (std.mem.eql(u8, ore.slice()[0..test_s.len], test_s)) {
        ore.idx += test_s.len;
        return;
    }
    return error.Null;
}

fn peekAmt(ore: *Parser, amt: usize) !void {
    if (ore.avail() >= amt) return;
    const diff_amt = amt - ore.avail();
    std.debug.assert(diff_amt <= buf_size);
    var buf: [buf_size]u8 = undefined;
    var target_buf = buf[0..diff_amt];
    const len = try ore.any.readAll(target_buf);
    if (len == 0) ore.end = true;
    if (len == 0) return error.EndOfStream;
    std.debug.assert(len <= diff_amt);
    try ore.temp.appendSlice(ore.arena, target_buf[0..len]);
    if (len != diff_amt) return error.EndOfStream;
}

pub fn eatByte(ore: *Parser, test_c: u8) !u8 {
    try ore.peekAmt(1);
    if (ore.slice()[0] == test_c) {
        ore.idx += 1;
        return test_c;
    }
    return error.Null;
}

pub fn eatCp(ore: *Parser, comptime test_cp: u21) !u21 {
    return ore.eatRangeM(test_cp, test_cp);
}

pub fn eatRange(ore: *Parser, comptime from: u8, comptime to: u8) !u8 {
    try ore.peekAmt(1);
    const b = ore.slice()[0];
    if (b >= from and b <= to) {
        ore.idx += 1;
        return b;
    }
    return error.Null;
}

pub fn eatRangeM(ore: *Parser, comptime from: u21, comptime to: u21) !u21 {
    const from_len = comptime std.unicode.utf8CodepointSequenceLength(from) catch unreachable;
    const to_len = comptime std.unicode.utf8CodepointSequenceLength(to) catch unreachable;
    const amt = @max(from_len, to_len);
    try ore.peekAmt(amt);
    const len = try std.unicode.utf8ByteSequenceLength(ore.slice()[0]);
    if (amt != len) return error.EndOfStream;
    const mcp = try std.unicode.utf8Decode(ore.slice()[0..amt]);
    if (mcp >= from and mcp <= to) {
        ore.idx += len;
        return @intCast(mcp);
    }
    return error.Null;
}

pub fn eatAny(ore: *Parser, test_s: []const u8) !u8 {
    for (test_s) |c| {
        return ore.eatByte(c) catch continue;
    }
    return error.Null;
}

pub fn eatEnum(ore: *Parser, comptime E: type) !E {
    inline for (comptime std.meta.fieldNames(E)) |name| {
        if (ore.eat(name)) |_| {
            return @field(E, name);
        }
    }
    return error.Null;
}

pub fn eatEnumU8(ore: *Parser, comptime E: type) !E {
    inline for (comptime std.meta.fieldNames(E)) |name| {
        if (ore.eatByte(@intFromEnum(@field(E, name)))) |_| {
            return @field(E, name);
        }
    }
    return error.Null;
}

pub fn eatTok(ore: *Parser, comptime test_s: string) !void {
    const tr = tracer.trace(@src(), "({d})({s})", .{ ore.idx, test_s });
    defer tr.end();

    try ore.eat(test_s);
    var s: usize = 0;
    var n: usize = 0;
    while (true) {
        ore.peekAmt(1) catch break;
        const b = ore.slice()[0];
        if (b == ' ') {
            ore.idx += 1;
            s += 1;
            continue;
        }
        if (b == '\n') {
            ore.idx += 1;
            n += 1;
            continue;
        }
        if (comptime extras.matchesAll(u8, test_s, std.ascii.isAlphabetic)) {
            if (std.ascii.isAlphabetic(b)) {
                if (s == 0 and n == 0) {
                    return error.JsMalformed;
                }
            }
        }
        break;
    }
    //TODO: should this function also be the place that does semicolon insertion?
}

pub fn addStr(ore: *Parser, alloc: std.mem.Allocator, str: string) !t.StringIndex {
    const adapter: Adapter = .{ .ore = ore };
    var res = try ore.strings_map.getOrPutAdapted(alloc, str, adapter);
    if (res.found_existing) return res.value_ptr.*;
    const q = ore.string_bytes.items.len;
    try ore.string_bytes.appendSlice(alloc, str);
    const r = ore.extras.items.len;
    try ore.extras.appendSlice(alloc, &[_]u32{ @as(u32, @intCast(q)), @as(u32, @intCast(str.len)) });
    res.value_ptr.* = @enumFromInt(r);
    return @enumFromInt(r);
}

const Adapter = struct {
    ore: *const Parser,

    pub fn hash(ctx: @This(), a: string) u32 {
        _ = ctx;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(a);
        return @truncate(hasher.final());
    }

    pub fn eql(ctx: @This(), a: string, _: string, b_index: usize) bool {
        const sidx = ctx.ore.strings_map.values()[b_index];
        const b = ctx.ore.getStr(sidx);
        return std.mem.eql(u8, a, b);
    }
};

pub fn addStrList(ore: *Parser, alloc: std.mem.Allocator, items: []const t.StringIndex) !t.StringListIndex {
    if (items.len == 0) return .empty;
    const r = ore.extras.items.len;
    try ore.extras.ensureUnusedCapacity(alloc, 1 + items.len);
    ore.extras.appendAssumeCapacity(@intCast(items.len));
    ore.extras.appendSliceAssumeCapacity(@ptrCast(items));
    return @enumFromInt(r);
}

pub fn getStr(ore: *const Parser, sidx: t.StringIndex) string {
    const obj = ore.extras.items[@intFromEnum(sidx)..][0..2].*;
    const str = ore.string_bytes.items[obj[0]..][0..obj[1]];
    return str;
}
