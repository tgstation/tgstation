import enum
import logging
import os
import re
import subprocess
import time
import typing

from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, Future, as_completed
from pathlib import Path
from re import Pattern
from subprocess import CompletedProcess

from github import Github
from github.PaginatedList import PaginatedList
from github.PullRequest import PullRequest
from github.Repository import Repository
from openai import OpenAI
from openai.types.chat import ChatCompletion

import changelog_utils


class UpstreamLabel(str, enum.Enum):
    CONFIG_CHANGE = "Config Update"
    SQL_CHANGE = "SQL"


class Change(typing.TypedDict):
    tag: str
    message: str
    translated_message: typing.NotRequired[str]
    pull: PullRequest


class PullDetails(typing.TypedDict):
    changelog: typing.Dict[int, list[Change]]
    merge_order: list[int]
    config_changes: list[PullRequest]
    sql_changes: list[PullRequest]


LABEL_BLOCK_STYLE = {
    UpstreamLabel.CONFIG_CHANGE: "IMPORTANT",
    UpstreamLabel.SQL_CHANGE: "IMPORTANT",
}


def check_env():
    """Check if the required environment variables are set."""
    logging.debug("Checking environment variables...")
    required_vars = [
        "GITHUB_TOKEN",
        "TARGET_REPO",
        "TARGET_BRANCH",
        "UPSTREAM_REPO",
        "UPSTREAM_BRANCH",
        "MERGE_BRANCH"
    ]
    if TRANSLATE_CHANGES:
        required_vars.append("OPENAI_API_KEY")
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        logging.error("Missing required environment variables: %s", ", ".join(missing_vars))
        raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")


logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO").upper())

# Environment variables
TRANSLATE_CHANGES = os.getenv("TRANSLATE_CHANGES", "False").lower() in ("true", "yes", "1")
CHANGELOG_AUTHOR = os.getenv("CHANGELOG_AUTHOR", "")

check_env()
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
TARGET_REPO = os.getenv("TARGET_REPO")
TARGET_BRANCH = os.getenv("TARGET_BRANCH")
UPSTREAM_REPO = os.getenv("UPSTREAM_REPO")
UPSTREAM_BRANCH = os.getenv("UPSTREAM_BRANCH")
MERGE_BRANCH = os.getenv("MERGE_BRANCH")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")


def run_command(command: str) -> str:
    """Run a shell command and return its output."""
    logging.debug("Running command: %s", command)
    try:
        result: CompletedProcess[str] = subprocess.run(command, shell=True, capture_output=True, text=True)
        result.check_returncode()
        logging.debug("Command output: %s", result.stdout.strip())
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logging.error("Error executing command: %s", command)
        logging.error("Exit code: %d, Output: %s, Error: %s", e.returncode, e.output, e.stderr)
        raise


def setup_repo():
    """Clone the repository and set up the upstream remote."""
    logging.info("Cloning repository: %s", TARGET_REPO)
    run_command(f"git clone https://x-access-token:{GITHUB_TOKEN}@github.com/{TARGET_REPO}.git repo")
    os.chdir("repo")
    run_command(f"git remote add upstream https://x-access-token:{GITHUB_TOKEN}@github.com/{UPSTREAM_REPO}.git")
    logging.info("Git remotes set up: %s", run_command(f"git remote -v"))


def update_merge_branch():
    """Update the merge branch with the latest changes from upstream."""
    logging.info("Fetching branch %s from upstream...", UPSTREAM_BRANCH)
    run_command(f"git fetch upstream {UPSTREAM_BRANCH}")
    run_command(f"git fetch origin")
    all_branches: list[str] = run_command("git branch -a").split()
    logging.debug("Fetched branches: %s", all_branches)

    if f"remotes/origin/{MERGE_BRANCH}" not in all_branches:
        logging.info("Branch '%s' does not exist. Creating it from upstream/%s...", MERGE_BRANCH, UPSTREAM_BRANCH)
        run_command(f"git checkout -b {MERGE_BRANCH} upstream/{UPSTREAM_BRANCH}")
        run_command(f"git push -u origin {MERGE_BRANCH}")
        return

    logging.info("Resetting '%s' onto upstream/%s...", MERGE_BRANCH, UPSTREAM_BRANCH)
    run_command(f"git checkout {MERGE_BRANCH}")
    run_command(f"git reset --hard upstream/{UPSTREAM_BRANCH}")
    logging.info("Pushing changes to origin...")
    run_command(f"git push origin {MERGE_BRANCH} --force")


def detect_commits() -> list[str]:
    """Detect commits from upstream not yet in downstream."""
    logging.info("Detecting new commits from upstream...")
    commit_log: list[str] = run_command(f"git log {TARGET_BRANCH}..{MERGE_BRANCH} --pretty=format:'%h %s'").split("\n")
    commit_log.reverse()
    logging.debug("Detected commits: %s", commit_log)
    return commit_log


