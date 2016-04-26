/**
*  Basically, a backplane for AI modules.
*
* Lets you insert modules of your liking as a sort of "dry run"
* Good if you're making your own "base laws" with freeforms and
* purge modules.
*
* Runs all laws after a delay when inserted into upload.
*/

/obj/item/weapon/planning_frame
	name = "planning frame"
	desc = "A large circuit board with slots for AI modules. Used for planning a law set."
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"

	icon = 'icons/obj/module.dmi'
	icon_state = "planning frame"
	item_state = "electronic"

	//Recycling
	starting_materials = list(MAT_GLASS = 2000/CC_PER_SHEET_GLASS)
	w_type=RECYK_ELECTRONIC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

	var/purge=0 // Purge laws?
	var/assuming_base=0 // Assuming we're on base_laws.

	var/list/obj/item/weapon/aiModule/modules = list()
	var/datum/ai_laws/laws

/obj/item/weapon/planning_frame/New()
	. = ..()
	laws = new base_law_type

/obj/item/weapon/planning_frame/attackby(var/obj/item/W,var/mob/user)
	if(istype(W, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/module=W
		if(!module.validate(src.laws,src,user))
			return
		if(!module.upload(src.laws,src,user))
			return
		//user.drop_item(null, )
		//module.loc=src
		modules += module.copy() // Instead of a reference
		to_chat(user, "<span class='notice'>You insert \the [module] into \the [src], and the device reads the module's contents.</span>")
	else
		return ..()

/obj/item/weapon/planning_frame/attack_self(var/mob/user)
	for(var/obj/item/weapon/aiModule/mod in modules)
		qdel(mod)
	modules.len = 0
	to_chat(user, "<span class='notice'>You clear \the [src]'s memory buffers!</span>")
	laws = new base_law_type
	return

/obj/item/weapon/planning_frame/examine(mob/user)
	..()
	laws_sanity_check()
	if(modules.len && istype(modules[1],/obj/item/weapon/aiModule/purge))
		to_chat(user, "<b>Purge module inserted!</b> - All laws will be cleared prior to adding the ones below.")
	if(!laws.inherent_cleared)
		to_chat(user, "<b><u>Assuming that default laws are unchanged</u>, the laws currently inserted would read as:</b>")
	else
		to_chat(user, "<b>The laws currently inserted would read as:</b>")
	if(src.modules.len == 0)
		to_chat(user, "<i>No modules have been inserted!</i>")
		return
	src.laws.show_laws(user)

/obj/item/weapon/planning_frame/verb/dry_run()
	set name = "Dry Run"
	to_chat(usr, "You read through the list of modules to emulate, in their run order:")
	for(var/i=1;i<=modules.len;i++)
		var/obj/item/weapon/aiModule/module = modules[i]
		var/notes="<span class='notice'>Looks OK!</span>"
		if(i>1 && istype(modules[i],/obj/item/weapon/aiModule/purge))
			notes="<span class='danger'>This should be the first module!</span>"
		if(!module.validate(src.laws,src,usr))
			notes="<span class='danger'>A red light is blinking!</span>"
		if(module.modflags & DANGEROUS_MODULE)
			notes="<span class='danger'>Your heart skips a beat!</span>"
		to_chat(usr, " [i-1]. [module.name] - [notes]")

/obj/item/weapon/planning_frame/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new base_law_type

/obj/item/weapon/planning_frame/proc/set_zeroth_law(var/law, var/law_borg)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)

/obj/item/weapon/planning_frame/proc/add_inherent_law(var/law)
	laws_sanity_check()
	src.laws.add_inherent_law(law)

/obj/item/weapon/planning_frame/proc/clear_inherent_laws()
	laws_sanity_check()
	src.laws.clear_inherent_laws()

/obj/item/weapon/planning_frame/proc/add_ion_law(var/law)
	laws_sanity_check()
	src.laws.add_ion_law(law)

/obj/item/weapon/planning_frame/proc/clear_ion_laws()
	laws_sanity_check()
	src.laws.clear_ion_laws()

/obj/item/weapon/planning_frame/proc/add_supplied_law(var/number, var/law)
	laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/obj/item/weapon/planning_frame/proc/clear_supplied_laws()
	laws_sanity_check()
	src.laws.clear_supplied_laws()