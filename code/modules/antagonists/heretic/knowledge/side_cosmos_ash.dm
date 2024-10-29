// Sidepaths for knowledge between Cosmos and Ash.

/datum/heretic_knowledge/summon/fire_shark
	name = "Scorching Shark"
	desc = "Allows you to transmute a pool of ash, a liver, and a sheet of plasma into a Fire Shark. \
		Fire Sharks are fast and strong in groups, but die quickly. They are also highly resistant against fire attacks. \
		Fire Sharks inject phlogiston into its victims and spawn plasma once they die."
	gain_text = "The cradle of the nebula was cold, but not dead. Light and heat flits even through the deepest darkness, and is hunted by its own predators."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cosmic_runes,
		/datum/heretic_knowledge/spell/ash_passage,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/fire_shark
	cost = 1
	route = PATH_SIDE
	poll_ignore_define = POLL_IGNORE_FIRE_SHARK
	depth = 4
	research_tree_icon_dir = EAST

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/star_blast,
		/datum/heretic_knowledge/mad_mask,
	)
	spell_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 1
	route = PATH_SIDE
	depth = 8
	research_tree_icon_frame = 6

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma and a diamond to create an Eldritch Coin. \
		The coin will open or close nearby doors when landing on heads and toggle their bolts \
		when landing on tails. If you insert the coin into an airlock, it will be consumed \
		to fry its electronics, opening the airlock permanently unless bolted. "
	gain_text = "The Mansus is a place of all sorts of sins. But greed held a special role."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cosmic_expansion,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	route = PATH_SIDE
	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"
	depth = 10