def fetch_pull(github: Github, pull_number: int) -> PullRequest | None:
    """Fetch the pull request from GitHub."""
    logging.debug("Fetching pull request #%d", pull_number)
    upstream_repo: Repository = github.get_repo(UPSTREAM_REPO)

    max_retries = 3
    for attempt in range(max_retries):
        try:
            pull = upstream_repo.get_pull(int(pull_number))
            logging.debug("Successfully fetched PR #%d: %s", pull_number, pull.title)
            return pull
        except Exception as e:
            logging.error("Error fetching PR #%d: %s", pull_number, e)
            if attempt + 1 < max_retries:
                logging.warning("Retrying fetch for PR #%d (attempt %d/%d)", pull_number, attempt + 1, max_retries)
                time.sleep(2)
            else:
                logging.error("Failed to fetch PR #%d after %d attempts", pull_number, max_retries)
                return None


def build_details(github: Github, commit_log: list[str],
                  translate: typing.Optional[typing.Callable[[typing.Dict[int, list[Change]]], None]]) -> PullDetails:
    """Generate data from parsed commits."""
    logging.info("Building pull request details from commit log...")
    pull_number_pattern: Pattern[str] = re.compile("#(?P<id>\\d+)")
    details = PullDetails(
        changelog={},
        merge_order=[],
        config_changes=[],
        sql_changes=[]
    )
    pull_cache: dict[int, str] = {}

    with ThreadPoolExecutor() as executor:
        futures: dict[Future, int] = {}
        for commit in commit_log:
            if '[ci skip]' in commit:
                logging.debug("Skipping automatic commit: %s", commit)
                continue

            match = re.search(pull_number_pattern, commit)
            if not match:
                logging.debug("Skipping commit without pull request reference: %s", commit)
                continue

            pull_number = int(match.group("id"))

            if pull_number in pull_cache:
                logging.warning(
                    "Duplicate pull request detected for #%d\n"
                    "Existing: %s\n"
                    "New: %s",
                    pull_number, pull_cache[pull_number], commit
                )
                continue

            pull_cache[pull_number] = commit
            details["merge_order"].append(pull_number)
            futures[executor.submit(fetch_pull, github, pull_number)] = pull_number

        for future in as_completed(futures):
            pull_number = futures[future]
            try:
                pull: PullRequest | None = future.result()
                if not pull:
                    logging.warning("Failed to fetch pull request #%d. Skipping.", pull_number)
                    continue
                process_pull(details, pull)
            except Exception as e:
                logging.error("Error processing pull request #%d: %s", pull_number, e)

    if translate:
        translate(details["changelog"])

    logging.info("Details building complete. Processed %d pull requests.", len(details["merge_order"]))
    return details


def process_pull(details: PullDetails, pull: PullRequest):
    """Handle fetched pull request data during details building."""
    logging.debug("Processing pull request #%d: %s", pull.number, pull.title)
    pull_number: int = pull.number
    labels: list[str] = [label.name for label in pull.get_labels()]
    pull_changes: list[Change] = []

    try:
        for label in labels:
            if label == UpstreamLabel.CONFIG_CHANGE.value:
                details["config_changes"].append(pull)
                logging.debug("Detected CONFIG_CHANGE label for PR #%d", pull_number)
            elif label == UpstreamLabel.SQL_CHANGE.value:
                details["sql_changes"].append(pull)
                logging.debug("Detected SQL_CHANGE label for PR #%d", pull_number)

        parsed = changelog_utils.parse_changelog(pull.body)
        if parsed and parsed["changes"]:
            logging.debug("Parsed changelog for PR #%d: %s", pull_number, parsed["changes"])
            for change in parsed["changes"]:
                pull_changes.append(Change(
                    tag=change["tag"],
                    message=change["message"],
                    pull=pull
                ))

        if pull_changes:
            details["changelog"][pull_number] = pull_changes
            logging.debug("Added %d changes for PR #%d", len(pull_changes), pull_number)
    except Exception as e:
        logging.error(
            "An error occurred while processing PR #%d: %s\n"
            "Body: %s",
            pull.number, e, pull.body
        )
        raise


def translate_changelog(changelog: typing.Dict[int, list[Change]]):
    """Translate changelog using OpenAI API."""
    logging.info("Translating changelog...")
    if not changelog:
        logging.warning("No changelog entries to translate.")
        return

    changes: list[Change] = [change for changes in changelog.values() for change in changes]
    if not changes:
        logging.warning("No changes found in the changelog to translate.")
        return

    logging.debug("Preparing text for translation: %d changes", len(changes))
    text = "\n".join([change["message"] for change in changes])
    logging.debug(text)
    script_dir = Path(__file__).resolve().parent
    with open(script_dir.joinpath("translation_context.txt"), encoding="utf-8") as f:
        context = "\n".join(f.readlines()).strip()

    client = OpenAI(
        base_url="https://models.github.ai/inference",
        api_key=OPENAI_API_KEY,
    )
    response: ChatCompletion = client.chat.completions.create(
        messages=[
            {"role": "system", "content": context},
            {"role": "user", "content": text}
        ],
        model="openai/gpt-4.1-mini",
    )
    translated_text: str | None = response.choices[0].message.content

    if not translated_text:
        logging.warning("Changelog translation failed!")
        logging.debug("Translation API response: %s", response)
        return

    translated_text = sanitize_translation(translated_text)

    for change, translated_message in zip(changes, translated_text.split("\n")):
        change["translated_message"] = translated_message
        logging.debug("Translated: %s -> %s", change["message"], translated_message)


