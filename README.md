<div align="center">

# 📄 Nouvo

**Windows' "Right-click → New", on macOS.**

![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

</div>

## Features

Right-click in any Finder folder, even an empty one → **Nouveau** → `.txt` `.docx` `.xlsx` `.csv` `.md` `.rtf` `.json`

- The file is created and selected, ready to rename.
- No overwrite: `Nouveau fichier 2.txt`, `3`…
- `.docx` and `.xlsx` are real Office documents, not 0-byte files.

> The UI is in French ("Nouveau" = "New").

## Install

Requirements: macOS 13+ and the Command Line Tools (`xcode-select --install`). No Xcode needed.

```bash
git clone https://github.com/kuunoh/Nouvo.git && cd Nouvo && ./build.sh
```

> [!TIP]
> Menu not showing? Go to **System Settings → General → Login Items & Extensions → Finder Extensions** and enable **Nouvo**.

To uninstall: `./uninstall.sh`

## Add a file type

1. Add it to `types` ([`FinderSync.swift`](Sources/Extension/FinderSync.swift)) and `allowed` ([`main.swift`](Sources/App/main.swift)).
2. *(Optional)* Add a template in `build.sh`.
3. Run `./build.sh` again.

## Under the hood

A sandboxed Finder Sync extension shows the menu and sends `nouvo://create?dir=…&ext=…` to a hidden helper app, which creates the file.

**Security:** file extensions are whitelisted, the target folder must exist, writes are atomic with no overwrite, and there's no network access.

## License

MIT © [kuunoh](https://github.com/kuunoh)
