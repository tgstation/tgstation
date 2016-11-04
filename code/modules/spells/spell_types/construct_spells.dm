//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	action_icon_state = "artificer"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser/cult
	cult_req = 1
	charge_max = 2500

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor"

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/open/floor/engine/cult)
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall"

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon_state = "lesserconstruct"
	action_background_icon_state = "bg_cult"

	summon_type = list(/turf/closed/wall/mineral/cult/artificer) //we don't want artificer-based runed metal farms


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/turf/closed/wall/r_wall)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_demon"

	summon_type = list(/obj/item/device/soulstone)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/cult
	cult_req = 1
	charge_max = 4000

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/noncult
	summon_type = list(/obj/item/device/soulstone/anybody)



/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	school = "transmutation"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	jaunt_duration = 50 //in deciseconds
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_demon"
	jaunt_in_time = 12
	jaunt_in_type = /obj/effect/overlay/temp/dir_setting/wraith
	jaunt_out_type = /obj/effect/overlay/temp/dir_setting/wraith/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return

/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 400
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	proj_lifespan = 10
	max_targets = 6
	action_icon_state = "magicm"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/targeted/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."

	school = "conjuration"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 3
	smoke_amt = 4
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"
