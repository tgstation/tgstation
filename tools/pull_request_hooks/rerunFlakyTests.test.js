import { strict as assert } from "node:assert";
import fs from "node:fs";
import { extractDetails } from "./rerunFlakyTests.js";

function extractDetailsFromPayload(filename) {
  return extractDetails(
    fs.readFileSync(`tests/flakyTestPayloads/${filename}.txt`, {
      encoding: "utf8",
    })
  );
}

const chatClient = extractDetailsFromPayload("chat_client");
assert.equal(
  chatClient.title,
  "Flaky test create_and_destroy: /datum/computer_file/program/chatclient hard deleted 1 times out of a total del count of 13"
);
assert.equal(chatClient.failures.length, 1);

const monkeyBusiness = extractDetailsFromPayload("monkey_business");
assert.equal(
  monkeyBusiness.title,
  "Flaky test monkey_business: Cannot execute null.resolve()."
);
assert.equal(monkeyBusiness.failures.length, 1);

const shapeshift = extractDetailsFromPayload("shapeshift");
assert.equal(
  shapeshift.title,
  "Multiple errors in flaky test shapeshift_spell"
);
assert.equal(shapeshift.failures.length, 16);

const multipleFailures = extractDetailsFromPayload("multiple_failures");
assert.equal(
  multipleFailures.title,
  "Multiple flaky test failures in more_shapeshift_spell, shapeshift_spell"
);
assert.equal(multipleFailures.failures.length, 2);
