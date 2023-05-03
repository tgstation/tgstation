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
