#!/usr/bin/env python3
# hooks/install.py
#
# This script is configured by adding `*.hook` and `*.merge` files in the same
# directory. Such files should be `#!/bin/sh` scripts, usually invoking Python.
# This installer will have to be re-run any time a hook or merge file is added
# or removed, but not when they are changed.
#
# Merge drivers will also need a corresponding entry in the `.gitattributes`
# file.

import os
import stat
import glob
import re
import pygit2
import shlex


def write_hook(fname, command):
    with open(fname, 'w', encoding='utf-8', newline='\n') as f:
        print("#!/bin/sh", file=f)
        print("exec", command, file=f)

    # chmod +x
    st = os.stat(fname)
    if not hasattr(st, 'st_file_attributes'):
        os.chmod(fname, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def _find_stuff(target=None):
    repo_dir = pygit2.discover_repository(target or os.getcwd())
    repo = pygit2.Repository(repo_dir)
    # Strips any active worktree to find the hooks directory.
    root_repo_dir = re.sub(r'/.git/worktrees/[^/]+/', '/.git/', repo_dir)
    hooks_dir = os.path.join(root_repo_dir, 'hooks')
    return repo, hooks_dir


def uninstall(target=None, keep=()):
    repo, hooks_dir = _find_stuff(target)

    # Remove hooks
    for fname in glob.glob(os.path.join(hooks_dir, '*')):
        _, shortname = os.path.split(fname)
        if not fname.endswith('.sample') and f"{shortname}.hook" not in keep:
            print('Removing hook:', shortname)
            os.unlink(fname)

    # Remove merge driver configuration
    for entry in repo.config:
        if entry.level != pygit2.GIT_CONFIG_LEVEL_LOCAL:
            continue
        match = re.match(r'^merge\.([^.]+)\.driver$', entry.name)
        if match and f"{match.group(1)}.merge" not in keep:
            print('Removing merge driver:', match.group(1))
            del repo.config[entry.name]


def install(target=None):
    repo, hooks_dir = _find_stuff(target)
    tools_hooks = os.path.split(__file__)[0]

    keep = set()
    for full_path in glob.glob(os.path.join(tools_hooks, '*.hook')):
        _, fname = os.path.split(full_path)
        name, _ = os.path.splitext(fname)
        print('Installing hook:', name)
        keep.add(fname)
        relative_path = shlex.quote(os.path.relpath(full_path, repo.workdir).replace('\\', '/'))
        write_hook(os.path.join(hooks_dir, name), f'{relative_path} "$@"')

    # Use libgit2 config manipulation to set the merge driver config.
    for full_path in glob.glob(os.path.join(tools_hooks, '*.merge')):
        # Merge drivers are documented here: https://git-scm.com/docs/gitattributes
        _, fname = os.path.split(full_path)
        name, _ = os.path.splitext(fname)
        print('Installing merge driver:', name)
        keep.add(fname)
        # %P: "real" path of the file, should not usually be read or modified
        # %O: ancestor's version
        # %A: current version, and also the output path
        # %B: other branches' version
        # %L: conflict marker size
        relative_path = shlex.quote(os.path.relpath(full_path, repo.workdir).replace('\\', '/'))
        repo.config[f"merge.{name}.driver"] = f'{relative_path} %P %O %A %B %L'

    uninstall(target, keep=keep)


def main(argv):
    if len(argv) <= 1:
        return install()
    elif argv[1] == '--uninstall':
        return uninstall()
    else:
        print("Usage: python -m hooks.install [--uninstall]")
        return 1


if __name__ == '__main__':
    import sys
    exit(main(sys.argv))
