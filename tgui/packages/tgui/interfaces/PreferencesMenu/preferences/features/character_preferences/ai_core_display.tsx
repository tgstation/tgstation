import { Feature, FeatureChoicedServerData, FeatureIconnedDropdownInput } from "../base";

export const preferred_ai_core_display: Feature<
  { value: string },
  string,
  FeatureChoicedServerData,
> = {
  name: "AI core display",
  component: FeatureIconnedDropdownInput,
};
