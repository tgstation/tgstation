import { DME_NAME } from "../build";

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
export async function prependDefines(...defines: string[]): Promise<void> {
  const file = Bun.file(`${DME_NAME}.dme`);

  const dmeContents = await file.text();
  const textToWrite = defines.map((define) => `#define ${define}\n`);

  await file.write(`${textToWrite.join("")}\n${dmeContents}`);
}
