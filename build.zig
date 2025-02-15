const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    const options = b.addOptions();
    options.addOption([]const u8, "parser_tests_path", deps.dirs._jt8JCkXwRTS9);

    const test_step = b.step("test", "Run unit tests");
    {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("src/test_parser.zig"),
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.root_module.addImport("build_options", options.createModule());
        unit_tests.use_llvm = !disable_llvm;
        unit_tests.use_lld = !disable_llvm;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.has_side_effects = true;
        test_step.dependOn(&run_unit_tests.step);
    }
    {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("src/test_parser_pass.zig"),
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.root_module.addImport("build_options", options.createModule());
        unit_tests.use_llvm = !disable_llvm;
        unit_tests.use_lld = !disable_llvm;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.has_side_effects = true;
        test_step.dependOn(&run_unit_tests.step);
    }
    {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("src/test_parser_fail.zig"),
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.root_module.addImport("build_options", options.createModule());
        unit_tests.use_llvm = !disable_llvm;
        unit_tests.use_lld = !disable_llvm;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.has_side_effects = true;
        test_step.dependOn(&run_unit_tests.step);
    }
}
