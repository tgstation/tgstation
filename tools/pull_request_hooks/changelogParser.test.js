import { strict as assert } from "node:assert";
import { parseChangelog } from "./changelogParser.js";

// Basic test
const basicChangelog = parseChangelog(`
	My cool PR!
	:cl: DenverCoder9
	add: Adds new stuff
	/:cl:
`);

assert.equal(basicChangelog.author, "DenverCoder9");
assert.equal(basicChangelog.changes.length, 1);
assert.equal(basicChangelog.changes[0].type.changelogKey, "rscadd");
assert.equal(basicChangelog.changes[0].description, "Adds new stuff");

// Multi-line test
const multiLineChangelog = parseChangelog(`
	My cool PR!
	:cl:
	add: Adds new stuff
	to the game
	/:cl:
`);

assert.equal(multiLineChangelog.author, undefined);
assert.equal(multiLineChangelog.changes.length, 1);
assert.equal(multiLineChangelog.changes[0].type.changelogKey, "rscadd");
assert.equal(
	multiLineChangelog.changes[0].description,
	"Adds new stuff\nto the game"
);

// Placeholders
const placeholderChangelog = parseChangelog(`
	My cool PR!
	:cl:
	add: Added new mechanics or gameplay changes
	/:cl:
`);

assert.equal(placeholderChangelog.changes.length, 0);

// No changelog
const noChangelog = parseChangelog(`
	My cool PR!
`);

assert.equal(noChangelog, undefined);

// No /:cl:

const noCloseChangelog = parseChangelog(`
	My cool PR!
	:cl:
	add: Adds new stuff
`);

assert.equal(noCloseChangelog.changes.length, 1);
assert.equal(noCloseChangelog.changes[0].type.changelogKey, "rscadd");
assert.equal(noCloseChangelog.changes[0].description, "Adds new stuff");

// :cl: with arbitrary text

const arbitraryTextChangelog = parseChangelog(`
	My cool PR!
	:cl:
	Adds new stuff
	/:cl:
`);

assert.equal(arbitraryTextChangelog.changes.length, 0);
