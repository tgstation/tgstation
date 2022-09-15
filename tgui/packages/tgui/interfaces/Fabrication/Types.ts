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
   * The categories the design should be present in.
   */
  categories?: string[];

  /**
   * The icon used to represent this design, generated in
   * /datum/asset/spritesheet/research_designs, if any. **The image may not be
   * 32x32; make sure to scale it accordingly.**
   */
  icon: string;
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
  fab_name: string;

  /**
   * Whether mineral access is disabled from the ore silo (contact the
   * quartermaster).
   */
  on_hold: boolean;

  /**
   * The set of designs that this fabricator can print, indexed by their ID.
   */
  designs: Record<string, Design>;

  /**
   * Whether the fabricator is currently printing an item.
   */
  busy: boolean;

  /**
   * If nonzero, the maximum quantity of material that the fabricator can hold.
   * Typically present with local storage is enabled (e.g, disconnected from
   * the ore silo).
   */
  materialMaximum: number;
};
