const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const enable_logging = b.option(bool, "log", "Whether to enable logging") orelse false;
    const yaml_module = b.addModule("yaml", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const yaml_tests = b.addTest(.{
        .root_module = yaml_module,
    });

    const cli = b.addModule("cli", .{
        .root_source_file = b.path("examples/yaml.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const example = b.addExecutable(.{
        .name = "yaml",
        .root_module = cli,
    });
    example.root_module.addImport("yaml", yaml_module);

    const example_opts = b.addOptions();
    example.root_module.addOptions("build_options", example_opts);
    example_opts.addOption(bool, "enable_logging", enable_logging);

    b.installArtifact(example);

    const run_cmd = b.addRunArtifact(example);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run example program parser");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(yaml_tests).step);

    const e2e_tests_module = b.addModule("test", .{
        .root_source_file = b.path("test/test.zig"),
        .target = target,
        .optimize = optimize,
    });
    var e2e_tests = b.addTest(.{
        .root_module = e2e_tests_module,
    });
    e2e_tests.root_module.addImport("yaml", yaml_module);
    test_step.dependOn(&b.addRunArtifact(e2e_tests).step);

    const enable_spec_tests = b.option(bool, "enable-spec-tests", "Enable YAML Test Suite") orelse false;
    if (enable_spec_tests) {
        const yaml_test_suite_module = b.addModule("yaml-test-suite", .{
            .root_source_file = b.path("test/yaml_test_suite.zig"),
            .target = target,
            .optimize = optimize,
        });
        var yaml_test_suite = b.addTest(.{
            .root_module = yaml_test_suite_module,
        });
        yaml_test_suite.root_module.addImport("yaml", yaml_module);
        test_step.dependOn(&b.addRunArtifact(yaml_test_suite).step);

        const cwd = std.Io.Dir.cwd();
        cwd.access(b.graph.io, "test/yaml-test-suite/tags", .{}) catch {
            test_step.dependOn(
                &b.addFail("Testfiles not found, make sure you have loaded the submodule.").step,
            );
        };
        if (b.graph.host.result.os.tag == .windows) {
            test_step.dependOn(
                &b.addFail("Windows does not support symlinks in git properly, can't run testsuite.").step,
            );
        }
    }
}
