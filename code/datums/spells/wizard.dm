/obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 150
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7

	max_targets = 0

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile
	amt_weakened = 5
	amt_dam_fire = 10

/obj/effect/proc_holder/spell/targeted/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "\blue You feel strong! You feel a pressure building behind your eyes!"
	range = -1
	include_user = 1

	mutations = LASER | HULK
	duration = 300

/obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1

	destroys = "gib"

	sparks_spread = 1
	sparks_amt = 4

/obj/effect/proc_holder/spell/targeted/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	smoke_spread = 2
	smoke_amt = 10

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	range = -1
	include_user = 1

	emp_heavy = 5
	emp_light = 7

/obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	smoke_spread = 1
	smoke_amt = 10

	inner_tele_radius = 0
	outer_tele_radius = 6

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	range = -1
	include_user = 1

	smoke_spread = 1
	smoke_amt = 5

/obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	range = 0

	summon_type = list("/obj/effect/forcefield")
	summon_lifespan = 300


/obj/effect/proc_holder/spell/aoe_turf/conjure/carp
	name = "Summon Bigger Carp"
	desc = "This spell conjures an elite carp."

	school = "conjuration"
	charge_max = 1200
	clothes_req = 1
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"
	range = 1

	summon_type = list("/obj/effect/critter/spesscarp/elite")


/obj/effect/proc_holder/spell/aoe_turf/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = "conjuration"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/obj/structure/constructshell")


/obj/effect/proc_holder/spell/aoe_turf/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	charge_max = 1200
	clothes_req = 0
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10
	range = 3

	summon_type = list("/obj/effect/critter/creature")

/obj/effect/proc_holder/spell/targeted/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "\blue Your eyes cry out in pain!"

	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/blind","/obj/effect/proc_holder/spell/targeted/genetic/blind")

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20

/obj/effect/proc_holder/spell/targeted/genetic/blind
	disabilities = 1
	duration = 300

/obj/effect/proc_holder/spell/targeted/projectile/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	charge_max = 200
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"

	proj_icon_state = "fireball"
	proj_name = "a fireball"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/trigger/fireball"

	proj_lifespan = 200
	proj_step_delay = 1

/obj/effect/proc_holder/spell/targeted/trigger/fireball
	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/fireball","/obj/effect/proc_holder/spell/targeted/explosion/fireball")

/obj/effect/proc_holder/spell/targeted/inflict_handler/fireball
	amt_dam_brute = 20
	amt_dam_fire = 25

/obj/effect/proc_holder/spell/targeted/explosion/fireball
	ex_severe = -1
	ex_heavy = -1
	ex_light = 2
	ex_flash = 5






//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Floor Construction"
	desc = "This spell constructs a cult floor"

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/turf/simulated/floor/engine/cult")

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Leser Construction"
	desc = "This spell constructs a cult wall"

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/turf/simulated/wall/cult")

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/turf/simulated/wall/r_wall")

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/obj/item/device/soulstone")


/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/obj/effect/forcefield")
	summon_lifespan = 50




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
	phaseshift = 1
	jaunt_duration = 50 //in deciseconds
