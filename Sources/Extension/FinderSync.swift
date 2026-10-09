import Cocoa
import FinderSync
import UniformTypeIdentifiers

// File types shown in the "New" menu. To add one, add it here AND to `allowed` (Sources/App/main.swift),
// translate its title in Support/Localization/*.lproj, and optionally add a Templates/template.<ext>.
private let types = [("Text document", "txt"), ("Word document", "docx"), ("Excel workbook", "xlsx"),
                     ("CSV file", "csv"), ("Markdown", "md"), ("Rich text", "rtf"), ("JSON", "json")]
private func L(_ key: String) -> String { NSLocalizedString(key, comment: "") }

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/"), URL(fileURLWithPath: "/Volumes")]
    }

    override func menu(for kind: FIMenuKind) -> NSMenu? {
        guard kind == .contextualMenuForContainer || kind == .contextualMenuForItems else { return nil }
        let sub = NSMenu()
        for (i, (title, ext)) in types.enumerated() {
            let item = sub.addItem(withTitle: "\(L(title)) (.\(ext))", action: #selector(create(_:)), keyEquivalent: "")
            item.tag = i // Finder copies the menu: only the tag survives
            item.image = UTType(filenameExtension: ext).map { NSWorkspace.shared.icon(for: $0) }
            item.image?.size = NSSize(width: 16, height: 16)
        }
        let menu = NSMenu()
        let root = menu.addItem(withTitle: L("New"), action: nil, keyEquivalent: "")
        root.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        root.submenu = sub
        return menu
    }

    @objc func create(_ sender: NSMenuItem) {
        let c = FIFinderSyncController.default()
        // Right-click on a single folder -> inside it; otherwise in the current folder.
        let sel = c.selectedItemURLs() ?? []
        guard types.indices.contains(sender.tag),
              let dir = sel.count == 1 && sel[0].hasDirectoryPath ? sel[0] : c.targetedURL() else { return }
        // The extension is sandboxed: writing is delegated to the host app via its URL scheme.
        var u = URLComponents(string: "nouvo://create")!
        u.queryItems = [.init(name: "dir", value: dir.path), .init(name: "ext", value: types[sender.tag].1)]
        u.url.map { _ = NSWorkspace.shared.open($0) }
    }
}
