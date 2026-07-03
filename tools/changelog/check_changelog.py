"""
DO NOT MANUALLY RUN THIS SCRIPT.
---------------------------------

Expected environmental variables:
-----------------------------------
GITHUB_REPOSITORY: Github action variable representing the active repo (Action provided)
GITHUB_TOKEN: A repository account token, this will allow the action to push the changes (Action provided)
GITHUB_EVENT_PATH: path to JSON file containing the event info (Action provided)
"""
import os
from pathlib import Path
from ruamel.yaml import YAML
from github import Github
import json

import changelog_utils

# Blessed is the GoOnStAtIoN birb ZeWaKa for thinking of this first
repo = os.getenv("GITHUB_REPOSITORY")
token = os.getenv("GITHUB_TOKEN")
event_path = os.getenv("GITHUB_EVENT_PATH")

with open(event_path, 'r') as f:
    event_data = json.load(f)

git = Github(token)
repo = git.get_repo(repo)
pr = repo.get_pull(event_data['number'])

pr_body = pr.body or ""
pr_author = pr.user.login
pr_labels = pr.labels

pr_is_mirror = pr.title.startswith("[MIRROR]")

has_valid_label = False
has_invalid_label = False
cl_required = True
for label in pr_labels:
    print("Found label: ", label.name)
    if label.name == changelog_utils.CL_NOT_NEEDED:
        print("No CL needed!")
        cl_required = False
    if label.name == changelog_utils.CL_VALID:
        has_valid_label = True
    if label.name == changelog_utils.CL_INVALID:
        has_invalid_label = True

if pr_is_mirror:
    cl_required = False

if not cl_required:
    # remove invalid, remove valid
    if has_invalid_label:
        pr.remove_from_labels(changelog_utils.CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(changelog_utils.CL_VALID)
    exit(0)

try:
    with open(Path.cwd().joinpath("tags.yml")) as file:
        yaml = YAML(typ = 'safe', pure = True)
        tags_config = yaml.load(file)
    cl = changelog_utils.build_changelog(pr, tags_config)
    cl_emoji = changelog_utils.emojify_changelog(cl)
    cl_emoji["author"] = cl_emoji["author"] or pr_author
    changelog_utils.validate_changelog(cl_emoji)
except Exception as e:
    print("Changelog parsing error:")
    print(e)

    # add invalid, remove valid
    if not has_invalid_label:
        pr.add_to_labels(changelog_utils.CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(changelog_utils.CL_VALID)
    exit(1)

# remove invalid, add valid
if has_invalid_label:
    pr.remove_from_labels(changelog_utils.CL_INVALID)
if not has_valid_label:
    pr.add_to_labels(changelog_utils.CL_VALID)
print("Changelog is valid.")
