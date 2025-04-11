const std = @import("std");

const lib = @import("zig_ini_lib");

// main goal: pass struct to parser with desired fields
// in case of mismatch return error
// also type can be nullable
const Config = struct { protocol: struct { version: u8 }, user: struct { name: []u8, email: []u8, active: bool, pi: f32, trillion: u64, billion: u64 } };

const MyErorr = enum { DivisonByZero, InputUnsupported };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            @panic("Memory leaked");
        }
    }

    const allocator = gpa.allocator();

    const path = "src/test.ini";

    const content = try getFileContents(path[0..], allocator);
    defer allocator.free(content);

    std.debug.print("{s}\n", .{content});

    _ = parse(Config, content);
}

fn parse(Pattern: type, content: []u8) ?Pattern {
    _ = content;
    const info = @typeInfo(Pattern);
    inline for (info.@"struct".fields) |field| {
        const sub_info = @typeInfo(field.type);
        inline for (sub_info.@"struct".fields) |sub_field| {
            std.debug.print("{s} : {s} : {s}\n", .{ field.name, sub_field.name, @typeName(sub_field.type) });
        }
    }

    return null;
}

fn getFileContents(path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();

    const file = try cwd.openFile(path, .{});
    defer file.close();

    const content = try file.reader().readAllAlloc(allocator, 1024);

    return content;
}
