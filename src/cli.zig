// caristo/src/cli.zig
//
// This file contains the logic needed for caristo
// to process flags, parameters, as well as other
// hard-coded components, such as the output for the
// version and help messages.

const std = @import("std");

const mem = std.mem;

pub const LOGO =
    \\                   _/_
    \\ _. __.  __  o _   /  __
    \\(__(_/|_/ (_<_/_)_<__(_)
    \\
    \\:::::::::::::::::::::::
    \\ >_ ARR bxavaby 2025  +
    \\:::::::::::::::::::::::
    \\
    \\+---------------------+
    \\| random list sampler |
    \\|  command-line tool  |
    \\+---------------------+
;

pub const VERSION = "v0.1.0";

pub const HELP =
    \\
    \\Usage: caristo [options] [count]
    \\
    \\Description:
    \\  Given a list, caristo will pick a default amount of elements
    \\  from it, and pass them to stdout. The default value depends
    \\  on the list length, but it can be overridden with [count].
    \\
    \\Options:
    \\  -h, --help             Display this help message
    \\  -v, --version          Display the version number
;

pub const EXAMPLE =
    \\                     _/_
    \\   _. __.  __  o _   /  __
    \\  (__(_/|_/ (_<_/_)_<__(_)
    \\   ----- + v0.1.0 + -----
    \\+---------------------------+
    \\| babynames.txt | caristo 1 |
    \\+---------------------------+
;

pub const CliOpts = struct {
    count: ?usize = null,
    help: bool = false,
    version: bool = false,
    unique: bool = false,
};

pub fn parseArgs(allocator: mem.Allocator) anyerror!CliOpts {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    var options = CliOpts{};
    _ = args.next(); // Skip name

    while (args.next()) |arg| {
        if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help") or mem.eql(u8, arg, "help") or mem.eql(u8, arg, "-H")) {
            options.help = true;
        } else if (mem.eql(u8, arg, "-v") or mem.eql(u8, arg, "--version") or mem.eql(u8, arg, "version") or mem.eql(u8, arg, "-V")) {
            options.version = true;
            // To-do: implement unique flag
            // } else if (mem.eql(u8, arg, "-u") or mem.eql(u8, arg, "--unique") or mem.eql(u8, arg, "unique") or mem.eql(u8, arg, "-U")) {
            //     options.unique = true;
        } else if (arg[0] != '-') {
            if (options.count != null) return error.InvalidCount;
            const parsed_count = std.fmt.parseInt(usize, arg, 10) catch return error.InvalidCount;
            if (parsed_count == 0) return error.InvalidCount;
            options.count = parsed_count;
        } else {
            return error.UnknownFlag;
        }
    }

    return options;
}

pub fn printHelpWithEr(msg: []const u8) void {
    std.debug.print("error: {s}\n{s}\n", .{ msg, HELP });
}
