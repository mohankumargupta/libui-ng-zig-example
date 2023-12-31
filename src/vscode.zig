const std = @import("std");
const ui = @import("ui");

pub const App = struct {
    main_window: *ui.Window,
};

pub fn main() !void {
    var init_options = ui.InitData{ .options = .{ .Size = 0 } };
    ui.Init(&init_options) catch |e| {
        std.debug.print("Error initializing libui: {s}\n", .{init_options.get_error()});
        init_options.free_error();
        return e;
    };
    const window = try ui.Window.New("Hello", 320, 240, .hide_menubar);
    window.SetMargined(true);

    const box = try ui.Box.New(.Vertical);
    box.SetPadded(true);
    window.SetChild(box.as_control());

    const entry = try ui.MultilineEntry.New(.Wrapping);
    entry.SetReadOnly(true);

    var app = App{ .main_window = window };

    const downloadButton = try ui.Button.New("Download");
    downloadButton.OnClicked(App, download, &app);
    const updateButton = try ui.Button.New("Upload");
    updateButton.OnClicked(App, update, &app);
    const hbox = try ui.Box.New(.Horizontal);
    hbox.SetPadded(true);
    hbox.Append(downloadButton.as_control(), .dont_stretch);
    hbox.Append(updateButton.as_control(), .dont_stretch);
    //box.Append(downloadButton.as_control(), .dont_stretch);
    box.Append(hbox.as_control(), .dont_stretch);
    //box.Append(entry.as_control(), .dont_stretch);

    window.OnClosing(void, on_closing, null);

    window.as_control().Show();

    ui.Main();
}

pub fn on_closing(_: *ui.Window, _: ?*void) ui.Window.ClosingAction {
    ui.Quit();
    return .should_close;
}

pub fn download(_: *ui.Button, app_opt: ?*App) void {
    const app = app_opt orelse @panic("Null userdata pointer");
    _ = app;
}

pub fn update(_: *ui.Button, app_opt: ?*App) void {
    const app = app_opt orelse @panic("Null userdata pointer");
    const dir = app.main_window.uiOpenFolder() orelse return;
    ui.FreeText(dir);
}
