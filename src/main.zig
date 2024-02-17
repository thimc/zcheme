const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() !void {
    const reader = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buffer: [1024]u8 = undefined;
    while (true) {
        try stdout.print("repl> ", .{});
        while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            if (line.len < 1) break;
            var lex = lexer.Lexer.init(line);
            while (!lex.eof()) {
                const token = lex.next();
                std.debug.print("{}\n", .{token});
            }
        }
    }
}
