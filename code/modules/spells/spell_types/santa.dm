//Santa spells!
/obj/effect/proc_holder/spell/aoe_turf/conjure/presents
	name = "Conjure Presents!"
	desc = "This spell lets you reach into S-space and retrieve presents! Yay!"
	school = "santa"
	charge_max = 600
	clothes_req = 0
	invocation = "HO HO HO"
	invocation_type = "shout"
	range = 3
	cooldown_min = 50

	summon_type = list("/obj/item/a_gift")
	summon_lifespan = 0
	summon_amt = 5

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/santa
	name = "Teleport"
	invocation = "REINDEER AWAY! TO THE"
	clothes_req = FALSE

/obj/effect/proc_holder/spell/targeted/conjure_item/minor_christmas_gift
	name = "Make Minor Christmas Present"
	desc = "Summons a wrapped minor present and puts it in your hand."
	item_type = /obj/item/a_gift
	invocation = "HO HO HO"
	only_one = FALSE
	charge_max = 1 MINUTES

/obj/effect/proc_holder/spell/targeted/conjure_item/wild_christmas_gift
	name = "Make Wild Christmas Present"
	desc = "Summons a wrapped present that could be almost anything, and puts it in your hand."
	item_type = /obj/item/a_gift/anything
	invocation = "HO HO HO"
	only_one = FALSE
	charge_max = 2 MINUTES
