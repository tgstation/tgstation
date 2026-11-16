#!/bin/sh
"exec" """$(dirname "$0")/../bootstrap/python""" "$0" "$@"
# -----------------------------------------------------------------------------
import io
import os
import argparse
import re
import json
from urllib import request
from dmi import *

USER_AGENT = "tgstation-13-credits-tool"


parser = argparse.ArgumentParser()
parser.add_argument("repo_owner", type=str)
parser.add_argument("repo", type=str)
parser.add_argument("auth_token", type=str, nargs="?", default=None)
parser.add_argument(
    "--output",
    type=str,
    default=os.path.join(os.path.dirname(__file__), "../../config/contributors.dmi"),
)
parser.add_argument(
    "--remappings",
    type=str,
    default=os.path.join(os.path.dirname(__file__), "remappings.txt"),
)
parser.add_argument("--icon-size", type=int, default=32)


def get_page_response(args, page_number):
    url = f"https://api.github.com/repos/{args.repo_owner}/{args.repo}/contributors?per_page=100&page={page_number}"
    return request.urlopen(
        request.Request(
            url,
            headers={
                "Accept": "application/json",
                "User-Agent": USER_AGENT,
                **({"Authorization": args.auth_token} if args.auth_token else {}),
            },
        )
    )


def get_num_pages_of_contributors(response):
    splits = response.headers["Link"].split(",")
    for each in splits:
        if 'rel="last"' in each:
            for match in re.findall(r"&page=(\d+)>", each):
                return int(match)
    return 1


def load_pages(first_response, args):
    num_pages = get_num_pages_of_contributors(first_response)
    yield from json.loads(first_response.read())
    for page in range(2, num_pages):
        yield from json.loads(get_page_response(args, page).read())


def load_config(path):
    r = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            k, v = line.split(maxsplit=1)
            r[k] = v
    return r


def main(args):
    print("Querying contributors API...")
    first_response = get_page_response(args, 1)

    print("Collecting avatar URLs...")
    login_avatars = {}
    for each in load_pages(first_response, args):
        avurl = each["avatar_url"]
        login_avatars[each["login"]] = (
            f"{avurl}{"&" if "?" in avurl else "&"}s={args.icon_size}"
        )

    print(f"Collected info for {len(login_avatars)} contributors.")
    print("Remapping github logins...")

    remaps = load_config(args.remappings)

    print(
        f"Downloading and converting avatars to {args.output} (this will take a while)..."
    )

    new_file = Dmi(args.icon_size, args.icon_size)

    for i, (key, url) in enumerate(login_avatars.items()):
        key = remaps.get(key, key)
        if key == "__REMOVE__":
            continue

        with request.urlopen(
            request.Request(
                url,
                headers={"User-Agent": USER_AGENT},
            )
        ) as response:
            im = Image.open(io.BytesIO(response.read()))

        if im.size != (args.icon_size, args.icon_size):
            im = im.resize((args.icon_size, args.icon_size))
        new_file.state(key).frame(im)

        print(f"Done {key}! {int(100 * (i + 1) / len(login_avatars))}%")

    new_file.to_file(args.output)


if __name__ == "__main__":
    main(parser.parse_args())
