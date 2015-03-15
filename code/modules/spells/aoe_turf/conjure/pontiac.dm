// Also called the firebird. Included here for people who want to find this spell

/spell/aoe_turf/conjure/pontiac
	name = "Chariot"
	desc = "This spell summons a glorious, flaming chariot that can move in space."

	charge_type = Sp_CHARGES
	charge_max = 1
	school = "conjuration"
	spell_flags = Z2NOCAST
	invocation = "NO F'AT C'HX"
	invocation_type = SpI_SHOUT
	range = 0

	summon_type = list(/obj/structure/stool/bed/chair/vehicle/wizmobile)
	duration = 0

	hud_state = "wiz_mobile"
