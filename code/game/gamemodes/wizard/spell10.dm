/client/proc/mutate()
	set category = "Spells"
	set name = "Mutate"
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
	usr.verbs -= /client/proc/mutate
	spawn(400)
		usr.verbs += /client/proc/mutate
	usr.say("BIRUZ BENNAR")
	usr << text("\blue You feel strong! Your mind expands!")
	if (!(usr.mutations & 8))
		usr.mutations |= 8
	if (!(usr.mutations & 1))
		usr.mutations |= 1
	spawn (300)
		if (usr.mutations & 1) usr.mutations &= ~1
		if (usr.mutations & 8) usr.mutations &= ~8
	return
