/obj/effect/decal/slag
	name = "slag puddle"
	desc = "The molten remains of something."
	gender = PLURAL
	icon = 'icons/effects/effects.dmi'
	icon_state = "slagcold"
	anchored = 1
	melt_temperature=0

	var/datum/materials/mats=new

/obj/effect/decal/slag/proc/slaggify(var/obj/O)
	// This is basically a crude recycler doohicky
	if (O.recycle(mats))
		if(melt_temperature==0)
			// Set up our solidification temperature.
			melt_temperature=O.melt_temperature
		else
			// Ensure slag solidifies at a lower temp, if needed.
			src.melt_temperature=min(src.melt_temperature,O.melt_temperature)
		qdel(O)
		if(!molten)
			molten=1
			icon_state="slaghot"

/obj/effect/decal/slag/examine()
	..()
	if(molten)
		usr << "<span class=\"warning\">Jesus, it's hot!</span>"

	var/list/bits=list()
	for(var/mat_id in mats)
		var/datum/material/mat=mats.getMaterial(mat_id)
		if(mat.stored>0)
			bits.Add(mat.processed_name)

	if(bits.len>0)
		usr << "<span class=\"info\">It appears to contain bits of [english_list(bits)].</span>"
	else
		usr << "<span class=\"info\">It appears to be completely worthless.</span>"

/obj/effect/decal/slag/solidify()
	icon_state="slagcold"

/obj/effect/decal/slag/melt()
	icon_state="slaghot"

/obj/effect/decal/slag/Crossed(M as mob)
	..()
	if(!molten)
		return
	if(!M)
		return
	if(istype(M, /mob/dead/observer))
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H=M
		H.apply_damage(3, BURN, "l_leg", 0, 0, "Slag")
		H.apply_damage(3, BURN, "r_leg", 0, 0, "Slag")
	else if(istype(M,/mob/living))
		var/mob/living/L=M
		L.apply_damage(125, BURN)

/obj/effect/decal/slag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(molten)
		user.show_message("<span class=\"warning\">You need to wait for \the [src] to cool.</span>")
		return
	if(W.force >= 5 && W.w_class >= 3.0)
		user.visible_message("<span class=\"danger\">\The [src] is broken apart with the [W.name] by [user.name]!</span>", \
			"<span class=\"danger\">You break apart \the [src] with your [W.name]!", \
			"You hear the sound of rock crumbling.")
		var/obj/item/weapon/ore/slag/slag = new /obj/item/weapon/ore/slag(loc)
		slag.mats = src.mats
		qdel(src)
	else
		user.visible_message("<span class=\"warning\">[user.name] hits \the [src] with his [W.name].</span>", \
			"<span class=\"warning\">You fail to damage \the [src] with your [W.name]!</span>", \
			"You hear someone hitting something.")