import { multiline } from "common/string";
import { FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput } from "../base";

export const screentip_color: Feature<string> = {
  name: "Screentips color",
  category: "UI",
  description: multiline`
    The color of screen tips, the text you see when hovering over something.
  `,
  component: FeatureColorInput,
};

export const screentip_pref: FeatureChoiced = {
  name: "Enable screentips",
  category: "UI",
  description: multiline`
    Enables screen tips, the text you see when hovering over something.
    When set to "Only with tips", will only show when there is more information
    than just the name, such as what right-clicking it does.
  `,
  component: FeatureDropdownInput,
};
