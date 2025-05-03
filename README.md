<div align="center">
  <img
    src="app/data/icons/hicolor/scalable/apps/org.altlinux.Foldy.svg"
    height="128"
  />
</div>

<div align="center">
  <h1>Folder Manager (aka Foldy)</h1>
</div>

<div align="center"><h3>Application for folders settings.</h4></div>

<div align="center">
  <img 
    src="app/data/images/2-folder.png"
	alt="Folder"
    height="500"
  />
</div>


### Build from sources
> [!NOTE]
> You need clone recursively.

#### Install dependencies:
> [!NOTE]
> This script works only with ALT Linux.
```
python3 build-tools/install_meson_deps.py
```

#### Install:
```
meson setup _build
meson install -C _build
```
