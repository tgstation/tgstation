#define STANDARD_ORGAN_THRESHOLD 100
#define STANDARD_ORGAN_HEALING 0.001

/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/broken_cyber_organ = FALSE //if the organ stopped working.
	var/zone = BODY_ZONE_CHEST
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/vital = 0
	//Was this organ implanted/inserted/etc, if true will not be removed during species change.
	var/external = FALSE
	var/synthetic = FALSE // To distinguish between organic and synthetic organs
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	var/damage = 0		//total damage this organ has sustained
	var/failing	= FALSE			//is this organ failing or not
	var/healing_factor = STANDARD_ORGAN_HEALING	//fraction of maxhealth healed per on_life()
	var/high_threshold	= STANDARD_ORGAN_THRESHOLD * 0.45		//when severe organ damage occurs
	var/low_threshold	= STANDARD_ORGAN_THRESHOLD * 0.1		//when minor organ damage occurs
	var/Unique_Failure_Msg		//certain organs may want unique failure messages for details on how to fix them

/obj/item/organ/proc/Assemble_Failure_Message()	//need to assemble a failure message since we can't have variables be based off of the same object's variables
	var/name_length
	//if no unique failure message is set, output the generic one, otherwise give the one we have set
	if(!Unique_Failure_Msg)
		name_length = lentext(name)
		if(name[name_length] == "s")	//plural case, done without much sanitization since I don't know any organ that ends with an "s" that isn't plural at the moment
			Unique_Failure_Msg = "<span class='danger'>Subject's [name] are too damaged to function, and needs to be replaced or fixed!</span>"
		else
			Unique_Failure_Msg = "<span class='danger'>Subject's [name] is too damaged to function, and needs to be replaced or fixed!</span>"
	return Unique_Failure_Msg

/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	moveToNullspace()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)

//Special is for instant replacement like autosurgeons
/obj/item/organ/proc/Remove(mob/living/carbon/M, special = FALSE)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
		if(vital && !special && !(M.status_flags & GODMODE))
			M.death()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)


/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/proc/on_life()
	var/mob/living/carbon/C = owner
	//if we start to fail, cap our damage and fail the organ
	if(damage > maxHealth)
		failing = TRUE
		damage = maxHealth
	//repair organ damage if the organ is not failing
	if((!failing) && C)
		damage = max(0, damage - (maxHealth * healing_factor) )
	return

/obj/item/organ/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC && broken_cyber_organ)
		. += "<span class='warning'>[src] seems to be broken!</span>"


/obj/item/organ/proc/prepare_eat()
	var/obj/item/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class

	return S

/obj/item/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtype = RAW | MEAT | GROSS


/obj/item/organ/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(owner, special=TRUE)
	return ..()

/obj/item/organ/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/reagent_containers/food/snacks/S = prepare_eat(H)
			if(S)
				qdel(src)
				if(H.put_in_active_hand(S))
					S.attack(H, H)
	else
		..()

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

/obj/item/organ/proc/applyOrganDamage(var/d)	//use for damaging effects
	damage = max(0, damage + d)

/obj/item/organ/proc/setOrganDamage(var/d)	//use mostly for admin heals
	damage = CLAMP(d, 0 ,maxHealth)
	if(d >= maxHealth)
		failing = TRUE
	else
		failing = FALSE

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs()
	if(dna?.species)
		dna.species.regenerate_organs(src)
		return

	else
		if(!getorganslot(ORGAN_SLOT_LUNGS))
			var/obj/item/organ/lungs/L = new()
			L.Insert(src)

		if(!getorganslot(ORGAN_SLOT_HEART))
			var/obj/item/organ/heart/H = new()
			H.Insert(src)

		if(!getorganslot(ORGAN_SLOT_TONGUE))
			var/obj/item/organ/tongue/T = new()
			T.Insert(src)

		if(!getorganslot(ORGAN_SLOT_EYES))
			var/obj/item/organ/eyes/E = new()
			E.Insert(src)

		if(!getorganslot(ORGAN_SLOT_EARS))
			var/obj/item/organ/ears/ears = new()
			ears.Insert(src)