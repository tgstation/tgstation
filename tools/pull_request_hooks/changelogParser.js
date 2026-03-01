import * as changelogConfig from "./changelogConfig.js";

const REGEX_CHANGELOG_LINE = /^(\w+): (.+)$/;

const CHANGELOG_KEYS_TO_ENTRY = {};
for (const [types, entry] of changelogConfig.CHANGELOG_ENTRIES) {
  const entryWithChangelogKey = {
    ...entry,
    changelogKey: types[0],
  };

  for (const type of types) {
    CHANGELOG_KEYS_TO_ENTRY[type] = entryWithChangelogKey;
  }
}

function parseChangelogBody(lines, openTag) {
  const [changelogOpening] = lines.splice(0, 1);

  const author = changelogOpening.substring(openTag.length).trim() || undefined;

  const changelog = {
    author,
    changes: [],
  };

  for (const line of lines) {
    if (line.trim().length === 0) {
      continue;
    }

    for (const closeTag of changelogConfig.CHANGELOG_CLOSE_TAGS) {
      if (line.startsWith(closeTag)) {
        return changelog;
      }
    }

    const match = line.match(REGEX_CHANGELOG_LINE);
    if (match) {
      const [_, type, description] = match;

      const entry = CHANGELOG_KEYS_TO_ENTRY[type.toLowerCase()];

      if (!entry || entry.placeholders.includes(description)) {
        continue;
      }

      if (entry) {
        changelog.changes.push({
          type: entry,
          description,
        });
      }
    } else {
      const lastChange = changelog.changes[changelog.changes.length - 1];
      if (lastChange) {
        lastChange.description += `\n${line}`;
      }
    }
  }

  return changelog;
}

export function parseChangelog(text) {
  if (text == null) {
    return undefined;
  }
  const lines = text.split("\n").map((line) => line.trim());

  for (let index = 0; index < lines.length; index++) {
    const line = lines[index];

    for (const openTag of changelogConfig.CHANGELOG_OPEN_TAGS) {
      if (line.startsWith(openTag)) {
        return parseChangelogBody(lines.slice(index), openTag);
      }
    }
  }

  return undefined;
}
