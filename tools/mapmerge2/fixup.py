#!/usr/bin/env python3
import os
import pygit2
from . import dmm
from .mapmerge import merge_map


STATUS_INDEX = (pygit2.GIT_STATUS_INDEX_NEW
    | pygit2.GIT_STATUS_INDEX_MODIFIED
    | pygit2.GIT_STATUS_INDEX_DELETED
    | pygit2.GIT_STATUS_INDEX_RENAMED
    | pygit2.GIT_STATUS_INDEX_TYPECHANGE
)
STATUS_WT = (pygit2.GIT_STATUS_WT_NEW
    | pygit2.GIT_STATUS_WT_MODIFIED
    | pygit2.GIT_STATUS_WT_DELETED
    | pygit2.GIT_STATUS_WT_RENAMED
    | pygit2.GIT_STATUS_WT_TYPECHANGE
)
ABBREV_LEN = 12
TGM_HEADER = dmm.TGM_HEADER.encode(dmm.ENCODING)


def walk_tree(tree, *, _prefix=''):
    for child in tree:
        if isinstance(child, pygit2.Tree):
            yield from walk_tree(child, _prefix=f'{_prefix}{child.name}/')
        else:
            yield f'{_prefix}{child.name}', child


def insert_into_tree(repo, tree_builder, path, blob_oid):
    try:
        first, rest = path.split('/', 1)
    except ValueError:
        tree_builder.insert(path, blob_oid, pygit2.GIT_FILEMODE_BLOB)
    else:
        inner = repo.TreeBuilder(tree_builder.get(first))
        insert_into_tree(repo, inner, rest, blob_oid)
        tree_builder.insert(first, inner.write(), pygit2.GIT_FILEMODE_TREE)


def main(repo):
    if repo.index.conflicts:
        print("You need to resolve merge conflicts first.")
        return 1

    # Ensure the index is clean.
    for path, status in repo.status().items():
        if status & pygit2.GIT_STATUS_IGNORED:
            continue
        if status & STATUS_INDEX:
            print("You have changes staged for commit. Commit them or unstage them first.")
            print("If you are about to commit maps for the first time, run `Run Before Committing.bat`.")
            return 1
        if path.endswith(".dmm") and (status & STATUS_WT):
            print("You have modified maps. Commit them first.")
            print("If you are about to commit maps for the first time, run `Run Before Committing.bat`.")
            return 1

    # Read the HEAD commit.
    head_commit = repo[repo.head.target]
    head_files = {}
    for path, blob in walk_tree(head_commit.tree):
        if path.endswith(".dmm"):
            data = blob.read_raw()
            if not data.startswith(TGM_HEADER):
                head_files[path] = dmm.DMM.from_bytes(data)

    if not head_files:
        print("All committed maps appear to be in the correct format.")
        print("If you are about to commit maps for the first time, run `Run Before Committing.bat`.")
        return 1

    # Work backwards to find a base for each map, converting as found.
    converted = {}
    if len(head_commit.parents) != 1:
        print("Unable to automatically fix anything because HEAD is a merge commit.")
        return 1
    commit_message_lines = []
    working_commit = head_commit.parents[0]
    while len(converted) < len(head_files):
        for path in head_files.keys() - converted.keys():
            try:
                blob = working_commit.tree[path]
            except KeyError:
                commit_message_lines.append(f"{'new':{ABBREV_LEN}}: {path}")
                print(f"Converting new map: {path}")
                converted[path] = head_files[path]
            else:
                data = blob.read_raw()
                if data.startswith(TGM_HEADER):
                    str_id = str(working_commit.id)[:ABBREV_LEN]
                    commit_message_lines.append(f"{str_id}: {path}")
                    print(f"Converting map: {path}")
                    converted[path] = merge_map(head_files[path], dmm.DMM.from_bytes(data))
        if len(working_commit.parents) != 1:
            print("A merge commit was encountered before good versions of these maps were found:")
            print("\n".join(f"    {x}" for x in head_files.keys() - converted.keys()))
            return 1
        working_commit = working_commit.parents[0]

    # Okay, do the actual work.
    tree_builder = repo.TreeBuilder(head_commit.tree)
    for path, merged_map in converted.items():
        blob_oid = repo.create_blob(merged_map.to_bytes())
        insert_into_tree(repo, tree_builder, path, blob_oid)
        repo.index.add(pygit2.IndexEntry(path, blob_oid, repo.index[path].mode))
        merged_map.to_file(os.path.join(repo.workdir, path))

    # Save the index.
    repo.index.write()

    # Commit the index to the current branch.
    signature = pygit2.Signature(repo.config['user.name'], repo.config['user.email'])
    joined = "\n".join(commit_message_lines)
    repo.create_commit(
        repo.head.name,
        signature,  # author
        signature,  # committer
        f'Convert maps to TGM\n\n{joined}\n\nAutomatically commited by: {os.path.relpath(__file__, repo.workdir)}',
        tree_builder.write(),
        [head_commit.id],
    )

    # Success.
    print("Successfully committed a fixup. Push as needed.")
    return 0


if __name__ == '__main__':
    exit(main(pygit2.Repository(pygit2.discover_repository(os.getcwd()))))
