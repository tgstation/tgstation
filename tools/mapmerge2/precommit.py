#!/usr/bin/env python3
import os
import sys
import pygit2
from . import dmm
from .mapmerge import merge_map


def main(repo, *, use_workdir=False):
    if repo.index.conflicts:
        print("You need to resolve merge conflicts first.")
        return 1

    try:
        repo.lookup_reference('MERGE_HEAD')
        print("Not running mapmerge for merge commit.")
        return 0
    except KeyError:
        pass

    target_statuses = pygit2.GIT_STATUS_INDEX_MODIFIED | pygit2.GIT_STATUS_INDEX_NEW
    skip_to_file_statuses = pygit2.GIT_STATUS_WT_DELETED | pygit2.GIT_STATUS_WT_MODIFIED
    if use_workdir:
        target_statuses |= pygit2.GIT_STATUS_WT_MODIFIED | pygit2.GIT_STATUS_WT_NEW
        skip_to_file_statuses &= ~pygit2.GIT_STATUS_WT_MODIFIED

    changed = 0
    for path, status in repo.status().items():
        if path.endswith(".dmm") and (status & target_statuses):
            # read the index
            index_entry = repo.index[path]
            if use_workdir:
                index_map = dmm.DMM.from_file(os.path.join(repo.workdir, path))
            else:
                index_map = dmm.DMM.from_bytes(repo[index_entry.id].read_raw())

            try:
                head_blob = repo[repo[repo.head.target].tree[path].id]
            except KeyError:
                # New map, no entry in HEAD
                print(f"Converting new map: {path}", flush=True)
                assert (status & pygit2.GIT_STATUS_INDEX_NEW)
                merged_map = index_map
            else:
                # Entry in HEAD, merge the index over it
                print(f"Converting map: {path}", flush=True)
                assert not (status & pygit2.GIT_STATUS_INDEX_NEW)
                head_map = dmm.DMM.from_bytes(head_blob.read_raw())
                merged_map = merge_map(index_map, head_map)

            # write to the index
            blob_id = repo.create_blob(merged_map.to_bytes())
            repo.index.add(pygit2.IndexEntry(path, blob_id, index_entry.mode))
            changed += 1

            # write to the working directory if that's clean
            if status & skip_to_file_statuses:
                print(f"Warning: {path} has unindexed changes, not overwriting them")
            else:
                merged_map.to_file(os.path.join(repo.workdir, path))

    if changed:
        repo.index.write()
    return 0


if __name__ == '__main__':
    repo = pygit2.Repository(pygit2.discover_repository(os.getcwd()))
    exit(main(repo, use_workdir='--use-workdir' in sys.argv))
