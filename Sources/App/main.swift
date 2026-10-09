import Cocoa

// Hidden host app: receives nouvo://create?dir=…&ext=… from the Finder extension,
// creates the file, then selects it in Finder.

// Whitelist: any app can open a nouvo:// URL, so only these extensions are accepted.
private let allowed: Set = ["txt", "docx", "xlsx", "csv", "md", "rtf", "json"]
private func L(_ key: String) -> String { NSLocalizedString(key, comment: "") }

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var viaURL = false

    func applicationWillFinishLaunching(_: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(open(_:reply:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationDidFinishLaunching(_: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !self.viaURL else { return } // launched manually: show quick help
            NSApp.activate(ignoringOtherApps: true)
            self.alert(L("Nouvo is installed"), L("Help"))
            NSApp.terminate(nil)
        }
    }

    @objc private func open(_ event: NSAppleEventDescriptor, reply _: NSAppleEventDescriptor) {
        viaURL = true
        defer { DispatchQueue.main.asyncAfter(deadline: .now() + 2) { NSApp.terminate(nil) } }
        let q = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue
            .flatMap(URLComponents.init(string:)).flatMap { $0.host == "create" ? $0.queryItems : nil } ?? []
        var isDir: ObjCBool = false
        guard let dir = q.first(where: { $0.name == "dir" })?.value,
              let ext = q.first(where: { $0.name == "ext" })?.value, allowed.contains(ext),
              FileManager.default.fileExists(atPath: dir, isDirectory: &isDir), isDir.boolValue else { return }
        do {
            NSWorkspace.shared.activateFileViewerSelecting([try create(in: URL(fileURLWithPath: dir), ext: ext)])
        } catch {
            NSApp.activate(ignoringOtherApps: true)
            alert(L("Couldn't create the file"), error.localizedDescription)
        }
    }

    private func create(in dir: URL, ext: String) throws -> URL {
        let data = try Bundle.main.url(forResource: "template", withExtension: ext, subdirectory: "Templates")
            .map { try Data(contentsOf: $0) } ?? Data()
        for n in 1... {
            let url = dir.appendingPathComponent("\(L("New file"))\(n > 1 ? " \(n)" : "").\(ext)")
            do { try data.write(to: url, options: .withoutOverwriting); return url } // atomic, never overwrites
            catch CocoaError.fileWriteFileExists {}
        }
        fatalError()
    }

    private func alert(_ title: String, _ text: String) {
        let a = NSAlert()
        (a.messageText, a.informativeText) = (title, text)
        a.runModal()
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.run()
