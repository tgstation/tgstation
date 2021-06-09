import { Stack } from "../../components";
import { Species, fallbackSpecies } from "./preferences/species/base";

// MOTHBLOCKS TODO: Derive this
const SPECIES = ["human", "moth", "lizard"];

const requireSpecies = require.context("./preferences/species");

export const SpeciesPage = (props, context) => {
  return (
    <Stack fill>
      <Stack.Item />
    </Stack>
  );
};
