#define MAX_POWER_PER_COG 250
#define HALLUCINATION_COG_CHANCE 20

/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cog that seems to spin by its own acord when left alone."
	icon_state = "integration_cog"
	clockwork_desc = "A sharp cog that can cut through and be inserted into APCs to extract power for your machinery."
	w_class = WEIGHT_CLASS_TINY


/obj/item/clockwork/integration_cog/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(!(IS_CLOCK(user)) || !istype(attacked_atom, /obj/machinery/power/apc))
		return ..()

	var/obj/machinery/power/apc/cogger_apc = attacked_atom
	if(cogger_apc.integration_cog)
		balloon_alert(user, "already has a cog inside!")
		return

	if(!cogger_apc.panel_open)
		//Cut open the panel
		balloon_alert(user, "cutting open APC...")
		if(!do_after(user, 5 SECONDS, target = cogger_apc))
			return

		balloon_alert(user, "APC cut open")
		cogger_apc.panel_open = TRUE
		cogger_apc.update_appearance()
		return

	//Insert the cog
	balloon_alert(user, "inserting [src]...")
	if(!do_after(user, 4 SECONDS, target = cogger_apc))
		balloon_alert(user, "failed to insert [src]!")
		return

	cogger_apc.integration_cog = src
	forceMove(cogger_apc)
	cogger_apc.panel_open = FALSE
	cogger_apc.update_appearance()
	balloon_alert(user, "[src] inserted")
	playsound(get_turf(user), 'sound/machines/clockcult/integration_cog_install.ogg', 20)
	if(!cogger_apc.clock_cog_rewarded)
		GLOB.clock_installed_cogs++
		GLOB.max_clock_power += MAX_POWER_PER_COG
		cogger_apc.clock_cog_rewarded = TRUE
		send_clock_message(null, span_brass(span_bold("[user.real_name] has installed an integration cog into [cogger_apc].")), msg_ghosts = TRUE)
		//Update the cog counts
		for(var/obj/item/clockwork/clockwork_slab/slab as anything in GLOB.clockwork_slabs)
			slab.cogs++
		GLOB.current_eminence?.cogs++


/obj/machinery/power/apc
	/// If this APC has given a reward for being coggered before
	var/clock_cog_rewarded = FALSE
	/// Reference to the cog inside
	var/integration_cog = null


/obj/machinery/power/apc/Destroy()
	QDEL_NULL(integration_cog)
	return ..()


/obj/machinery/power/apc/examine_more(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		if(panel_open && integration_cog || (living_user.has_status_effect(/datum/status_effect/hallucination) && prob(HALLUCINATION_COG_CHANCE)))
			. += span_brass("A small cogwheel is inside of it.")


/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/crowbar)
	if(!opened || !integration_cog)
		return ..()

	balloon_alert(user, "prying something out of [src]...")
	crowbar.play_tool_sound(src)
	if(!crowbar.use_tool(src, user, 5 SECONDS))
		return

	balloon_alert(user, "pried out something, destroying it!")
	QDEL_NULL(integration_cog)

#undef MAX_POWER_PER_COG
#undef HALLUCINATION_COG_CHANCE
