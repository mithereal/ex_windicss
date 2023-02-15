defmodule WindicssTest do
  use ExUnit.Case, async: true

  @version Windicss.latest_version()

  setup do
    Application.put_env(:windicss, :version, @version)
    File.mkdir_p!("assets/js")
    File.mkdir_p!("assets/css")
    File.rm("assets/windicss.config.js")
    File.rm("assets/css/app.css")
    :ok
  end

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Windicss.run(:default, ["--help"]) == 0
           end) =~ @version
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Windicss.run(:another, []) == 0
           end) =~ @version
  end

  test "run with pre-existing app.css" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Windicss.run(:default, []) == 0
           end) =~ @version
  end

  test "updates on install" do
    Application.put_env(:windicss, :version, "3.0.3")
    Mix.Task.rerun("windicss.install", ["--if-missing"])

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Windicss.run(:default, ["--help"]) == 0
           end) =~ "3.0.3"

    Application.delete_env(:windicss, :version)

    Mix.Task.rerun("windicss.install", ["--if-missing"])
    assert File.exists?("assets/windicss.config.js")
    assert File.read!("assets/css/app.css") =~ "windicss"

    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Windicss.run(:default, ["--help"]) == 0
           end) =~ @version
  end

  test "install on existing app.css and app.js" do
    File.write!("assets/css/app.css", """
    @import "./phoenix.css";
    body {
    }
    """)

    File.write!("assets/js/app.js", """
    import "../css/app.css"

    let Hooks = {}
    """)

    Mix.Task.rerun("windicss.install")

    expected_css =
      String.trim("""
      @import "windicss/base";
      @import "windicss/components";
      @import "windicss/utilities";

      body {
      }
      """)

    expected_js =
      String.trim("""

      let Hooks = {}
      """)

    assert String.trim(File.read!("assets/css/app.css")) == expected_css
    assert String.trim(File.read!("assets/js/app.js")) == expected_js

    Mix.Task.rerun("windicss.install")

    assert String.trim(File.read!("assets/js/app.js")) == expected_js
  end

  test "installs with custom URL" do
    assert :ok =
             Mix.Task.rerun("windicss.install", [
               "https://github.com/windicss/windicss/releases/download/v$version/windicss-$target"
             ])
  end
end
