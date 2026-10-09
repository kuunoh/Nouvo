import Cocoa
import FinderSync
import UniformTypeIdentifiers

// Types proposés dans le menu « Nouveau ». Pour en ajouter un, ajoute-le ici ET dans
// `allowed` (Sources/App/main.swift), avec au besoin un modèle Templates/template.<ext>.
private let types = [("Document texte", "txt"), ("Document Word", "docx"), ("Classeur Excel", "xlsx"),
                     ("Fichier CSV", "csv"), ("Markdown", "md"), ("Texte enrichi", "rtf"), ("JSON", "json")]

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
            let item = sub.addItem(withTitle: "\(title) (.\(ext))", action: #selector(create(_:)), keyEquivalent: "")
            item.tag = i // Finder recopie le menu : seul le tag survit
            item.image = UTType(filenameExtension: ext).map { NSWorkspace.shared.icon(for: $0) }
            item.image?.size = NSSize(width: 16, height: 16)
        }
        let menu = NSMenu()
        let root = menu.addItem(withTitle: "Nouveau", action: nil, keyEquivalent: "")
        root.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        root.submenu = sub
        return menu
    }

    @objc func create(_ sender: NSMenuItem) {
        let c = FIFinderSyncController.default()
        // Clic droit sur un seul dossier -> dedans ; sinon dans le dossier affiché.
        let sel = c.selectedItemURLs() ?? []
        guard types.indices.contains(sender.tag),
              let dir = sel.count == 1 && sel[0].hasDirectoryPath ? sel[0] : c.targetedURL() else { return }
        // Extension sandboxée : l'écriture est déléguée à l'app hôte via son URL scheme.
        var u = URLComponents(string: "nouvo://create")!
        u.queryItems = [.init(name: "dir", value: dir.path), .init(name: "ext", value: types[sender.tag].1)]
        u.url.map { _ = NSWorkspace.shared.open($0) }
    }
}
