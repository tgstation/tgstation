/client/proc/blind(mob/M as mob in oview())
	set category = "Spells"
	set name = "Blind"
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
	usr.verbs -= /client/proc/blind
	spawn(300)
		usr.verbs += /client/proc/blind
	usr.say("STI KALY!")
	var/obj/overlay/B = new /obj/overlay( M.loc )
	B.icon_state = "blspell"
	B.icon = 'wizard.dmi'
	B.name = "spell"
	B.anchored = 1
	B.density = 0
	B.layer = 4
	M.canmove = 0
	spawn(5)
		del(B)
		M.canmove = 1
	M << text("\blue Your eyes cry out in pain!")
	M.disabilities |= 1
	spawn(300)
		M.disabilities &= ~1
	M.eye_blind = 10
	M.eye_blurry = 20
	return
