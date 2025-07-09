import * as autoLabelConfig from "./autoLabelConfig.js";

function keyword_to_cl_label() {
  const keyword_to_cl_label = {};
  for (const label in autoLabelConfig.changelog_labels) {
    for (const keyword of autoLabelConfig.changelog_labels[label].keywords) {
      keyword_to_cl_label[keyword] = label;
    }
  }
  return keyword_to_cl_label;
}

// Checks the body (primarily the changelog) for labels to add
function check_body_for_labels(body) {
  const labels_to_add = [];

  // if the body contains a github "fixes #1234" line, add the Fix tag
  const fix_regex = new RegExp(`(fix[des]*|resolve[sd]*)\s*#\d+`, "gmi");
  if (fix_regex.test(body)) {
    labels_to_add.push("Fix");
  }

  const keywords = keyword_to_cl_label();

  let found_cl = false;
  for (const line of body.split("\n")) {
    if (line.startsWith(":cl:")) {
      found_cl = true;
      continue;
    } else if (line.startsWith("/:cl:")) {
      break;
    } else if (!found_cl) {
      continue;
    }
    // see if the first segment of the line is one of the keywords
    const found_label = keywords[line.split(":")[0]?.toLowerCase()];
    if (found_label) {
      // don't add a billion tags if they forgot to clear all the default ones
      const line_text = line.split(":")[1].trim();
      const cl_label = autoLabelConfig.changelog_labels[found_label];
      if (
        line_text !== cl_label.default_text &&
        line_text !== cl_label.alt_default_text
      ) {
        labels_to_add.push(found_label);
      }
    }
  }
  return labels_to_add;
}

// Checks the title for labels to add
function check_title_for_labels(title) {
  const labels_to_add = [];
  const title_lower = title.toLowerCase();
  for (const label in autoLabelConfig.title_labels) {
    let found = false;
    for (const keyword of autoLabelConfig.title_labels[label].keywords) {
      if (title_lower.includes(keyword)) {
        found = true;
        break;
      }
    }
    if (found) {
      labels_to_add.push(label);
    }
  }
  return labels_to_add;
}

function check_diff_line_for_element(diff, element) {
  const tag_re = new RegExp(`^diff --git a/${element}/`);
  return tag_re.test(diff);
}

// Checks the file diff for labels to add or remove
async function check_diff_for_labels(diff_url) {
  const labels_to_add = [];
  const labels_to_remove = [];
  try {
    const diff = await fetch(diff_url);
    if (diff.ok) {
      const diff_txt = await diff.text();
      for (const label in autoLabelConfig.file_labels) {
        let found = false;
        const { filepaths, add_only } = autoLabelConfig.file_labels[label];
        for (const filepath of filepaths) {
          if (check_diff_line_for_element(diff_txt, filepath)) {
            found = true;
            break;
          }
        }
        if (found) {
          labels_to_add.push(label);
        } else if (!add_only) {
          labels_to_remove.push(label);
        }
      }
    } else {
      console.error(`Failed to fetch diff: ${diff.status} ${diff.statusText}`);
    }
  } catch (e) {
    console.error(e);
  }
  return { labels_to_add, labels_to_remove };
}

export async function get_updated_label_set({ github, context }) {
  const { action, pull_request } = context.payload;
  const {
    body = "",
    diff_url,
    labels = [],
    mergeable,
    title = "",
  } = pull_request;

  const updated_labels = new Set();
  for (const label of labels) {
    updated_labels.add(label.name);
  }

  // diff is always checked
  if (diff_url) {
    const diff_tags = await check_diff_for_labels(diff_url);
    for (const label of diff_tags.labels_to_add) {
      updated_labels.add(label);
    }
    for (const label of diff_tags.labels_to_remove) {
      updated_labels.delete(label);
    }
  }
  // body and title are only checked on open, not on sync
  if (action === "opened") {
    if (title) {
      for (const label of check_title_for_labels(title)) {
        updated_labels.add(label);
      }
    }
    if (body) {
      for (const label of check_body_for_labels(body)) {
        updated_labels.add(label);
      }
    }
  }

  // this is always removed on updates
  updated_labels.delete("Test Merge Candidate");

  // update merge conflict label
  let merge_conflict = mergeable === false;
  // null means it was not reported yet
  // it is not normally included in the payload - a "get" is needed
  if (mergeable === null) {
    try {
      let response = await github.rest.pulls.get({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: pull_request.number,
      });
      // failed to find? still processing? try again in a few seconds
      if (response.data.mergeable === null) {
        console.log("Awaiting GitHub response for merge status...");
        await new Promise((r) => setTimeout(r, 10000));
        response = await github.rest.pulls.get({
          owner: context.repo.owner,
          repo: context.repo.repo,
          pull_number: pull_request.number,
        });
        if (response.data.mergeable === null) {
          throw new Error("Merge status not available");
        }
      }

      merge_conflict = response.data.mergeable === false;
    } catch (e) {
      console.error(e);
    }
  }
  if (merge_conflict) {
    updated_labels.add("Merge Conflict");
  } else {
    updated_labels.delete("Merge Conflict");
  }

  // return the labels to the action, which will apply it
  return [...updated_labels];
}
