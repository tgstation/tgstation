import Juke from "../juke/index.js";

let yarnPath;

export const yarn = (...args) => {
  if (!yarnPath) {
    yarnPath = Juke.glob("./tgui/.yarn/releases/*.cjs")[0].replace(
      "/tgui/",
      "/",
    );
  }
  return Juke.exec(
    "node",
    [yarnPath, ...args.filter((arg) => typeof arg === "string")],
    {
      cwd: "./tgui",
    },
  );
};
