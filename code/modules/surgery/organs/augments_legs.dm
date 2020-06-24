/obj/item/organ/cyberimp/leg
	name = "leg-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/cyberimp/leg/Initialize()
	. = ..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	SetSlotFromZone()
	items_list = contents.Copy()

/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg.</span>")
	update_icon()

/obj/item/organ/cyberimp/arm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>[src] is hit by EMP!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()

/obj/item/organ/cyberimp/leg/clownservo
	name = "Snappop waddle servo"
	desc = "A rare, highly illegal device used by the infamous Honkquisition to subjugate clowns who remove their shoes."
	icon_state = "clownservo"
	slot = ORGAN_SLOT_RIGHT_LEG_AUG

/obj/item/organ/cyberimp/leg/clownservo/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(!iscarbon(M) || owner == M)
		M.AddElement(/datum/element/waddling)
		return

/obj/item/organ/cyberimp/leg/clownservo/Remove(mob/living/carbon/M, special = 0)
	M.RemoveElement(/datum/element/waddling)
