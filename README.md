# Windows venv builder

Push a `requirements.txt` and GitHub's Windows VM (which has MSVC preinstalled) builds everything.
Download the result from **Actions → latest run → Artifacts**.

You get two zips:

| Artifact | What it is |
|---|---|
| `wheelhouse-py3.12-win_amd64` | Prebuilt `.whl` files. **Use this one.** |
| `venv-py3.12-win_amd64` | The whole venv folder. Needs a one-line fix after unzipping. |

**Your local Python must match the build version (e.g. 3.12) and be 64-bit.** Change `DEFAULT_PYTHON`
in the workflow, or run it manually from the Actions tab and type a version.

## Option A: wheelhouse (no compiler needed)

```powershell
py -3.12 -m venv venv
.\venv\Scripts\python.exe -m pip install --no-index --find-links .\wheelhouse -r requirements.txt
```

## Option B: the prebuilt venv

A venv stores the absolute path of the Python that made it, which on the runner is `C:\hostedtoolcache\...`.
After unzipping, repoint it at your Python:

```powershell
.\fix-venv.ps1 -Venv .\venv -Python "py -3.12"
.\venv\Scripts\python.exe -c "import numpy; print(numpy.__version__)"
```

`pip.exe` and other `Scripts\*.exe` wrappers keep the old path. Use `python -m pip` instead.
