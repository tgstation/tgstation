import { Material, MATERIAL_KEYS } from '../common/Materials';

/**
 * A named material.
 */
export type MaterialName = keyof typeof MATERIAL_KEYS;

/**
 * A map of keyed materials to a quantity.
 */
export type MaterialMap = Partial<Record<MaterialName, number>>;

/**
 * A single design that the fabricator can print.
 */
export type Design = {
  /**
   * The name of the design.
   */
  name: string;

  /**
   * A human-readable description of the design.
   */
  desc: string;

  /**
   * The individual material cost to print the design, adjusted for the
   * fabricator's part efficiency.
   */
  cost: MaterialMap;

  /**
   * A reference to the design's design datum.
   */
  id: string;

  /**
   * The categories the design should be present in. Subcategories are
   * slash-delimited, and categories always start with a slash.
   */
  categories: string[];

  /**
   * The icon used to represent this design, generated in
   * /datum/asset/spritesheet/research_designs. **The image within may not be
   * 32x32.**
   */
  icon: string;

  /**
   * The amount of time, in seconds, that this design takes to print.
   */
  constructionTime: number;
};

/**
 * The static and dynamic data made available to a fabricator UI.
 */
export type FabricatorData = {
  /**
   * The materials available to the fabricator, via ore silo or local storage.
   */
  materials: Material[];

  /**
   * The name of the fabricator, as displayed on the title bar.
   */
  fabName: string;

  /**
   * Whether mineral access is disabled from the ore silo (contact the
   * quartermaster).
   */
  onHold: boolean;

  /**
   * The set of designs that this fabricator can print, indexed by their ID.
   */
  designs: Record<string, Design>;

  /**
   * Whether the fabricator is currently printing an item.
   */
  busy: boolean;

  /**
   * The maximum quantity of material that the fabricator can hold, or `-1`
   * if the fabricator can hold infinitely many materials (such as the ore
   * silo).
   */
  materialMaximum: number;

  /**
   * The fabricator's current queue.
   */
  queue: {
    /**
     * The job ID for this queued job. This is always unique, and can be used
     * as a `key`.
     */
    jobId: number;

    /**
     * The design ID being printed. Available in `super.designs`.
     */
    designId: string;

    /**
     * If `true`, this design is currently being fabricated, and `timeLeft`
     * is actively decreasing.
     */
    processing: boolean;

    /**
     * The time left in this design's fabrication, in seconds.
     */
    timeLeft: number;
  }[];
};
