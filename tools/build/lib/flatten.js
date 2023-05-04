// This script does the following:
// Loads the .dme and recurively and indiscriminately (no preprocessing) finds all #included files
// The included file are then copied to /flat but they have their directory separators replace with `!`s
// i.e. /code/game/world.dm becomes /flat/code!game!world.dm
// All #includes are adjusted to reflect this
// It then outputs /{dmeFile}.flat.dme which can be used to build the /flat tree
// We do this for code coverage purposes in CI generally
// It would not be necessary if not for this decade old BYOND bug
// http://www.byond.com/forum/post/108025

import fsPromises from 'fs/promises';
import path from 'path';

const FlatDirectoryName = "flat";

const flattenCode = async (directoryToFlatten, dmeFile) => {
  const includeRegex = new RegExp("#include(\\s+)\"(.*)\"", "gm");

  const outputLines = [];

  const currentDirectoryA = path.resolve(path.join(directoryToFlatten, "A"));

  function flatPath(filePath) {
    return filePath.replace(/[\\\/]/g, '!');
  }

  async function createFlatFile(filePath, dme) {
    const originalPathDirectory = path.resolve(path.dirname(filePath));
    filePath = path.resolve(filePath).substring(currentDirectoryA.length - 1);

    let fileContents = await fsPromises.readFile(filePath, "utf8");
    // normalize __FILE__
    fileContents = fileContents.replace(/__FILE__/g, 'replacetext(copytext(__FILE__, 6), "!", "/")');

    const matches = Array.from(fileContents.matchAll(includeRegex));

    for (const match of matches) {
      const fullIncludePath = path.resolve(path.join(originalPathDirectory, match[2])).substring(currentDirectoryA.length - 1).replace(/\\/g, '/');
      if (await fsPromises.access(fullIncludePath).then(() => true).catch(() => false)) {
        await createFlatFile(fullIncludePath, false);
      }

      let substitutedPath = flatPath(fullIncludePath.replace(/\//g, '\\'));
      if (dme) {
        substitutedPath = path.join(FlatDirectoryName, substitutedPath);
      }

      fileContents = fileContents.replace(match[0], `#include${match[1]}"${substitutedPath}"`);
    }

    const flatFileName = path.resolve(
      dme
        ? filePath.replace(".dme", ".flat.dme")
        : path.join(FlatDirectoryName, flatPath(filePath))
    );

    await fsPromises.mkdir(path.dirname(flatFileName), {recursive: true});
    await fsPromises.writeFile(flatFileName, fileContents);

    outputLines.push(`"${path.resolve(filePath)}" => "${flatFileName}"${matches.length > 0 ? ` (${matches.length} adapted #includes)` : ""}`);
  }

  const flatDirectory = path.join(directoryToFlatten, FlatDirectoryName);
  if (await fsPromises.access(flatDirectory).then(() => true).catch(() => false)) {
    await fsPromises.rm(flatDirectory, {recursive: true});
  }
  await fsPromises.mkdir(flatDirectory);

  await createFlatFile(path.join(directoryToFlatten, dmeFile), true);
};

export default flattenCode;
