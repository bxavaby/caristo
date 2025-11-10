// Welcome to caristo/src/main.zig
//
// caristo is a simple command-line sampler for text-based data,
// using the reservoir sampling algorithm.
//
// It is also my 2nd ever project in Zig, so pardon any misteps.
//
// Anyhow, here's how I first thought it would work:
//
// 1. read from stdin;
// 2. compute amount of options (lines);
// 3. depending on the quantity, select default count;
// 4. reservoir sample;
// 5. selection to stdout.
//
// Expanding on step 3, a switch statement would be used
// to "smartly" pick a default count value. If a list had
// x lines, y would be the value of count:
//
// 1-4 -> 1
// 5-6 -> 2
// 7-8 -> 3
// 9 -> 4
// 10-49 -> 5
// 50-99 -> 10
// 100-999 -> 15
// 1000+ -> 20
//
// Note: this would be great, but there are some caveats
// to consider, especially when dealing with large sets.
// For this reason, the default count is 3, which is a
// balanced value, and also considered lucky in Italy.
//
// And, well... Here's how it actually works:
//
// 1. read from stdin;
// 2. reservoir sample;
// 4. selection to stdout.
//
// Note 2: the selected count can be changed by specifying
// the number after the name, like so:
//
// 'ls | caristo 3'
// -> this randomly picks three files from current dir
//
// What if the specified count is greater than the list
// length?
// -> just err or err+use default? ✗
// -> print entire list ✓
//
// Use-cases seem vast to me, but one is clearly very
// simple, yet intriguing: 'babynames.txt | caristo 1'
//
// A total of 2 additional files is necessary for this
// project, ensuring organization and clarity:
//
// - cart.zig: read from stdin, reservoir sample
// - cli.zig: commands logic
//
// Licensed under the MIT License.
// Copyright (c) 2025 bxavaby
//
// Repo: https://github.com/bxavaby/caristo

const std = @import("std");
const cli = @import("cli.zig");
const cart = @import("cart.zig");

const debug = std.debug;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const options = cli.parseArgs(allocator) catch |err| switch (err) {
        error.InvalidCount => {
            cli.printHelpWithEr("invalid count specified");
            return;
        },
        error.UnknownFlag => {
            cli.printHelpWithEr("unknown flag");
            return;
        },
        else => |e| {
            debug.print("unexpected error: {any}\n", .{e});
            return;
        },
    };

    if (options.help) {
        debug.print("{s}\n{s}\n", .{ cli.LOGO, cli.HELP });
        return;
    }

    if (options.version) {
        debug.print("caristo {s}\n", .{cli.VERSION});
        return;
    }

    const stdin_file = std.fs.File.stdin();
    const is_terminal = std.posix.isatty(stdin_file.handle);

    if (is_terminal and options.count == null) {
        debug.print("{s}\n", .{cli.EXAMPLE});
        return;
    }

    // const count = if (options.count) |c| c else 3;

    // try cart.reservoirSample(allocator, count);
}
