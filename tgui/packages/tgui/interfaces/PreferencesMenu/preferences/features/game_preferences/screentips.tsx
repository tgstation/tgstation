import { multiline } from "common/string";
import { FeatureColorInput, Feature } from "../base";

export const screentip_color: Feature<string> = {
  name: "Screentips color",
  category: "UI",
  description: multiline`
    The color of screen tips, the text you see when hovering over something.
  `,
  component: FeatureColorInput,
};
