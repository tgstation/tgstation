/**
 * A map of changelog phrases to meta-information.
 *
 * The first entry in the list is used in the changelog YML file as the key when
 * used, but other than that all entries are equivalent.
 *
 * placeholders - The default messages, if the changelog has this then we pretend it
 * doesn't exist.
 */
export const CHANGELOG_ENTRIES = [
	[
		["rscadd", "add", "adds"],
		{
			placeholders: [
				"Added new mechanics or gameplay changes",
				"Added more things",
			],
		},
	],

	[
		["bugfix", "fix", "fixes"],
		{
			placeholders: ["fixed a few things"],
		},
	],

	[
		["rscdel", "del", "dels"],
		{
			placeholders: ["Removed old things"],
		},
	],

	[
		["qol"],
		{
			placeholders: ["made something easier to use"],
		},
	],

	[
		["soundadd"],
		{
			placeholders: ["added a new sound thingy"],
		},
	],

	[
		["sounddel"],
		{
			placeholders: ["removed an old sound thingy"],
		},
	],

	[
		["imageadd"],
		{
			placeholders: ["added some icons and images"],
		},
	],

	[
		["imagedel"],
		{
			placeholders: ["deleted some icons and images"],
		},
	],

	[
		["spellcheck", "typo"],
		{
			placeholders: ["fixed a few typos"],
		},
	],

	[
		["balance"],
		{
			placeholders: ["rebalanced something"],
		},
	],

	[
		["code_imp", "code"],
		{
			placeholders: ["changed some code"],
		},
	],

	[
		["refactor"],
		{
			placeholders: ["refactored some code"],
		},
	],

	[
		["config"],
		{
			placeholders: ["changed some config setting"],
		},
	],

	[
		["admin"],
		{
			placeholders: ["messed with admin stuff"],
		},
	],

	[
		["server"],
		{
			placeholders: ["something server ops should know"],
		},
	],
];

// Valid changelog openers
export const CHANGELOG_OPEN_TAGS = [":cl:", "??"];

// Valid changelog closers
export const CHANGELOG_CLOSE_TAGS = ["/:cl:", "/ :cl:", ":/cl:", "/??", "/ ??"];

// Placeholder value for an author
export const CHANGELOG_AUTHOR_PLACEHOLDER_NAME = "optional name here";
