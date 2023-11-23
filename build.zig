const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const strip = b.option(bool, "strip", "Strip debug symbols") orelse false;
    const pie = b.option(bool, "pie", "Build a position independent executable.") orelse false;

    const test_step = b.step("test", "Run unit tests");
    {
        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = "src/test_parser.zig" },
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.strip = strip;
        unit_tests.pie = pie;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
    {
        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = "src/test_parser_pass.zig" },
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.strip = strip;
        unit_tests.pie = pie;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
    {
        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = "src/test_parser_fail.zig" },
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.strip = strip;
        unit_tests.pie = pie;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
}
