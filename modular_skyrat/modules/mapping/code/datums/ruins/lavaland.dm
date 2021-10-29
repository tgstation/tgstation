/*----- Template for ruins, prevents needing to re-type the filepath prefix -----*/
/datum/map_template/ruin/lavaland/skyrat/
	prefix = "modular_skyrat/modules/mapping/_maps/RandomRuins/LavaRuins/"
/*------*/

/datum/map_template/ruin/lavaland/skyrat/syndicate_base
	name = "Syndicate Lava Base"
	id = "lava-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "lavaland_surface_syndicate_base1_skyrat.dmm"
	allow_duplicates = FALSE
	never_spawn_with = list(/datum/map_template/ruin/icemoon/underground/skyrat/syndicate_base, /datum/map_template/ruin/rockplanet/syndicate_base)
	always_place = TRUE
