/obj/effect/proc_holder/changeling/pop_off_limbs
	name = "Detach Limb"
	desc = "Allows us to cause limbs to fall off."
	helptext = "Is <i>extremely</i> obvious to nearby crewmembers!"
	chemical_cost = 10
	dna_cost = 0
	req_stat = UNCONSCIOUS
	always_keep = TRUE

/obj/effect/proc_holder/changeling/pop_off_limbs/sting_action(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	var/obj/item/bodypart/what_to_detach = input(C, "Select which limb to detach") as null|anything in (C.bodyparts - (locate(/obj/item/bodypart/chest) in C.bodyparts)) //if there's a better way to do this, let me know
	if(!what_to_detach)
		to_chat(C, "<span class='notice'>We decide against detaching a limb for now.</span>")
	else
		C.visible_message("<span class='danger bold'>[C]'s [what_to_detach] falls off!</span>")
		what_to_detach.dismember(silent = TRUE)
		what_to_detach.animate_atom_living(C)