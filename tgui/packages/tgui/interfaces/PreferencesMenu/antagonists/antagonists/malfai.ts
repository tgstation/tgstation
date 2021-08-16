import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const MALF_AI_MECHANICAL_DESCRIPTION
  = multiline`
    With a law zero to complete your objectives at all costs, combine your
    omnipotence and malfunction modules to wreak havoc across the station.
    Go delta to destroy the station and all those who opposed you.
  `;

const MalfAI: Antagonist = {
  key: "malfai",
  name: "Malfunctioning AI",
  description: [
    MALF_AI_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default MalfAI;
