<div align="center">

# 📄 Nouvo

**Le « Clic droit → Nouveau » de Windows, sur macOS.**

Crée un fichier vide en un clic droit dans n'importe quel dossier du Finder, même un dossier vide.

![macOS](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)
![No Xcode](https://img.shields.io/badge/Xcode-pas%20requis-success)

</div>

---

## ✨ Ce que ça fait

```
Clic droit dans un dossier
└── Nouveau ▸
    ├── 📝 Document texte (.txt)
    ├── 📘 Document Word  (.docx)
    ├── 📗 Classeur Excel (.xlsx)
    ├── 📊 Fichier CSV    (.csv)
    ├── Ⓜ️ Markdown       (.md)
    ├── 🖋️ Texte enrichi  (.rtf)
    └── { } JSON          (.json)
```

- Le fichier est créé sous le nom **`Nouveau fichier.ext`**, puis sélectionné dans le Finder. Il ne reste qu'à le renommer.
- Le nom ne remplace jamais un fichier existant : on passe à `Nouveau fichier 2.ext`, `Nouveau fichier 3.ext`…
- Si tu fais un clic droit **sur** un dossier, le fichier est créé **dedans**.
- Les `.docx` et `.xlsx` sont de vrais documents Office valides, qui s'ouvrent directement dans Word ou Excel. Ce ne sont pas des fichiers de 0 octet.

## 📦 Installation

**Prérequis :** macOS 13 ou plus, avec les *Command Line Tools*. Xcode n'est pas nécessaire.

```bash
xcode-select --install
```

```bash
git clone https://github.com/kuunoh/Nouvo.git
```

```bash
cd Nouvo && ./build.sh
```

Le script compile l'app, l'installe dans `~/Applications/Nouvo.app`, active l'extension Finder et redémarre le Finder. C'est tout. 🎉

> [!TIP]
> Si le menu **Nouveau** n'apparaît pas, ouvre **Réglages Système → Général → Éléments de connexion et extensions → Extensions du Finder**, puis active **Nouvo**.

## 🗑️ Désinstallation

```bash
./uninstall.sh
```

## ➕ Ajouter un type de fichier

1. Ajoute l'entrée dans `types` ([`Sources/Extension/FinderSync.swift`](Sources/Extension/FinderSync.swift)).
2. Ajoute l'extension dans `allowed` ([`Sources/App/main.swift`](Sources/App/main.swift)).
3. *(Facultatif)* Si le fichier ne doit pas être vide, génère un modèle `Templates/template.<ext>` dans `build.sh`.
4. Relance `./build.sh`.

## 🛠️ Comment ça marche

```
┌──────────── Finder ────────────┐   nouvo://create?dir=…&ext=…   ┌──────── Nouvo.app ────────┐
│ NouvoExtension.appex         │ ───────────────────────────────▶ │ crée le fichier depuis le   │
│ (Finder Sync, sandboxée)       │                                  │ modèle, puis le sélectionne │
│ → affiche le menu « Nouveau »  │                                  │ et quitte                   │
└────────────────────────────────┘                                  └─────────────────────────────┘
```

Une extension Finder Sync est obligatoirement *sandboxée* : elle n'a pas le droit d'écrire dans tes dossiers. Elle passe donc la demande à une petite app hôte invisible, via un URL scheme.

**Sécurité**

- L'app hôte n'accepte que les extensions de sa **liste blanche**.
- Elle vérifie que la cible est bien un **dossier existant**.
- Elle écrit de façon atomique sans **jamais écraser** un fichier existant.
- Elle n'a aucun accès réseau.

## 📁 Structure

```
Nouvo/
├── Sources/
│   ├── App/main.swift              # app hôte (création des fichiers)
│   └── Extension/FinderSync.swift  # menu contextuel du Finder
├── Support/                        # Info.plist + entitlements
├── build.sh                        # build + install + activation
└── uninstall.sh
```

## 📄 Licence

MIT © [kuunoh](https://github.com/kuunoh)
