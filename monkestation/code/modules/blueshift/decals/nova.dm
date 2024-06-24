/obj/effect/turf_decal/stripes/blue
	icon_state = "warningline_blue"
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'

/obj/effect/turf_decal/stripes/blue/line
	icon_state = "warningline_blue"

/obj/effect/turf_decal/stripes/blue/end
	icon_state = "warn_end_blue"

/obj/effect/turf_decal/stripes/blue/corner
	icon_state = "warninglinecorner_blue"

/obj/effect/turf_decal/stripes/blue/box
	icon_state = "warn_box_blue"

/obj/effect/turf_decal/stripes/blue/full
	icon_state = "warn_full_blue"

/obj/effect/turf_decal/bot_blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "bot_blue"

/obj/effect/turf_decal/caution/stand_clear/blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "stand_clear_blue"

/obj/effect/turf_decal/arrows/blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "arrows_blue"

/obj/effect/turf_decal/box/blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "box_blue"

/obj/effect/turf_decal/box/blue/corners
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "box_corners_blue"


/obj/effect/turf_decal/delivery/blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "delivery_blue"

/obj/effect/turf_decal/caution/blue
	icon = 'monkestation/code/modules/blueshift/icons/turf_decals.dmi'
	icon_state = "caution_blue"


// Adds red variant that doesnt break 'bluesec' but allows mappers to use red elsewhere

/obj/effect/turf_decal/siding/red/real_red
	color = "#DE3A3A"

/obj/effect/turf_decal/siding/red/real_red/corner
	icon_state = "siding_corner"

/obj/effect/turf_decal/siding/red/real_red/end
	icon_state = "siding_end"

/// To make upstream mapping easier we overwrote the color for Red to be not red but blue for our weird bluesec
/// This re-adds a red coloring to be used by mappers in other areas.

/// Real Red Tiles

/obj/effect/turf_decal/tile/red/real_red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/red/real_red/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing red corners"

/obj/effect/turf_decal/tile/red/real_red/half
	icon_state = "tile_half"
	name = "red half"

/obj/effect/turf_decal/tile/red/real_red/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted red half"

/obj/effect/turf_decal/tile/red/real_red/anticorner
	icon_state = "tile_anticorner"
	name = "red anticorner"

/obj/effect/turf_decal/tile/red/real_red/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted red anticorner"

/obj/effect/turf_decal/tile/red/real_red/fourcorners
	icon_state = "tile_fourcorners"
	name = "red fourcorners"

/obj/effect/turf_decal/tile/red/real_red/full
	icon_state = "tile_full"
	name = "red full"

/obj/effect/turf_decal/tile/red/real_red/diagonal_centre
	icon_state = "diagonal_centre"
	name = "red diagonal centre"

/obj/effect/turf_decal/tile/red/real_red/diagonal_edge
	icon_state = "diagonal_edge"
	name = "red diagonal edge"

/// Real Red Trimlines

/obj/effect/turf_decal/trimline/red/real_red
	color = "#DE3A3A"

/obj/effect/turf_decal/trimline/red/real_red/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/red/real_red/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/red/real_red/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/red/real_red/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/red/real_red/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/red/real_red/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/red/real_red/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/red/real_red/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/red/real_red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/red/real_red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/nova_decals
	icon = 'monkestation/code/modules/blueshift/icons/turf/turf_decals.dmi'
	icon_state = "bad_coder"

/obj/effect/decal/fakelattice/passthru	//Why the hell did TG make it dense anyways
	density = FALSE

/obj/effect/decal/fakelattice/passthru/NeverShouldHaveComeHere(turf/here_turf)
	return !isclosedturf(here_turf) && ..()

///SYNDICATE EMBLEM///
//Bottom
/obj/effect/turf_decal/nova_decals/syndicate/bottom/left
	icon_state = "1,1"

/obj/effect/turf_decal/nova_decals/syndicate/bottom/middle
	icon_state = "1,2"

/obj/effect/turf_decal/nova_decals/syndicate/bottom/right
	icon_state = "1,3"
