const std = @import("std");
const ui = @import("ui");

pub fn on_closing(_: *ui.Window, _: ?*void) ui.Window.ClosingAction {
    ui.Quit();
    return .should_close;
}

const Application = struct {
    main_window: *ui.Window = undefined,
    label: *ui.Label = undefined,

    //vbox: *ui.Box = undefined,
    //group: *ui.Group = undefined,
    //form: *ui.Form = undefined,

    const Self = @This();
};

pub fn uploadClicked(_: *ui.Button, app: ?*Application) void {
    const result = app.?.main_window.uiOpenFolder();
    const moo: [*:0]const u8 = @ptrCast(@alignCast(result.?));
    app.?.label.SetText(moo);
}

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

    const main_window = try ui.Window.New("VSCode Portable Dowloader", 240, 200, .hide_menubar);
    main_window.SetMargined(true);

    const vbox = try ui.Box.New(.Vertical);
    const group = try ui.Group.New("Download VSCode Portable Edition");
    const form = try ui.Form.New();
    const entry = try ui.Entry.New(.Entry);
    const group2 = try ui.Group.New("Update Existing VSCode");
    const form2 = try ui.Form.New();
    const choosefolder = try ui.Button.New("Choose Folder");
    const downloadButton = try ui.Button.New("Download");
    const label = try ui.Label.New("moo");
    const label2 = try ui.Label.New("boo");
    label2.SetText("pop");

    const vbox2 = try ui.Box.New(.Vertical);
    //group.SetMargined(bool);
    ui.Group.uiGroupSetMargined(group, 1);
    form.Append("VSCode Folder", entry.as_control(), .dont_stretch);
    form.Append("", downloadButton.as_control(), .dont_stretch);
    form.Append("Result:", label.as_control(), .dont_stretch);
    form.SetPadded(true);
    group.SetChild(form.as_control());
    vbox2.Append(group.as_control(), .dont_stretch);
    form2.Append("", choosefolder.as_control(), .dont_stretch);
    form2.SetPadded(true);
    group2.SetChild(form2.as_control());
    vbox2.Append(group2.as_control(), .stretch);

    const vbox3 = try ui.Box.New(.Vertical);
    const grid = try ui.Grid.New();
    const vscodeDownload = try ui.Button.New("Download VSCode");
    const vscodeUpload = try ui.Button.New("Update VSCode");
    var app: Application = .{ .main_window = main_window, .label = label2 };
    vscodeUpload.OnClicked(Application, uploadClicked, &app);
    grid.Append(vscodeDownload.as_control(), 0, 0, 1, 1, 0, .Fill, 0, .Fill);
    grid.Append(vscodeUpload.as_control(), 0, 1, 1, 1, 0, .Fill, 0, .Fill);
    grid.Append(label2.as_control(), 0, 2, 1, 1, 0, .Fill, 0, .Fill);
    //grid.Append()
    grid.SetPadded(true);
    vbox3.Append(grid.as_control(), .stretch);

    vbox.Append(vbox3.as_control(), .stretch);

    main_window.SetChild(vbox.as_control());
    main_window.as_control().Show();
    main_window.OnClosing(void, on_closing, null);
    ui.Main();
}
