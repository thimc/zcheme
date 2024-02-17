const std = @import("std");

pub const Lexer = struct {
    source: []const u8,
    position: u8 = 0,
    read_position: u8 = 0,
    token: u8 = 0,

    const TokenType = enum { Syntax, Number, Identifier };
    const Token = struct {
        value: []const u8,
        kind: TokenType,
    };

    pub fn init(source: []const u8) Lexer {
        var lexer = Lexer{
            .source = source,
            .position = 0,
            .read_position = 0,
            .token = source[0],
        };
        lexer.read();
        return lexer;
    }
    pub fn eof(self: *Lexer) bool {
        return self.token == 0;
    }
    pub fn next(self: *Lexer) !Lexer.Token {
        while (std.ascii.isWhitespace(self.token)) {
            self.read();
        }
        const start = self.position;
        const tok: Lexer.Token = switch (self.token) {
            '(', ')' => {
                self.read();
                return .{
                    .value = self.source[start..self.position],
                    .kind = TokenType.Syntax,
                };
            },
            '0'...'9' => {
                while (std.ascii.isDigit(self.peek())) {
                    self.read();
                }
                return .{
                    .value = self.source[start..self.position],
                    .kind = TokenType.Number,
                };
            },
            else => {
                while (!std.ascii.isWhitespace(self.peek()) and self.peek() != ')' and self.peek() != 0) {
                    self.read();
                }
                return .{
                    .value = self.source[start..self.position],
                    .kind = TokenType.Identifier,
                };
            },
        };
        self.read();
        return tok;
    }

    fn peek(self: *Lexer) u8 {
        if (self.position >= self.source.len) return 0;
        return self.source[self.position];
    }
    fn read(self: *Lexer) void {
        if (self.read_position >= self.source.len) {
            self.token = 0;
        } else {
            self.token = self.source[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }
};

test "lex" {
    const source =
        \\(
        \\
        \\+
        \\
        \\21
        \\
        \\4
        \\
        \\)
    ;
    const expected = [_]Lexer.Token{
        .{ .kind = .Syntax, .value = "(" },
        .{ .kind = .Ident, .value = "+" },
        .{ .kind = .Number, .value = "21" },
        .{ .kind = .Number, .value = "4" },
        .{ .kind = .Syntax, .value = ")" },
    };

    var lexer = Lexer.init(source);
    for (expected) |token| {
        const tok = try lexer.next();
        try std.testing.expectEqualDeep(token, tok);
    }
}
