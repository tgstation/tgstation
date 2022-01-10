// Unlike species and others, feature files export arrays of features
// rather than individual ones. This is because a lot of features are
// extremely small, and so it's easier for everyone to just combine them
// together.
// This still helps to prevent the server from needing to send client UI data
import { Feature } from "./base";

// while also preventing downstreams from needing to mutate existing files.
const features: Record<string, Feature<unknown>> = {};

const requireFeature = require.context("./", true, /.tsx$/);

for (const key of requireFeature.keys()) {
  if (key === "index" || key === "base") {
    continue;
  }

  for (const [featureKey, feature] of Object.entries(requireFeature(key))) {
    features[featureKey] = feature as Feature<unknown>;
  }
}

export default features;
