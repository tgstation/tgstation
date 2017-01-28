/proc/is_servant_of_wizard(mob/living/U, mob/living/M)
	for(var/R in M.faction)
		if(R == U)
			return M && istype(M) && M.mind
		else
			for(var/RM in U.faction)
				if(RM == R && RM != "neutral" && R != "neutral")
					return  M && istype(M) && M.mind
	return 0

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/communicate_wizard(null))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone(null))
	return .

/datum/spellbook_entry/item/soulstones
	cost = 3
	limit = 1

/obj/effect/proc_holder/spell/aoe_turf/communicate_wizard
	name = "Communicate"
	desc = "This spell communicates with wizard and his servents."
	charge_max = 5

/obj/effect/proc_holder/spell/aoe_turf/communicate_wizard/cast(mob/living/user, message)
	message = sanitize_russian(stripped_input(usr, "Please choose a message to tell to the servants and wizard.", "Voice of Magic", ""))
	if(!message)
		return
	sleep(10)
	if(!user)
		return
	if(!ishuman(user))
		user.say(message)
	else
		user.whisper(message)
	var/my_message = "<span class='purple'><b>[(ishuman(user) ? "Wizard" : "Servant")] [user]:</b> [message]</span>"
	for(var/mob/M in mob_list)
		if(is_servant_of_wizard(user, M))
			M << my_message
		else if(M in dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			M << "[link] [my_message]"

	log_say("[user.real_name]/[user.key] : [message]")