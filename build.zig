const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

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

    const lib = b.addStaticLibrary(.{
        .name = "libui-ng-zig-example",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "libui-ng-zig-example",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("ui", ui_module);
    //exe.addModule("ui-extras", ui_extras_module);
    exe.linkLibrary(libui.artifact("ui"));
    //This is giving problem
    //exe.subsystem = std.Target.SubSystem.Windows;
    exe.addWin32ResourceFile(.{
        .file = .{ .path = "zig-libui-ng/examples/resources.rc" },
        .flags = &.{ "/d", "_UI_STATIC" },
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
