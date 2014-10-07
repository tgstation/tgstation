/obj/item/organ
	name = "organ"
	desc = "It looks like it probably just plopped out."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"

	health = 100                              // Process() ticks before death.

	var/fresh = 3                             // Squirts of blood left in it.
	var/dead_icon                             // Icon used when the organ dies.
	var/robotic                               // Is the limb prosthetic?
	var/organ_tag                             // What slot does it go in?
	var/organ_type = /datum/organ/internal    // Used to spawn the relevant organ data when produced via a machine or spawn().
	var/datum/organ/internal/organ_data       // Stores info when removed.
	var/prosthetic_name = "prosthetic organ"  // Flavour string for robotic organ.
	var/prosthetic_icon                       // Icon for robotic organ.

/obj/item/organ/attack_self(mob/user as mob)

	// Convert it to an edible form, yum yum.
	if(!robotic && user.a_intent == "help" && user.zone_sel.selecting == "mouth")
		bitten(user)
		return

/obj/item/organ/New()
	..()
	create_reagents(5)
	if(!robotic)
		processing_objects += src
	spawn(1)
		update()

/obj/item/organ/Del()
	if(!robotic) processing_objects -= src
	..()

/obj/item/organ/process()

	if(robotic)
		processing_objects -= src
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag. //TODO: ambient temperature?
	if(istype(loc,/obj/item/device/mmi) || istype(loc,/obj/item/bodybag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer))
		return

	if(fresh && prob(40))
		fresh--
		var/datum/reagent/blood = reagents.reagent_list["blood"]
		blood_splatter(src,blood,1)

	health -= rand(1,3)
	if(health <= 0)
		die()

/obj/item/organ/proc/die()
	name = "dead [initial(name)]"
	if(dead_icon) icon_state = dead_icon
	health = 0
	processing_objects -= src
	//TODO: Grey out the icon state.
	//TODO: Inject an organ with peridaxon to make it alive again.

/obj/item/organ/proc/roboticize()

	robotic = (organ_data && organ_data.robotic) ? organ_data.robotic : 1

	if(prosthetic_name)
		name = prosthetic_name

	if(prosthetic_icon)
		icon_state = prosthetic_icon
	else
		//TODO: convert to greyscale.

/obj/item/organ/proc/update()

	if(!organ_data)
		organ_data = new /datum/organ/internal()

	if(robotic)
		organ_data.robotic = robotic

	if(organ_data.robotic >= 2)
		roboticize()

// Brain is defined in brain_item.dm.
/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	prosthetic_name = "circulatory pump"
	prosthetic_icon = "heart-prosthetic"
	organ_tag = "heart"
	fresh = 6 // Juicy.
	dead_icon = "heart-off"

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	prosthetic_name = "gas exchange system"
	prosthetic_icon = "lungs-prosthetic"
	organ_tag = "lungs"

/obj/item/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	prosthetic_name = "prosthetic kidneys"
	prosthetic_icon = "kidneys-prosthetic"
	organ_tag = "kidneys"

/obj/item/organ/eyes
	name = "eyeballs"
	icon_state = "eyes"
	prosthetic_name = "visual prosthesis"
	prosthetic_icon = "eyes-prosthetic"
	organ_tag = "eyes"

	var/eye_colour

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	prosthetic_name = "toxin filter"
	prosthetic_icon = "liver-prosthetic"
	organ_tag = "liver"

/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_tag = "appendix"

//These are here so they can be printed out via the fabricator.
/obj/item/organ/heart/prosthetic
	robotic = 2

/obj/item/organ/lungs/prosthetic
	robotic = 2

/obj/item/organ/kidneys/prosthetic
	robotic = 2

/obj/item/organ/eyes/prosthetic
	robotic = 2

/obj/item/organ/liver/prosthetic
	robotic = 2

/obj/item/organ/appendix
	name = "appendix"

/obj/item/organ/proc/removed(var/mob/living/target,var/mob/living/user)

	if(!target || !user)
		return

	if(organ_data.vital)
		user.attack_log += "\[[time_stamp()]\]<font color='red'> removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> had a vital organ ([src]) removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		target.death()

/obj/item/organ/appendix/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/inflamed = 0
	for(var/datum/disease/appendicitis/appendicitis in target.viruses)
		inflamed = 1
		appendicitis.cure()
		target.resistances += appendicitis

	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"

/obj/item/organ/eyes/removed(var/mob/living/target,var/mob/living/user)

	if(!eye_colour)
		eye_colour = list(0,0,0)

	..() //Make sure target is set so we can steal their eye colour for later.
	var/mob/living/carbon/human/H = target
	if(istype(H))
		eye_colour = list(
			H.r_eyes ? H.r_eyes : 0,
			H.g_eyes ? H.g_eyes : 0,
			H.b_eyes ? H.b_eyes : 0
			)

		// Leave bloody red pits behind!
		H.r_eyes = 128
		H.g_eyes = 0
		H.b_eyes = 0
		H.update_body()

/obj/item/organ/proc/replaced(var/mob/living/target)
	return

/obj/item/organ/eyes/replaced(var/mob/living/target)

	// Apply our eye colour to the target.
	var/mob/living/carbon/human/H = target
	if(istype(H) && eye_colour)
		H.r_eyes = eye_colour[1]
		H.g_eyes = eye_colour[2]
		H.b_eyes = eye_colour[3]
		H.update_body()

/obj/item/organ/proc/bitten(mob/user)

	if(robotic)
		return

	user << "\blue You take an experimental bite out of \the [src]."
	var/datum/reagent/blood = reagents.reagent_list["blood"]
	blood_splatter(src,blood,1)


	user.drop_from_inventory(src)
	var/obj/item/weapon/reagent_containers/food/snacks/organ/O = new(get_turf(src))
	O.name = name
	O.icon_state = dead_icon ? dead_icon : icon_state

	// Pass over the blood.
	reagents.trans_to(O, reagents.total_volume)

	if(fingerprints) O.fingerprints = fingerprints.Copy()
	if(fingerprintshidden) O.fingerprintshidden = fingerprintshidden.Copy()
	if(fingerprintslast) O.fingerprintslast = fingerprintslast

	user.put_in_active_hand(O)
	del(src)