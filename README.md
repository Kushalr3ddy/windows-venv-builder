# Windows venv builder

Build Python packages for Windows without fighting Visual C++ on your own machine.
You push a `requirements.txt`, and GitHub's Windows VM compiles everything. It has MSVC
preinstalled. You then download the result as a zip.

## 1. Start a build

Either of these works:

- **Push a change to `requirements.txt`.** Editing it on github.com and clicking *Commit changes* counts too.
- **Run it by hand:** open the **Actions** tab, pick **Build Windows venv** on the left, click **Run workflow**,
  optionally type a Python version (e.g. `3.11`), then click **Run workflow** again.

A build takes around 30 seconds to a few minutes, depending on what it has to compile.

## 2. Download the result

**In the browser:**

1. Open the repo's **Actions** tab.
2. Click the latest **Build Windows venv** run. A green ✓ means it worked.
3. Scroll down to the **Artifacts** section at the bottom of the run's summary page.
4. Click an artifact's name to download it as a `.zip`.

You must be logged in to GitHub to download. Artifacts are deleted after **30 days**. To change
that, edit `retention-days` in the workflow.

**From the command line** (with the [GitHub CLI](https://cli.github.com/)), inside a clone of this repo:

```powershell
gh run download -n venv-py3.12-win_amd64 -D venv          # the built venv
gh run download -n wheelhouse-py3.12-win_amd64 -D wheelhouse   # the wheels
```

This grabs that artifact from the most recent run that produced it and unzips it for you.
To pick a specific run, pass its ID first, e.g. `gh run download 45125047457 -n ...`. `gh run list` shows the IDs.

## 3. What's in the two zips?

Each build uploads two artifacts. Pick **one** of them.

| Artifact | What it is | When to use it |
|---|---|---|
| `wheelhouse-py3.12-win_amd64` | Every package from `requirements.txt` as a prebuilt `.whl` file | **Recommended.** You make your own venv, and installing takes seconds with no compiler. |
| `venv-py3.12-win_amd64` | The complete, ready-made `venv` folder the runner built | When you want the folder itself. Needs one fix command after unzipping (see Option B). |

The `py3.12` in the name is the Python version it was built for. **Your local Python must have the
same major.minor version and be 64-bit**, or compiled packages won't import. To build for a different
version, change `DEFAULT_PYTHON` at the top of `.github/workflows/build-venv.yml`, or type the version
when you click **Run workflow**.

> If `requirements.txt` has no packages, the wheelhouse is empty and that zip is skipped.

### Option A: wheelhouse (recommended)

Unzip it into a folder called `wheelhouse` next to your `requirements.txt`, then:

```powershell
py -3.12 -m venv venv
.\venv\Scripts\python.exe -m pip install --no-index --find-links .\wheelhouse -r requirements.txt
```

`--no-index` means pip only uses the downloaded wheels. Nothing is fetched or compiled.

### Option B: the prebuilt venv

A venv stores the full path of the Python that created it, which on the runner is something like
`C:\hostedtoolcache\windows\Python\3.12.x\x64`. That path doesn't exist on your PC, so after unzipping
into a `venv` folder, point it at your own Python:

```powershell
.\fix-venv.ps1 -Venv .\venv -Python "py -3.12"
.\venv\Scripts\python.exe -c "import sys; print(sys.prefix)"
```

After that:

- Run things with `.\venv\Scripts\python.exe`, or activate it with `.\venv\Scripts\Activate.ps1`.
- Use `python -m pip ...`, not `pip.exe`. The `Scripts\*.exe` wrappers (pip.exe and others) still hold the runner's path.
- `venv\requirements.lock.txt` lists the exact versions that were installed.