def sanitize_translation(translated_text: str):
    """Sanitize changelog translation."""
    return re.sub(r"\\n+", "\n+", translated_text.strip())


def silence_pull_url(pull_url: str) -> str:
    """Reformat HTTP URL with 'www' prefix to prevent pull request linking."""
    return re.sub("https?://", "www.", pull_url)


def prepare_pull_body(details: PullDetails) -> str:
    """Build new pull request body from the generated changelog."""
    logging.info("Preparing pull request body...")
    pull_body: str = (
        f"This pull request merges upstream/{UPSTREAM_BRANCH}. "
        f"Resolve possible conflicts manually and make sure all the changes are applied correctly.\n"
    )

    if not details:
        logging.warning("No pull details provided. Using default body.")
        return pull_body

    label_to_pulls: dict[UpstreamLabel, list[PullRequest]] = {
        UpstreamLabel.CONFIG_CHANGE: details["config_changes"],
        UpstreamLabel.SQL_CHANGE: details["sql_changes"]
    }

    for label, fetched_pulls in label_to_pulls.items():
        if not fetched_pulls:
            logging.debug("No pulls found for label '%s'", label.value)
            continue

        pull_body += (
            f"\n> [!{LABEL_BLOCK_STYLE[label]}]\n"
            f"> {label.value}:\n"
        )
        for fetched_pull in fetched_pulls:
            silenced_url = silence_pull_url(fetched_pull.html_url)
            logging.debug("Adding pull #%d to body: %s", fetched_pull.number, silenced_url)
            pull_body += f"> {silenced_url}\n"

    if not details["changelog"]:
        logging.info("No changelog entries found.")
        return pull_body

    logging.info("Adding changelog entries to pull request body.")
    pull_body += f"\n## Changelog\n"
    pull_body += f":cl: {CHANGELOG_AUTHOR}\n" if CHANGELOG_AUTHOR else ":cl:\n"

    for pull_number in details["merge_order"]:
        if pull_number not in details["changelog"]:
            continue
        for change in details["changelog"][pull_number]:
            tag: str = change["tag"]
            message: str = change["message"]
            translated_message: str | None = change.get("translated_message")
            pull_url: str = silence_pull_url(change["pull"].html_url)
            if translated_message:
                pull_body += f"{tag}: {translated_message} <!-- {message} ({pull_url}) -->\n"
                logging.debug("Added translated change for PR #%d: %s", pull_number, translated_message)
            else:
                pull_body += f"{tag}: {message} <!-- ({pull_url}) -->\n"
                logging.debug("Added original change for PR #%d: %s", pull_number, message)
    pull_body += "/:cl:\n"

    logging.info("Pull request body prepared successfully.")
    return pull_body


def create_pr(repo: Repository, details: PullDetails):
    """Create a pull request with the processed changelog."""
    logging.info("Creating pull request...")
    pull_body: str = prepare_pull_body(details)

    try:
        # Create the pull request
        pull: PullRequest = repo.create_pull(
            title=f"[IDB IGNORE][MDB IGNORE] Merge Upstream {datetime.today().strftime('%d.%m.%Y')}",
            body=pull_body,
            head=MERGE_BRANCH,
            base=TARGET_BRANCH
        )
        logging.info("Pull request created: %s", pull.html_url)
    except Exception as e:
        logging.error("Failed to create pull request: %s", e)
        raise


def check_pull_exists(target_repo: Repository, base: str, head: str):
    """Check if the merge pull request already exists."""
    logging.info("Checking if pull request already exists between '%s' and '%s'...", base, head)
    owner: str = target_repo.owner.login
    head_strict = f"{owner}:{head}"
    existing_pulls: PaginatedList[PullRequest] = target_repo.get_pulls(state="open", base=base, head=head_strict)
    if existing_pulls.totalCount > 0:
        logging.error("Pull request already exists: %s", ", ".join(pull.html_url for pull in existing_pulls))
        exit(1)
    logging.debug("No existing pull requests found.")

if __name__ == "__main__":
    github = Github(GITHUB_TOKEN)
    target_repo: Repository = github.get_repo(TARGET_REPO)

    check_pull_exists(target_repo, TARGET_BRANCH, MERGE_BRANCH)
    setup_repo()

    update_merge_branch()
    commit_log: list[str] = detect_commits()

    if commit_log:
        details: PullDetails = build_details(github, commit_log, translate_changelog if TRANSLATE_CHANGES else None)
        create_pr(target_repo, details)
    else:
        logging.info("No changes detected from %s/%s. Skipping pull request creation.", UPSTREAM_REPO, UPSTREAM_BRANCH)