//Middle
/obj/effect/turf_decal/nova_decals/syndicate/middle/left
	icon_state = "2,1"

/obj/effect/turf_decal/nova_decals/syndicate/middle/middle
	icon_state = "2,2"

/obj/effect/turf_decal/nova_decals/syndicate/middle/right
	icon_state = "2,3"
//Top
/obj/effect/turf_decal/nova_decals/syndicate/top/left
	icon_state = "3,1"

/obj/effect/turf_decal/nova_decals/syndicate/top/middle
	icon_state = "3,2"

/obj/effect/turf_decal/nova_decals/syndicate/top/right
	icon_state = "3,3"

///ENCLAVE EMBLEM///
/obj/effect/turf_decal/nova_decals/enclave
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	color = "#A46106"
//Bottom
/obj/effect/turf_decal/nova_decals/enclave/bottom/left
	icon_state = "e1,1"

/obj/effect/turf_decal/nova_decals/enclave/bottom/middle
	icon_state = "e1,2"

/obj/effect/turf_decal/nova_decals/enclave/bottom/right
	icon_state = "e1,3"
//Middle
/obj/effect/turf_decal/nova_decals/enclave/middle/left
	icon_state = "e2,1"

/obj/effect/turf_decal/nova_decals/enclave/middle/middle
	icon_state = "e2,2"

/obj/effect/turf_decal/nova_decals/enclave/middle/right
	icon_state = "e2,3"
//Top
/obj/effect/turf_decal/nova_decals/enclave/top/left
	icon_state = "e3,1"

/obj/effect/turf_decal/nova_decals/enclave/top/middle
	icon_state = "e3,2"

/obj/effect/turf_decal/nova_decals/enclave/top/right
	icon_state = "e3,3"

///Departments///
/obj/effect/turf_decal/nova_decals/departments/bridge
	icon_state = "bridge"

///DS-2 Sign///
/obj/effect/turf_decal/nova_decals/ds2/left
	icon_state = "ds1"

/obj/effect/turf_decal/nova_decals/ds2/middle
	icon_state = "ds2"

/obj/effect/turf_decal/nova_decals/ds2/right
	icon_state = "ds3"

///Misc///
/obj/effect/turf_decal/nova_decals/misc/handicapped
	icon_state = "handicapped"

/obj/structure/sign/shuttleg250
	name = "Transfer Shuttle G250"
	desc = "Transfer Shuttle G250."
	icon = 'monkestation/code/modules/blueshift/icons/g250.dmi' //LARGE icon
	icon_state = "g250"

/obj/structure/fans/tiny/forcefield
	name = "forcefield"
	desc = "A fluctuating forcefield for ships to cross."
	icon = 'monkestation/code/modules/blueshift/icons/effects.dmi'
	icon_state = "forcefield"

//Floor Decals -----
/obj/effect/turf_decal/shuttle/exploration
	icon = 'monkestation/code/modules/blueshift/icons/exploration_floor.dmi'
	icon_state = "decal1"

/obj/effect/turf_decal/shuttle/exploration/medbay
	icon_state = "decalmed"

/obj/effect/turf_decal/shuttle/exploration/cargostore
	icon_state = "decalstore"

/obj/effect/turf_decal/shuttle/exploration/bridge
	icon_state = "decalbridge"

/obj/effect/turf_decal/shuttle/exploration/o2
	icon_state = "decalo2"

/obj/effect/turf_decal/shuttle/exploration/typhon
	icon_state = "decal2"

/obj/effect/turf_decal/shuttle/exploration/echidna
	icon_state = "decal1"

/obj/effect/turf_decal/shuttle/exploration/weapons
	icon_state = "decal3"

/obj/effect/turf_decal/shuttle/exploration/airlock
	icon_state = "decal4"

/obj/effect/turf_decal/shuttle/exploration/hazardstripe
	icon_state = "hazard_decal"

/obj/effect/turf_decal/shuttle/exploration/bot
	icon_state = "bot_decal"
