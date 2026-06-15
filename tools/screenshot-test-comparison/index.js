import {
  copyFileSync,
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { join, parse } from 'node:path';
import { argv, exit } from 'node:process';
import pixelmatch from 'pixelmatch';
import { PNG } from 'pngjs';

const artifactsDirectory = argv[2];
if (!artifactsDirectory) {
  console.error('Artifacts directory was not passed in');
  exit(1);
}

const screenshotsDirectory = argv[3];
if (!screenshotsDirectory) {
  console.error('Screenshots directory was not passed in');
  exit(1);
}

const outputDirectory = argv[4];
if (!outputDirectory) {
  console.error('Output directory was not passed in');
  exit(1);
}

const knownFailures = new Set();

const fail = (screenshotName, newScreenshot, oldScreenshot, diff) => {
  knownFailures.add(screenshotName);

  const outputPath = join(outputDirectory, parse(screenshotName).name);
  mkdirSync(outputPath, {
    recursive: true,
  });

  copyFileSync(newScreenshot, join(outputPath, 'new.png'));

  if (oldScreenshot) {
    copyFileSync(oldScreenshot, join(outputPath, 'old.png'));
  }

  if (diff) {
    writeFileSync(join(outputPath, 'diff.png'), PNG.sync.write(diff));
  }
};

for (const filename of readdirSync(artifactsDirectory)) {
  if (!filename.startsWith('test_artifacts')) {
    continue;
  }

  const fullPath = join(artifactsDirectory, filename, 'screenshots_new');

  const fullPathStat = statSync(fullPath);
  if (!fullPathStat.isDirectory()) {
    continue;
  }

  for (const screenshotName of readdirSync(fullPath)) {
    if (knownFailures.has(screenshotName)) {
      continue;
    }

    const fullPathScreenshotName = join(fullPath, screenshotName);

    const fullPathCompareScreenshot = join(
      screenshotsDirectory,
      screenshotName,
    );
    if (!existsSync(fullPathCompareScreenshot)) {
      console.error(
        `${fullPathCompareScreenshot} is missing an existing screenshot to compare against`,
      );
      fail(screenshotName, fullPathScreenshotName);
      continue;
    }

    const screenshotNew = PNG.sync.read(readFileSync(fullPathScreenshotName));
    const screenshotCompare = PNG.sync.read(
      readFileSync(fullPathCompareScreenshot),
    );

    if (
      screenshotNew.width !== screenshotCompare.width ||
      screenshotNew.height !== screenshotCompare.height
    ) {
      console.error(
        `${screenshotName} has different dimensions from the known screenshot`,
      );
      fail(screenshotName, fullPathScreenshotName, fullPathCompareScreenshot);
      continue;
    }

    const diff = new PNG({
      width: screenshotNew.width,
      height: screenshotNew.height,
    });
    const diffResult = pixelmatch(
      screenshotNew.data,
      screenshotCompare.data,
      diff.data,
      screenshotNew.width,
      screenshotNew.height,
      { threshold: 0.1 },
    );

    if (diffResult) {
      console.error(`${screenshotName} differs from the known screenshot`);
      fail(
        screenshotName,
        fullPathScreenshotName,
        fullPathCompareScreenshot,
        diff,
      );
    }
  }
}

if (knownFailures.size > 0) {
  console.error(`${knownFailures.size} screenshots failed`);
  exit(1);
}
