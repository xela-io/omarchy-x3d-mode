import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "xela.x3d-mode"
  readonly property string modePath: "/sys/devices/platform/AMDI0101:00/amd_x3d_mode"
  property string mode: "unknown"
  property bool switching: false

  function refresh() { if (!probe.running) probe.running = true }
  function toggleMode() {
    if (switching || mode === "unknown") return
    var nextMode = mode === "cache" ? "frequency" : "cache"
    switching = true
    apply.command = ["pkexec", "sh", "-c", "printf '%s\\n' '" + nextMode + "' > '" + modePath + "'"]
    apply.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: probe
    command: ["cat", root.modePath]
    stdout: StdioCollector { id: probeOutput; waitForEnd: true }
    onExited: function(exitCode) {
      var value = String(probeOutput.text || "").trim()
      root.mode = exitCode === 0 && (value === "cache" || value === "frequency") ? value : "unknown"
    }
  }
  Process {
    id: apply
    onExited: function(exitCode) {
      root.switching = false
      root.refresh()
      if (exitCode !== 0 && root.bar)
        root.bar.run("omarchy-notification-send 'X3D-Modus konnte nicht geändert werden'")
    }
  }
  Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.switching ? "…" : (root.mode === "cache" ? "3D" : (root.mode === "frequency" ? "GHz" : "?"))
    horizontalMargin: 7.5
    tooltipText: root.mode === "cache"
      ? "X3D: Cache-CCD bevorzugt — klicken für Frequenz-CCD"
      : (root.mode === "frequency" ? "X3D: Frequenz-CCD bevorzugt — klicken für Cache-CCD" : "X3D-Modus nicht verfügbar")
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.toggleMode()
      else root.refresh()
    }
  }
}
