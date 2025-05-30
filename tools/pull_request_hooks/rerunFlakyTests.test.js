import { strict as assert } from "node:assert";
import fs from "node:fs";
import { extractDetails } from "./rerunFlakyTests.js";

function extractDetailsFromPayload(filename) {
  return extractDetails(
    fs.readFileSync(`tests/flakyTestPayloads/${filename}.txt`, {
      encoding: "utf8",
    }),
  );
}

const chatClient = extractDetailsFromPayload("chat_client");
assert.equal(
  chatClient.title,
  "Flaky hard delete: /datum/computer_file/program/chatclient",
);
assert.equal(chatClient.failures.length, 1);

const monkeyBusiness = extractDetailsFromPayload("monkey_business");
assert.equal(
  monkeyBusiness.title,
  "Flaky test monkey_business: Cannot execute null.resolve().",
);
assert.equal(monkeyBusiness.failures.length, 1);

const shapeshift = extractDetailsFromPayload("shapeshift");
assert.equal(
  shapeshift.title,
  "Multiple errors in flaky test shapeshift_spell",
);
assert.equal(shapeshift.failures.length, 16);

const multipleFailures = extractDetailsFromPayload("multiple_failures");
assert.equal(
  multipleFailures.title,
  "Multiple flaky test failures in more_shapeshift_spell, shapeshift_spell",
);
assert.equal(multipleFailures.failures.length, 2);

const invalidTimer = extractDetailsFromPayload("invalid_timer");
assert.equal(
  invalidTimer.title,
  "Flaky test monkey_business: Invalid timer: /datum/looping_sound/proc/start_sound_loop() on /datum/looping_sound/showering",
);
