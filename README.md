<div align="center">

# 📄 Nouvo

**Le « Clic droit → Nouveau » de Windows, sur macOS.**

![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

</div>

## Features

Clic droit dans n'importe quel dossier du Finder, même vide → **Nouveau** → `.txt` `.docx` `.xlsx` `.csv` `.md` `.rtf` `.json`

- Le fichier est créé puis sélectionné, prêt à être renommé.
- Pas d'overwrite : `Nouveau fichier 2.txt`, `3`…
- Les `.docx` et `.xlsx` sont de vrais documents Office, pas des fichiers de 0 octet.

## Install

Prérequis : macOS 13+ et les Command Line Tools (`xcode-select --install`). Xcode n'est pas nécessaire.

```bash
git clone https://github.com/kuunoh/Nouvo.git && cd Nouvo && ./build.sh
```

> [!TIP]
> Si le menu n'apparaît pas, va dans **Réglages Système → Général → Éléments de connexion et extensions → Extensions du Finder** et active **Nouvo**.

Pour désinstaller : `./uninstall.sh`

## Ajouter un type de fichier

1. Ajoute-le dans `types` ([`FinderSync.swift`](Sources/Extension/FinderSync.swift)) et dans `allowed` ([`main.swift`](Sources/App/main.swift)).
2. *(Optionnel)* Ajoute un template dans `build.sh`.
3. Relance `./build.sh`.

## Under the hood

Une Finder Sync extension (sandboxée) affiche le menu et envoie un `nouvo://create?dir=…&ext=…` à une app helper invisible, qui crée le fichier.

**Security :** les extensions de fichier sont filtrées par une whitelist, le dossier cible doit exister, l'écriture est atomique et sans overwrite, et il n'y a aucun accès réseau.

## License

MIT © [kuunoh](https://github.com/kuunoh)
