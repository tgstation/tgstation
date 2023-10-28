
https://github.com/Monkestation/Monkestation2.0/pull/429

## \<Tha bitrunner PR: Splits the Technology disk tab into combat gear and abilities tabs, seperates all the disk choices into seperate disks>

- Module ID: ID: BIT_RUNNERS

### Description:

- This modular file is for all things related to bitrunners, the PR that it started with is the title

### TG Proc/File Changes:

<!-- Added an override for initialize, so we can get custom icons and remove un-needed descriptions. Along with changing the order categories -->
- code/modules/bitrunning/objects/bit_vendor.dm

### Modular Overrides:

- N/A

### Defines:

<!-- Added defines so the order vendor functions properly -->
- computers.dm
- #define CATEGORY_BITRUNNING_COMBAT_GEAR
- #define CATEGORY_BITRUNNING_ABILITIES
### Included files that are not contained in this module:

- N/A

### Credits:

- Gboster-0 - Splitting the tech disks into their individual parts, Most of the disk icons
