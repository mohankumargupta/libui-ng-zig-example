const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const libui = b.dependency("libui", .{
        .target = target,
        .optimize = optimize,
    });

    // Re-export libui artifact
    b.installArtifact(libui.artifact("ui"));

    const ui_module = b.addModule("ui", .{
        .source_file = .{ .path = "zig-libui-ng/src/ui.zig" },
    });

    // const ui_extras_module = b.addModule("ui-extras", .{
    //     .source_file = .{ .path = "zig-libui-ng/src/extras.zig" },
    //     .dependencies = &.{.{
    //         .name = "ui",
    //         .module = ui_module,
    //     }},
    // });
    // _ = ui_extras_module;

    //const check_step = b.step("check", "Build all examples");

    {
        const exe = b.addExecutable(.{
            .name = "hello",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = optimize,
        });
        exe.addModule("ui", ui_module);
        //exe.addModule("ui-extras", ui_extras_module);
        exe.linkLibrary(libui.artifact("ui"));
        exe.subsystem = std.Target.SubSystem.Windows;

        exe.addWin32ResourceFile(.{
            .file = .{ .path = "src/resources.rc" },
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&exe.step);

        const run_step = b.step("run", "Run the hello example app");
        run_step.dependOn(&run_cmd.step);
    }
}
