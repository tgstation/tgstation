/obj/item/implant/spell/specified_type
	var/spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee/buzzon

/obj/item/implant/spell/specified_type/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	spell = new spell_type()
	. = ..()


/obj/item/implant/spell/specified_type/bees
	name = "bluespace bee storage implant"
	desc = "Allows user to create swarms of bees on will."

/obj/item/implant/spell/specified_type/bees/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Bluespace Bee Storage Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Allows user to create swarms of bees on will."}
	return dat

/obj/item/implant/spell/specified_type/bees/cryo
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee/buzzon/cryo

/obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee/buzzon
	name = "Activate BBS implant"
	desc = "Activate BBS implant to summon a swarm of bees. Attention: The bees are hostile to everyone."
	clothes_req = FALSE
	invocation = "Bees, deploy!"
	clear_invocation = TRUE
	summon_amt = 5	//Bees are very, very annoying to deal with so only 5
	action_icon_state = "bee"
	cooldown_min = 20 SECONDS

	summon_type = /mob/living/simple_animal/hostile/bee/toxin_type

/obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee/buzzon/cryo
	summon_type = /mob/living/simple_animal/hostile/bee/toxin_type/cryo