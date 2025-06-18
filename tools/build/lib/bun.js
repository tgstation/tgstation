import Juke from "../juke/index.js";
import { mkdirSync } from "node:fs";

let hasInstallFolder = false;

export function bun(...args) {
  if (!hasInstallFolder) {
    mkdirSync("./tgui/node_modules/", { recursive: true });
    hasInstallFolder = true;
  }

  return Juke.exec("bun", [...args.filter((arg) => typeof arg === "string")], {
    cwd: "./tgui",
    shell: true,
  });
}
