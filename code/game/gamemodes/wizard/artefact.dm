
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = 3
	var/charged = 1
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/rend/New()
	spawn(50)
		new /obj/singularity/narsie/wizard(get_turf(src))
		qdel(src)
		return
	return

/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged == 1)
		new /obj/effect/rend(get_turf(usr))
		charged = 0
		visible_message("<span class='userdanger'>[src] hums with power as [usr] deals a blow to reality itself!</span>")
	else
		user << "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>"



/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."

/obj/item/weapon/veilrender/vealrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend/cow(get_turf(usr))
		charged = 0
		visible_message("<span class='userdanger'>[src] hums with power as [usr] deals a blow to hunger itself!</span>")
	else
		user << "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>"

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	var/cowsleft = 20

/obj/effect/rend/cow/New()
	SSobj.processing.Add(src)
	return

/obj/effect/rend/cow/process()
	if(locate(/mob) in loc) return
	new /mob/living/simple_animal/cow(loc)
	cowsleft--
	if(cowsleft <= 0)
		qdel(src)

/obj/effect/rend/cow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/nullrod))
		visible_message("<span class='danger'>[I] strikes a blow against \the [src], banishing it!</span>")
		qdel(src)
		return
	..()


/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "<span class='notice'>You can see...everything!</span>"
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)
	return

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/device/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = 1
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/device/necromantic_stone/unlimited
	unlimited = 1

/obj/item/device/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M, /mob/living/carbon/human))
		return ..()

	if(!istype(user) || !user.canUseTopic(M,1))
		return

	if(M.stat != DEAD)
		user << "<span class='warning'>This artifact can only affect the dead!</span>"
		return

	if(!M.mind || !M.client)
		user << "<span class='warning'>There is no soul connected to this body...</span>"
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		user << "<span class='warning'>This artifact can only affect three undead at a time!</span>"
		return

	hardset_dna(M, null, null, null, null, /datum/species/skeleton)
	M.revive()
	spooky_scaries |= M
	M << "<span class='notice'>You have been revived by </span><B>[user.real_name]!</B>"
	M << "<span class='notice'>They are your master now, assist them even if it costs you your new life!</span>"

	if(prob(33))
		equip_roman_skeleton(M)

	var/mob/living/carbon/human/master = user

	var/datum/objective/protect/protect_master = new /datum/objective/protect
	protect_master.owner = M.mind
	protect_master.target = master.mind
	protect_master.explanation_text = "Protect [master.real_name], your master."
	M.mind.objectives += protect_master
	ticker.mode.traitors += M.mind
	M.mind.special_role = "skeleton-thrall"

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/device/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!istype(X, /mob/living/carbon/human))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/device/necromantic_stone/proc/equip_roman_skeleton(var/mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.unEquip(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
	H.equip_to_slot_or_del(new hat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/roman(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_r_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), slot_back)
