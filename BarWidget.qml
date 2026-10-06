import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "xela.x3d-mode"
  readonly property string modePath: "/sys/devices/platform/AMDI0101:00/amd_x3d_mode"
  property string mode: "unknown"
  property bool available: false
  property bool switching: false

  function refresh() { modeFile.reload() }
  function toggleMode() {
    if (switching || mode === "unknown") return
    var nextMode = mode === "cache" ? "frequency" : "cache"
    switching = true
    apply.command = ["pkexec", "sh", "-c", "printf '%s\\n' '" + nextMode + "' > '" + modePath + "'"]
    apply.running = true
  }

  // Hidden entirely on systems without the amd_x3d_mode interface.
  visible: available
  implicitWidth: available ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight

  // Writes to the sysfs attribute raise inotify events, so the file is watched
  // instead of polled.
  FileView {
    id: modeFile
    path: root.modePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var value = String(text() || "").trim()
      root.mode = value === "cache" || value === "frequency" ? value : "unknown"
      root.available = true
    }
    onLoadFailed: function(error) {
      root.mode = "unknown"
      root.available = false
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
  // The driver may load after the bar starts; check again rarely while absent.
  Timer { interval: 60000; running: !root.available; repeat: true; onTriggered: root.refresh() }

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
