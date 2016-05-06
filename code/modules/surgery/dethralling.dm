/datum/surgery/remove_thrall
	name = "dethralling"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/dethrall)
	possible_locs = list("head")

/datum/surgery/remove_thrall/can_start(mob/user, mob/living/carbon/target)
	return is_thrall(target)

/datum/surgery_step/dethrall
	name = "cleanse contamination"
	implements = list(/obj/item/device/assembly/flash = 100, /obj/item/device/flashlight/pen = 80, /obj/item/device/flashlight = 40)
	time = 30

/datum/surgery_step/dethrall/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] reaches into [target]'s head with [tool].", "<span class='notice'>You begin aligning [tool]'s light to the tumor on [target]'s brain...</span>")

/datum/surgery_step/dethrall/success(mob/user, mob/living/carbon/target, target_zone, datum/surgery/surgery)
	if(target.dna.species.id == "l_shadowling") //Empowered thralls cannot be deconverted
		target << "<span class='shadowling'><b><i>NOT LIKE THIS!</i></b></span>"
		user.visible_message("<span class='danger'>[target] suddenly slams upward and knocks down [user]!</span>", \
							 "<span class='userdanger'>[target] suddenly bolts up and slams you with tremendous force!</span>")
		user.resting = 0 //Remove all stuns
		user.SetSleeping(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.SetParalysis(0)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Weaken(6)
			C.apply_damage(20, "brute", "chest")
		else if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Weaken(8)
			S.apply_damage(20, "brute")
			playsound(S, 'sound/effects/bang.ogg', 50, 1)
		return 0
	user.visible_message("[user] shines light onto the tumor in [target]'s head!", "<span class='notice'>You cleanse the contamination from [target]'s brain!</span>")
	ticker.mode.remove_thrall(target.mind, 0)
	target.visible_message("<span class='warning'>A strange black mass falls from [target]'s head!</span>")
	new /obj/item/organ/internal/shadowtumor(get_turf(target))
	return 1
