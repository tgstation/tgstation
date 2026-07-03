import re
import copy

CL_INVALID = ":scroll: CL невалиден"
CL_VALID = ":scroll: CL валиден"
CL_NOT_NEEDED = ":scroll: CL не требуется"

CL_BODY = re.compile(r"(:cl:|🆑)[ \t]*(?P<author>.+?)?\s*\n(?P<content>(.|\n)*?)\n/(:cl:|🆑)", re.MULTILINE)
CL_SPLIT = re.compile(r"\s*(?:(?P<tag>\w+)\s*:)?\s*(?P<message>.*)")

DISCORD_TAG_EMOJI = {
    "admin": ":magic_wand:",
    "balance": ":scales:",
    "bugfix": ":adhesive_bandage:",
    "code_imp": ":hammer:",
    "config": ":gear:",
    "image": ":frame_photo:",
    "map": ":map:",
    "qol": ":herb:",
    "refactor": ":tools:",
    "rscadd": ":sparkles:",
    "rscdel": ":wastebasket:",
    "server": ":shield:",
    "sound": ":notes:",
    "spellcheck": ":pencil:",
    "translation": ":nerd:"
}


def build_changelog(pr: dict, tags_config: dict) -> dict:
    changelog = parse_changelog(pr.body, tags_config)
    if changelog is None:
        raise Exception("Failed to parse the changelog. Check changelog format.")
    changelog["author"] = changelog["author"] or pr.user.login
    return changelog


def emojify_changelog(changelog: dict):
    changelog_copy = copy.deepcopy(changelog)
    for change in changelog_copy["changes"]:
        if change["tag"] in DISCORD_TAG_EMOJI:
            change["tag"] = DISCORD_TAG_EMOJI[change["tag"]]
        else:
            raise Exception(f"Invalid tag for emoji: {change}")
    return changelog_copy


def validate_changelog(changelog: dict):
    if not changelog:
        raise Exception("No changelog.")
    if not changelog["author"]:
        raise Exception("The changelog has no author.")
    if len(changelog["changes"]) == 0:
        raise Exception("No changes found in the changelog. Use special label if changelog is not expected.")


def parse_changelog(pr_body: str, tags_config: dict | None = None) -> dict | None:
    clean_pr_body = re.sub(r"<!--.*?-->", "", pr_body, flags=re.DOTALL)
    cl_parse_result = CL_BODY.search(clean_pr_body)
    if cl_parse_result is None:
        return None

    cl_changes = []
    for cl_line in cl_parse_result.group("content").splitlines():
        if not cl_line:
            continue
        change_parse_result = CL_SPLIT.search(cl_line)
        if not change_parse_result:
            raise Exception(f"Invalid change: '{cl_line}'")
        tag = change_parse_result["tag"]
        message = change_parse_result["message"]

        if tags_config and tag and tag not in tags_config['tags'].keys():
            raise Exception(f"Invalid tag: '{cl_line}'. Valid tags: {', '.join(tags_config['tags'].keys())}")
        if not message:
            raise Exception(f"No message for change: '{cl_line}'")

        message = message.strip()

        if tags_config and message in list(tags_config['defaults'].values()): # Check to see if the tags are associated with something that isn't the default text
            raise Exception(f"Don't use default message for change: '{cl_line}'")
        if tag:
            cl_changes.append({
                "tag": tags_config['tags'][tag] if tags_config else tag,
                "message": message
            })
        # Append line without tag to the previous change
        else:
            if len(cl_changes):
                prev_change = cl_changes[-1]
                prev_change["message"] += f" {message}"
            else:
                raise Exception(f"Change with no tag: {cl_line}")

    if len(cl_changes) == 0:
        raise Exception("No changes found in the changelog. Use special label if changelog is not expected.")
    return {
        "author": str.strip(cl_parse_result.group("author") or "") or None,  # I want this to be None, not empty
        "changes": cl_changes
    }
