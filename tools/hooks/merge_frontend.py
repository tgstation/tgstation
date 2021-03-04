# merge_frontend.py
import sys
import io
import os
import pygit2
import collections
import typing


ENCODING = 'utf-8'


class MergeReturn(typing.NamedTuple):
    success: bool
    merge_result: typing.Optional[object]


class MergeDriver:
    driver_id: typing.Optional[str] = None

    def pre_announce(self, path: str):
        """
        Called before merge() is called, with a human-friendly path for output.
        """
        print(f"Merging {self.driver_id}: {path}")

    def merge(self, base: typing.BinaryIO, left: typing.BinaryIO, right: typing.BinaryIO) -> MergeReturn:
        """
        Read from three BinaryIOs: base (common ancestor), left (ours), and
        right (theirs). Perform the actual three-way merge operation. Leave
        conflict markers if necessary.

        Return (False, None) to indicate the merge driver totally failed.
        Return (False, merge_result) if the result contains conflict markers.
        Return (True, merge_result) if everything went smoothly.
        """
        raise NotImplementedError

    def to_file(self, output: typing.BinaryIO, merge_result: object):
        """
        Save the merge() result to the given output stream.
        Override this if the merge() result is not bytes or str.
        """
        if isinstance(merge_result, bytes):
            output.write(merge_result)
        elif isinstance(merge_result, str):
            with io.TextIOWrapper(output, ENCODING) as f:
                f.write(merge_result)
        else:
            raise NotImplementedError

    def post_announce(self, success: bool, merge_result: object):
        """
        Called after merge() is called, to warn the user if action is needed.
        """
        if not success:
            print("!!! Manual merge required")
            if merge_result:
                print("    A best-effort merge was performed. You must finish the job yourself.")
            else:
                print("    No merge was possible. You must resolve the conflict yourself.")

    def main(self, args: typing.List[str] = None):
        return _main(self, args or sys.argv[1:])


def _main(driver: MergeDriver, args: typing.List[str]):
    if len(args) > 0 and args[0] == '--posthoc':
        return _posthoc_main(driver, args[1:])
    else:
        return _driver_main(driver, args)


def _driver_main(driver: MergeDriver, args: typing.List[str]):
    """
    Act like a normal Git merge driver, called by Git during a merge.
    """
    if len(args) != 5:
        print("merge driver called with wrong number of arguments")
        print("    usage: %P %O %A %B %L")
        return 1

    path, path_base, path_left, path_right, _ = args
    driver.pre_announce(path)

    with open(path_base, 'rb') as io_base:
        with open(path_left, 'rb') as io_left:
            with open(path_right, 'rb') as io_right:
                success, merge_result = driver.merge(io_base, io_left, io_right)

    if merge_result:
        # If we got anything, write it to the working directory.
        with open(path_left, 'wb') as io_output:
            driver.to_file(io_output, merge_result)

    driver.post_announce(success, merge_result)
    if not success:
        # If we were not successful, do not mark the conflict as resolved.
        return 1


def _posthoc_main(driver: MergeDriver, args: typing.List[str]):
    """
    Apply merge driver logic to a repository which is already in a conflicted
    state, running the driver on any conflicted files.
    """
    repo_dir = pygit2.discover_repository(os.getcwd())
    repo = pygit2.Repository(repo_dir)
    conflicts = repo.index.conflicts
    if not conflicts:
        print("There are no unresolved conflicts.")
        return 0

    all_success = True
    index_changed = False
    any_attempted = False
    for base, left, right in list(conflicts):
        if not base or not left or not right:
            # (not left) or (not right): deleted in one branch, modified in the other.
            # (not base): added differently in both branches.
            # In either case, there's nothing we can do for now.
            continue

        path = left.path
        if not _applies_to(repo, driver, path):
            # Skip the file if it's not the right extension.
            continue

        any_attempted = True
        driver.pre_announce(path)
        io_base = io.BytesIO(repo[base.id].data)
        io_left = io.BytesIO(repo[left.id].data)
        io_right = io.BytesIO(repo[right.id].data)
        success, merge_result = driver.merge(io_base, io_left, io_right)
        if merge_result:
            # If we got anything, write it to the working directory.
            with open(os.path.join(repo.workdir, path), 'wb') as io_output:
                driver.to_file(io_output, merge_result)

            if success:
                # If we were successful, mark the conflict as resolved.
                with open(os.path.join(repo.workdir, path), 'rb') as io_readback:
                    contents = io_readback.read()
                merged_id = repo.create_blob(contents)
                repo.index.add(pygit2.IndexEntry(path, merged_id, left.mode))
                del conflicts[path]
                index_changed = True
        if not success:
            all_success = False
        driver.post_announce(success, merge_result)

    if index_changed:
        repo.index.write()

    if not any_attempted:
        print("There are no unresolved", driver.driver_id, "conflicts.")

    if not all_success:
        # Not usually observed, but indicate the failure just in case.
        return 1


def _applies_to(repo: pygit2.Repository, driver: MergeDriver, path: str):
    """
    Check if the current merge driver is a candidate to handle a given path.
    """
    if not driver.driver_id:
        raise ValueError('Driver must have ID to perform post-hoc merge')
    return repo.get_attr(path, 'merge') == driver.driver_id
