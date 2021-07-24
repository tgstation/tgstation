/**
 * This folder represents the antagonists you can choose in the preferences
 * menu.
 *
 * Every file in this folder represents one antagonist. The filename matters--
 * it is the antag_flag, made lowercase, and with non-alphanumerics removed.
 *
 * For example "Syndicate Sleeper Agent" -> syndicatesleeperagent.ts
 *
 * "Antagonist" in this context actually means ruleset.
 * This is an important distinction--it means that players can choose to be
 * a roundstart traitor, but not a latejoin traitor.
 *
 * Icons are generated from the antag datums themselves, provided by the
 * `antag_datum` variable on the /datum/dynamic_ruleset.
 *
 * The icon used is whatever the return value of get_preview_icon() is.
 * Most antagonists, unless they want an especially cool effect, can simply
 * set preview_outfit to some typepath representing their character.
 */

export type Antagonist = {
  name: string;
  description: string[];
  category: Category,
};

enum Category {
  Roundstart,
  Midround,
  Latejoin,
}
