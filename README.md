# Windows venv builder

Build Python packages for Windows without fighting Visual C++ on your own machine.
You push a `requirements.txt`, and GitHub's Windows VM compiles everything. It has MSVC
preinstalled. Each build is published as a **GitHub Release** with downloadable zips.

## Download the latest build

These links always point to the newest build. No login is needed, and they never expire:

- **Venv:** https://github.com/Kushalr3ddy/windows-venv-builder/releases/latest/download/venv-py3.12-win_amd64.zip
- **Wheels:** https://github.com/Kushalr3ddy/windows-venv-builder/releases/latest/download/wheelhouse-py3.12-win_amd64.zip

There's always one **`latest`** release holding the newest build (that's what the links above point to),
plus the most recent **5 numbered `build-N` releases** on the [Releases page](https://github.com/Kushalr3ddy/windows-venv-builder/releases)
as history. Older numbered builds are pruned automatically. Each release lists the exact packages it contains.

From PowerShell:

```powershell
curl.exe -LO https://github.com/Kushalr3ddy/windows-venv-builder/releases/latest/download/venv-py3.12-win_amd64.zip
```

> The links say `py3.12`. If the latest build used a different Python version, swap the number in the link,
> or pick the zip from the Releases page.

## Start a build

Either of these works:

- **Push a change to `requirements.txt` or `.python-version`.** Editing either on github.com and clicking
  *Commit changes* counts too.
- **Run it by hand:** open the **Actions** tab, pick **Build Windows venv** on the left, click **Run workflow**,
  optionally type a Python version to override just that run, then click **Run workflow** again.

A build takes around 30 seconds to a few minutes. When it finishes, a new release appears and the links above update.

## What's in the two zips?

Both zips contain the same packages, so pick **one**.

| Zip | What it is | When to use it |
|---|---|---|
| `wheelhouse-py3.12-win_amd64.zip` | Every package from `requirements.txt` as a prebuilt `.whl` file | **Recommended.** You make your own venv, and installing takes seconds with no compiler. |
| `venv-py3.12-win_amd64.zip` | The complete, ready-made `venv` folder the build made | When you want the folder itself. Needs one fix command after unzipping (see Option B). |

The `py3.12` is the Python version it was built for. **Your local Python must have the same
major.minor version and be 64-bit**, or compiled packages won't import. To build for a different
version, edit the one line in [`.python-version`](.python-version) (e.g. `3.11`) and push — that
both sets the version and starts a build. A version typed into **Run workflow** overrides the file
for that single run only.

> If `requirements.txt` has no packages, there's nothing to put in the wheelhouse zip, so it's skipped.

### Option A: wheelhouse (recommended)

Unzip it next to your `requirements.txt`. That gives you a `wheelhouse` folder. Then:

```powershell
py -3.12 -m venv venv
.\venv\Scripts\python.exe -m pip install --no-index --find-links .\wheelhouse -r requirements.txt
```

`--no-index` means pip only uses the downloaded wheels. Nothing is fetched or compiled.

### Option B: the prebuilt venv

Unzipping gives you a `venv` folder. A venv stores the full path of the Python that created it,
which on the build machine is something like `C:\hostedtoolcache\windows\Python\3.12.x\x64`. That path
doesn't exist on your PC, so point it at your own Python with the script included in the zip:

```powershell
.\venv\fix-venv.ps1 -Venv .\venv -Python "py -3.12"
.\venv\Scripts\python.exe -c "import sys; print(sys.prefix)"
```

If PowerShell refuses to run the script, run `Unblock-File .\venv\fix-venv.ps1` first,
or use `powershell -ExecutionPolicy Bypass -File .\venv\fix-venv.ps1 -Venv .\venv -Python "py -3.12"`.

After that:

- Run things with `.\venv\Scripts\python.exe`, or activate it with `.\venv\Scripts\Activate.ps1`.
- Use `python -m pip ...`, not `pip.exe`. The `Scripts\*.exe` wrappers (pip.exe and others) still hold the build machine's path.
- `venv\requirements.lock.txt` lists the exact versions that were installed.
