const std = @import("std");
const ui = @import("ui");

pub fn on_closing(_: *ui.Window, _: ?*void) ui.Window.ClosingAction {
    ui.Quit();
    return .should_close;
}

const Application = struct {
    vbox: *ui.Box = undefined,
    tab: *ui.Tab = undefined,
    form: *ui.Form = undefined,

    const Self = @This();
};

pub fn main() !void {
    var init_data = ui.InitData{
        .options = .{ .Size = 0 },
    };
    ui.Init(&init_data) catch {
        std.debug.print("Error initializing LibUI: {s}\n", .{init_data.get_error()});
        init_data.free_error();
        return;
    };
    defer ui.Uninit();

    const main_window = try ui.Window.New("VSCode Portable Dowloader", 1000, 750, .hide_menubar);
    main_window.SetMargined(true);

    const vbox = try ui.Box.New(.Vertical);
    const tab = try ui.Tab.New();
    const download = try ui.Label.New("Hello world");
    const update = try ui.Label.New("Goodbye world");
    tab.Append("Download", download.as_control());
    tab.Append("Update", update.as_control());
    vbox.Append(tab.as_control(), .stretch);

    const app: Application = .{ .vbox = vbox, .tab = tab };
    _ = app;

    main_window.SetChild(vbox.as_control());
    main_window.as_control().Show();
    main_window.OnClosing(void, on_closing, null);
    ui.Main();
}
