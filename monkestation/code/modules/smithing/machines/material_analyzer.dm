/atom/proc/scan_animation(passed_color, time = 2 SECONDS, alpha = "96") // alpha needs to be in hex formant and color in non hex format
	var/fading_time = time * 0.5 /// we spend half the time fading

	add_filter("scanning", 1, layering_filter(blend_mode = BLEND_INSET_OVERLAY, icon = icon('monkestation/code/modules/smithing/icons/effects.dmi', "scanline"), color = "[passed_color]00")) // we add 00 to turn it into a alpha hex color
	if(!get_filter("scanning")) // filter check for things that don't support filters or have them cleared quickly
		return
	var/filter = get_filter("scanning")
	animate(filter, y = -30, easing = QUAD_EASING, time = time)
	animate(color = passed_color + alpha, time = fading_time, flags = ANIMATION_PARALLEL, easing = QUAD_EASING | EASE_IN)
	animate(color = passed_color + "00", time = fading_time, easing = QUAD_EASING | EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(clear_filter), "scanning"), time)

/atom/proc/clear_filter(name)
	remove_filter(name)


/obj/machinery/material_analyzer
	name = "material analyzer"
	desc = "This machine allows you to analyzer materials."

	icon_state = "matscannerx"
	icon = 'goon/icons/matsci.dmi'

	anchored = TRUE
	density = TRUE

	idle_power_usage = 10
	active_power_usage = 1000
	circuit = /obj/item/circuitboard/machine/material_analyzer

	///the time we need to analyze a material
	var/analyze_time = 5 SECONDS
	var/analyzing = FALSE


/obj/machinery/material_analyzer/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/material_analyzer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item && !analyzing)
		context[SCREENTIP_CONTEXT_LMB] = "Analyze the [held_item]."
	return CONTEXTUAL_SCREENTIP_SET


/obj/machinery/material_analyzer/attackby(obj/item/weapon, mob/user, params)
	if((user.istate & ISTATE_HARM) || analyzing)
		return ..()
	weapon.scan_animation(COLOR_GREEN_GRAY, 5 SECONDS)
	icon_state = "matscanner1"
	analyzing = TRUE
	if(!do_after(user, 5 SECONDS, src))
		weapon.remove_filter("scanning")
		icon_state = "matscannerx"
		analyzing = FALSE
		return ..()
	analyzing = FALSE
	print_material_data(weapon)

/obj/machinery/material_analyzer/proc/print_material_data(obj/item/checker)
	if(!checker.material_stats)
		say("ERROR: No Material stats found.")
		return
	var/obj/item/paper/printed_paper = new(get_turf(src))
	var/final_paper_text = text("<center><b>[checker]</b></center><br>")

	var/datum/material_stats/stats = checker.material_stats

	final_paper_text += text("<center><b>Stats</b></center><br>")
	if(stats.conductivity)
		final_paper_text += text("<B>Conductivity</B>: [stats.conductivity]<br>")
	if(stats.thermal)
		final_paper_text += text("<B>Thermal</B>: [stats.thermal]<br>")
	if(stats.hardness)
		final_paper_text += text("<B>Hardness</B>: [stats.hardness]<br>")
	if(stats.density)
		final_paper_text += text("<B>Density</B>: [stats.density]<br>")
	if(stats.flammability)
		final_paper_text += text("<B>Flammability</B>: [stats.flammability]<br>")
	if(stats.radioactivity)
		final_paper_text += text("<B>Radioactivity</B>: [stats.radioactivity]<br>")
	if(stats.refractiveness)
		final_paper_text += text("<B>Refractive Scale</B>: [stats.refractiveness]<br>")
	if(stats.liquid_flow)
		final_paper_text += text("<B>Liquid Flow</B>: [stats.liquid_flow]<br>")

	final_paper_text += text("<center><b>Traits</b></center><br>")
	for(var/datum/material_trait/trait as anything in stats.material_traits)
		final_paper_text += text("<B>[trait.name]</B>: [trait.desc]<br>")


	printed_paper.name = text("[checker] Material Stats")
	printed_paper.add_raw_text(final_paper_text)
	printed_paper.update_appearance()
