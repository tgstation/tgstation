// File Labels
//
// Add a label based on if a file is modified in the diff
//
// You can optionally set add_only to make the label one-way -
// if the edit to the file is removed in a later commit,
// the label will not be removed
const file_labels = {
	'GitHub': {
		filepaths: ['.github'],
	},
	'SQL': {
		filepaths: ['SQL'],
	},
	'Map Edit': {
		filepaths: ['_maps'],
	},
	'Tools': {
		filepaths: ['tools'],
	},
	'Config Update': {
		filepaths: ['config', 'code/controllers/configuration/entries'],
		add_only: true,
	},
	'Sprites': {
		filepaths: ['icons'],
		add_only: true,
	},
	'Sound': {
		filepaths: ['sound'],
		add_only: true,
	},
	'UI': {
		filepaths: ['tgui'],
		add_only: true,
	}
}

// Title Labels
//
// Add a label based on keywords in the title
const title_labels = {
	'Logging' : {
		keywords: ['log', 'logging'],
	},
	'Removal' : {
		keywords: ['remove', 'delete'],
	},
	'Refactor' : {
		keywords: ['refactor'],
	},
	'Unit Tests' : {
		keywords: ['test'],
	},
	'April Fools' : {
		keywords: ['[april fools]'],
	},
	'Do Not Merge' : {
		keywords: ['[dnm]', '[do not merge]'],
	},
	'GBP: No Update' : {
		keywords: ['[no gbp]'],
	},
	'Test Merge Only' : {
		keywords: ['[tm only]'],
	},
}

// Changelog Labels
//
// Adds labels based on keywords in the changelog
// TODO use the existing changelog parser
const changelog_labels = {
	'Fix': {
		default_text: 'fixed a few things',
		keywords: ['fix', 'fixes', 'bugfix'],
	},
	'Quality of Life': {
		default_text: 'made something easier to use',
		keywords: ['qol'],
	},
	'Sound': {
		default_text: 'added/modified/removed audio or sound effects',
		keywords: ['sound'],
	},
	'Feature': {
		default_text: 'Added new mechanics or gameplay changes',
		alt_default_text: 'Added more things',
		keywords: ['add', 'adds', 'rscadd'],
	},
	'Removal': {
		default_text: 'Removed old things',
		keywords: ['del', 'dels', 'rscdel'],
	},
	'Sprites': {
		default_text: 'added/modified/removed some icons or images',
		keywords: ['image'],
	},
	'Grammar and Formatting': {
		default_text: 'fixed a few typos',
		keywords: ['typo', 'spellcheck'],
	},
	'Balance': {
		default_text: 'rebalanced something',
		keywords: ['balance'],
	},
	'Code Improvement': {
		default_text: 'changed some code',
		keywords: ['code_imp', 'code'],
	},
	'Refactor': {
		default_text: 'refactored some code',
		keywords: ['refactor'],
	},
	'Config Update': {
		default_text: 'changed some config setting',
		keywords: ['config'],
	},
	'Administration': {
		default_text: 'messed with admin stuff',
		keywords: ['admin'],
	},
}

function keyword_to_cl_label() {
	const keyword_to_cl_label = {};
	for (let label in changelog_labels) {
		for (let keyword of changelog_labels[label].keywords) {
			keyword_to_cl_label[keyword] = label;
		}
	}
	return keyword_to_cl_label;
}

// Checks the body (primarily the changelog) for labels to add
function check_body_for_labels(body) {
	const labels_to_add = [];

	// if the body contains a github "fixes #1234" line, add the Fix tag
	const fix_regex = new RegExp(`(?i)(fix[des]*|resolve[sd]*)\s*#[0-9]+/`);
	if (fix_regex.test(body)) {
		labels_to_add.push('Fix');
	}

	const keywords = keyword_to_cl_label();

	let found_cl = false;
	for (let line in body.split('\n')) {
		if(line.startsWith(':cl:')) {
			found_cl = true;
			continue;
		} else if(line.startsWith('/:cl:')) {
			break;
		} else if(!found_cl) {
			continue;
		}
		// see if the first segment of the line is one of the keywords
		const found_label = keywords[line.split(':')[0]?.toLowerCase()];
		if (found_label) {
			// don't add a billion tags if they forgot to clear all the default ones
			const line_text = line.split(':')[1].trim();
			const cl_label = changelog_labels[found_label];
			if (line_text !== cl_label.default_text && line_text !== cl_label.alt_default_text) {
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
	for (let label in title_labels) {
		let found = false;
		for (let keyword in title_labels[label].keywords) {
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
	const tag_re = new RegExp(`diff --git a/${element}/`);
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
			for (let label in file_labels) {
				let found = false;
				const { filepaths, add_only } = file_labels[label];
				for (let filepath in filepaths) {
					if(check_diff_line_for_element(diff_txt, filepath)) {
						found = true;
						break;
					}
				}
				if (found) {
					labels_to_add.push(label);
				}
				else if (!add_only) {
					labels_to_remove.push(label);
				}
			}
		}
		else {
			console.error(`Failed to fetch diff: ${diff.status} ${diff.statusText}`);
		}
	}
	catch (e) {
		console.error(e);
	}
	return { labels_to_add, labels_to_remove };
}


export async function update_labels({ github, context }) {
	const {
		action,
		pull_request,
	} = context.payload;
	const {
		body,
		diff_url,
		labels,
		mergeable,
		number,
		title,
	} = pull_request;

	let updated_labels = labels;

	// diff is always checked
	const diff_tags = await check_diff_for_labels(diff_url);
	updated_labels = updated_labels.concat(diff_tags.labels_to_add);
	updated_labels = updated_labels.filter(label => !diff_tags.labels_to_remove.includes(label));

	// body and title are only checked on open, not on sync
	if(action === 'opened' || action === 'reopened') {
		updated_labels = updated_labels.concat(check_title_for_labels(title));
		updated_labels = updated_labels.concat(check_body_for_labels(body));
	}
	// update merge conflict label
	if(mergeable)
		updated_labels = updated_labels.filter(label => label !== 'Merge Conflict');
	else
		updated_labels.push('Merge Conflict');

	return [... new Set(updated_labels)];
}
