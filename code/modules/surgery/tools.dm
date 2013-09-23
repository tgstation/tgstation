/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	m_amt = 10000
	g_amt = 5000
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/retractor/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is holding \his [pick("nose", "throat")] with the [src.name]! It looks like \he's trying to commit suicide!</b>"
	return (OXYLOSS)


/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	m_amt = 5000
	g_amt = 2500
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")

/obj/item/weapon/hemostat/suicide_act(mob/living/carbon/user)
	viewers(user) << "\red <b>[user] is pinching \himself in the jugular vein with the [src.name]! It looks like \he's trying to commit suicide!</b>"
	var/turf/simulated/L = get_turf(user)
	L.add_blood(user)
	return (BRUTELOSS)

/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	m_amt = 5000
	g_amt = 2500
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")

/obj/item/weapon/cautery/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is burning \himself with the [src.name]! It looks like \he's trying to commit suicide!</b>"
	return (FIRELOSS)


/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	m_amt = 15000
	g_amt = 10000
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 3.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

/obj/item/weapon/surgicaldrill/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is pressing [src] to \his [pick("temple", "chest", "eyes")] and activating it! It looks like \he's trying to commit suicide.</b>"
	playsound(user, src.hitsound, 50, 1)
	return (BRUTELOSS)


/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/scalpel/suicide_act(mob/user)
	viewers(user) << pick("\red <b>[user] is slitting \his [pick("wrists", "throat")] with [src]! It looks like \he's trying to commit suicide.</b>", \
						"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
	return (BRUTELOSS)


/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 3.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")

/obj/item/weapon/circular_saw/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is using the [src.name] to slice off \his [pick("arm", "leg", "head")]! It looks like \he's trying to commit suicide!</b>"
	playsound(user, src.hitsound, 50, 1)
	return (BRUTELOSS)


/obj/item/weapon/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = 1.0
	origin_tech = "biotech=1"
	attack_verb = list("slapped")

/obj/item/weapon/surgical_drapes/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is suffocating \himself with the [src.name]! It looks like \he's trying to commit suicide!</b>"
	return (OXYLOSS)

/obj/item/weapon/surgical_drapes/attack(mob/living/M, mob/user)
	if(!attempt_initiate_surgery(src, M, user))
		..()