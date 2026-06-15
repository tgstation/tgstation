## Resources

[Guide to DreamMaker](https://www.byond.com/docs/guide/)

## Edits to existing files

This action is reserved for number-tweaks, un-commenting imported deletions, adding guard statements or editing behavior for existing features.
**Do not remove features unless they break other modules.**
**Do not add new behavior to existing modules.**
All edits to existing files must be commented appropriately.

- **First line of added feature/Single line:**
  `new/line 		// IRIDIUM ADD
second/line 	// IRIDIUM ADD END
`
- **First line of removed feature/Single line:**
  `//old/line		// IRIDIUM DEL
//second/line 	// IRIDIUM DEL END
`
- **Edited feature:**
  `
  edited/code/first
  edited/code/last

// original/code/first
// original/code/last // IRIDIUM EDIT
`

## Importing from other repositories

WIP

## Creating new features

New features will need additional, separate files to be created in **code/\_\_\_IRIDIUM_DEFINES** and **code/zz_modules_iridium**, for word definitions and code respectively.
**Overrides count as new features for the purpose of maintenance.**
To create a definition override, a separate file must be created in **code/zz_IRIDIUM_OVERRIDE_DEFINES**, and it must follow a similar path structure to the file it's overriding.
Make sure to name files appropriately for their purpose: e.g. if a variable for /datum/species/human must be overridden, the file should be named human_overrides.dm or similar.
**The PR must be formatted with the given tools and prompts.**

##
