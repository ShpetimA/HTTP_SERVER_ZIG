const std = @import("std");
const SocketConf = @import("config.zig");
const stdout = std.io.getStdOut().writer();
const Request = @import("request.zig");
const Response = @import("response.zig");
const Method = Request.Method;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Address: {any}", .{socket._address});

    var server = try socket._address.listen(.{});
    const connection = try server.accept();
    var buffer: [1000]u8 = undefined;

    for (buffer, 0..) |_, i| {
        buffer[i] = 0;
    }

    try Request.read_request(connection, buffer[0..buffer.len]);

    const request = Request.parse_request(buffer[0..buffer.len]);

     if (request.method == Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try Response.send_200(connection);
        } else {
            try Response.send_404(connection);
        }
    }
}
