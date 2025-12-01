import assert from "node:assert/strict";
import { changelogToYml } from "./autoChangelog.js";
import { parseChangelog } from "./changelogParser.js";

assert.equal(
  changelogToYml(
    parseChangelog(`
			My cool PR!
			:cl: DenverCoder9
			add: Adds new stuff
			add: Adds more stuff
			/:cl:
		`),
  ),

  `author: "DenverCoder9"
delete-after: True
changes:
  - rscadd: "Adds new stuff"
  - rscadd: "Adds more stuff"`,
);
