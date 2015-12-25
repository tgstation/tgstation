/spell/aoe_turf/conjure/snowmobile
	name = "Summon Snowmobile"
	desc = "Time to Sleigh some No-gooders."

	charge_type = Sp_CHARGES
	charge_max = 1
	school = "conjuration"
	spell_flags = Z2NOCAST
	invocation = "How much did Santa pay for his sleigh? Nothing, it was on the house!"
	invocation_type = SpI_SHOUT
	range = 0

	summon_type = list(/obj/structure/bed/chair/vehicle/wizmobile/santa)
	duration = 0

	hud_state = "snowmobile"