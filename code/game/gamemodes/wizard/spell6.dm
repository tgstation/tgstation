/obj/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon = 'mob.dmi'
	icon_state = "shield"
	anchored = 1.0
	opacity = 0
	density = 1

/client/proc/forcewall()

	set category = "Spells"
	set name = "Forcewall"
	set desc = "Create a forcewall on your location."
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return
	usr.verbs -= /client/proc/forcewall
	spawn(100)
		usr.verbs += /client/proc/forcewall
	var/forcefield
	var/mob/living/carbon/human/G = usr
	G.say("TARCOL MINTI ZHERI")
	if(!usr.miming)
		if(usr.gender=="male")
			playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
		else
			playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)
	forcefield =  new /obj/forcefield(locate(usr.x,usr.y,usr.z))
	spawn (300)
		del (forcefield)
	return
