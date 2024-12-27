/datum/map_template/ruin
	//name = "A Chest of Doubloons"
	name = null
	var/id = null // For blacklisting purposes, all ruins need an id
	var/description = "In the middle of a clearing in the rockface, there's a chest filled with gold coins with Spanish engravings. \
	How is there a wooden container filled with 18th century coinage in the middle of a lavawracked hellscape? \
	It is clearly a mystery."

	///If TRUE these won't be placed automatically (can still be forced or loaded with another ruin)
	var/unpickable = FALSE
	///Will skip the whole weighting process and just plop this down, ideally you want the ruins of this kind to have no cost.
	var/always_place = FALSE
	///How often should this ruin appear
	var/placement_weight = 1
	///Cost in ruin budget placement system
	var/cost = 0
	/// Cost in the ruin budget placement system associated with mineral spawning. We use a different budget for mineral sources like ore vents. For practical use see seedRuins
	var/mineral_cost = 0
	/// If TRUE, this ruin can be placed multiple times in the same map
	var/allow_duplicates = TRUE
	///These ruin types will be spawned along with it (where dependent on the flag) eg list(/datum/map_template/ruin/space/teleporter_space = SPACERUIN_Z)
	var/list/always_spawn_with = null
	///If this ruin is spawned these will not eg list(/datum/map_template/ruin/base_alternate)
	var/list/never_spawn_with = null
	///Static part of the ruin path eg "_maps\RandomRuins\LavaRuins\"
	var/prefix = null
	///The dynamic part of the ruin path eg "lavaland_surface_ruinfile.dmm"
	var/suffix = null
	///What flavor or ruin is this? eg ZTRAIT_SPACE_RUINS
	var/ruin_type = null

/datum/map_template/ruin/New()
	if(!name && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)

