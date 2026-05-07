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
	///is this ruin "enclosed" by walls. This is relevant for terrain gen with cellular automata to know whether this ruin will spawn inside of walls, or should spawn in the open.
	var/enclosed_for_terrain = FALSE
	///Padding to be used to ensure extra space around the ruin for terrain gen purposes. If a ruin is NOT enclosed and this is set to 1; there will be at least one layer of open terrain around the ruin. If a ruin IS enclosed and this is set to 1; there will be at least one layer of wall terrain around the ruin.
	var/terrain_padding = 0

/datum/map_template/ruin/New()
	if(!name && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)

