const fs = require("fs");
const path = require("path");
const pixelmatch = require("pixelmatch");
const process = require("process");
const PNG = require("pngjs").PNG;

const artifactsDirectory = process.argv[2];
if (!artifactsDirectory) {
  console.error("Artifacts directory was not passed in");
  process.exit(1);
}

const screenshotsDirectory = process.argv[3];
if (!screenshotsDirectory) {
  console.error("Screenshots directory was not passed in");
  process.exit(1);
}

const outputDirectory = process.argv[4];
if (!outputDirectory) {
  console.error("Output directory was not passed in");
  process.exit(1);
}

const knownFailures = new Set();

const fail = (screenshotName, newScreenshot, oldScreenshot, diff) => {
  knownFailures.add(screenshotName);

  const outputPath = path.join(
    outputDirectory,
    path.parse(screenshotName).name,
  );
  fs.mkdirSync(outputPath, {
    recursive: true,
  });

  fs.copyFileSync(newScreenshot, path.join(outputPath, "new.png"));

  if (oldScreenshot) {
    fs.copyFileSync(oldScreenshot, path.join(outputPath, "old.png"));
  }

  if (diff) {
    fs.writeFileSync(path.join(outputPath, "diff.png"), PNG.sync.write(diff));
  }
};

for (const filename of fs.readdirSync(artifactsDirectory)) {
  if (!filename.startsWith("test_artifacts")) {
    continue;
  }

  const fullPath = path.join(artifactsDirectory, filename, "screenshots_new");

  const fullPathStat = fs.statSync(fullPath);
  if (!fullPathStat.isDirectory()) {
    continue;
  }

  for (const screenshotName of fs.readdirSync(fullPath)) {
    if (knownFailures.has(screenshotName)) {
      continue;
    }

    const fullPathScreenshotName = path.join(fullPath, screenshotName);

    const fullPathCompareScreenshot = path.join(
      screenshotsDirectory,
      screenshotName,
    );
    if (!fs.existsSync(fullPathCompareScreenshot)) {
      console.error(
        `${fullPathCompareScreenshot} is missing an existing screenshot to compare against`,
      );
      fail(screenshotName, fullPathScreenshotName);
      continue;
    }

    const screenshotNew = PNG.sync.read(
      fs.readFileSync(fullPathScreenshotName),
    );
    const screenshotCompare = PNG.sync.read(
      fs.readFileSync(fullPathCompareScreenshot),
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
  process.exit(1);
}
