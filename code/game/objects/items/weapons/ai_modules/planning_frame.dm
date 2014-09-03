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
	flags = FPRINT | TABLEPASS| CONDUCT
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
	g_amt=2000 // Glass
	var/gold_amt=0
	var/diamond_amt=0
	w_type=RECYK_ELECTRONIC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

	var/purge=0 // Purge laws?
	var/assuming_base=0 // Assuming we're on base_laws.

	var/list/obj/item/weapon/aiModule/modules = list()
	var/datum/ai_laws/laws

/obj/item/weapon/planning_frame/New()
	. = ..()
	laws = new base_law_type

/obj/item/weapon/planning_frame/recycle(var/datum/materials/rec)
	rec.addAmount("glass",  g_amt)
	rec.addAmount("gold",   gold_amt)
	rec.addAmount("diamond",diamond_amt)
	return 1

/obj/item/weapon/planning_frame/attackby(var/obj/item/W,var/mob/user)
	if(istype(W, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/module=W
		if(!module.validate(src.laws,src,user))
			return
		if(!module.upload(src.laws,src,user))
			return
		//user.drop_item()
		//module.loc=src
		modules += module.copy() // Instead of a reference
		user << "\blue You insert \the [module] into \the [src], and the device reads the module's contents."
	else
		return ..()

/obj/item/weapon/planning_frame/attack_self(var/mob/user)
	for(var/obj/item/weapon/aiModule/mod in modules)
		qdel(mod)
	modules.Cut()
	user << "\blue You clear \the [src]'s memory buffers!"
	laws = new base_law_type
	return

/obj/item/weapon/planning_frame/examine()
	..()
	laws_sanity_check()
	if(modules.len && istype(modules[1],/obj/item/weapon/aiModule/purge))
		usr << "<b>Purge module inserted!</b> - All laws will be cleared prior to adding the ones below."
	if(!laws.inherent_cleared)
		usr << "<b><u>Assuming that default laws are unchanged</u>, the laws currently inserted would read as:</b>"
	else
		usr << "<b>The laws currently inserted would read as:</b>"
	if(src.modules.len == 0)
		usr << "<i>No modules have been inserted!</i>"
		return
	src.laws.show_laws(usr)

/obj/item/weapon/planning_frame/verb/dry_run()
	set name = "Dry Run"
	usr << "You read through the list of modules to emulate, in their run order:"
	for(var/i=1;i<=modules.len;i++)
		var/obj/item/weapon/aiModule/module = modules[i]
		var/notes="\blue Looks OK!"
		if(i>1 && istype(modules[i],/obj/item/weapon/aiModule/purge))
			notes="\red <b>This should be the first module!</b>"
		if(!module.validate(src.laws,src,usr))
			notes="\red <b>A red light is blinking!</b>"
		if(module.modflags & DANGEROUS_MODULE)
			notes="\red <b>Your heart skips a beat!</b>"
		usr << " [i-1]. [module.name] - [notes]"

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