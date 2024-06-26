GLOBAL_LIST_EMPTY(map_delamination_counters)

/// Display days since last delam on incident sign
#define DISPLAY_DELAM (1<<0)
/// Display current number of tram hits on incident sign
#define DISPLAY_TRAM (1<<1)

DEFINE_BITFIELD(sign_features, list(
	"DISPLAY_DELAM" = DISPLAY_DELAM,
	"DISPLAY_TRAM" = DISPLAY_TRAM,
))

#define TREND_RISING "rising"
#define TREND_FALLING "falling"

#define NAME_DELAM "delamination incident display"
#define NAME_TRAM "tram incident display"

#define DESC_DELAM "A signs describe how long it's been since the last delamination incident. Features an advert for SAFETY MOTH."
#define DESC_TRAM "A display that provides the number of tram related safety incidents this shift. Features an advert for SAFETY MOTH."

#define DISPLAY_PIXEL_1_W 21
#define DISPLAY_PIXEL_1_Z -2
#define DISPLAY_PIXEL_2_W 16
#define DISPLAY_PIXEL_2_Z -2
#define DISPLAY_BASE_ALPHA 64
#define DISPLAY_PIXEL_ALPHA 128

/**
 * List of safety statistic signs on the map that have delam counting enabled.
 * Required as persistence subsystem loads after the ones present at mapload, and to reset to 0 upon explosion.
 */

/obj/machinery/incident_display
	name = NAME_DELAM
	desc = DESC_DELAM
	icon = 'icons/obj/machines/incident_display.dmi'
	icon_preview = "display_normal"
	icon_state = "display_normal"
	verb_say = "beeps"
	verb_ask = "bloops"
	verb_exclaim = "blares"
	idle_power_usage = 450
	max_integrity = 150
	integrity_failure = 0.75
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4, /datum/material/alloy/titaniumglass = SHEET_MATERIAL_AMOUNT * 4)
	/// What statistics we want the sign to display
	var/sign_features = DISPLAY_DELAM
	/// Delam digits color
	var/delam_display_color = COLOR_DISPLAY_YELLOW
	/// Tram hits digits color
	var/tram_display_color = COLOR_DISPLAY_BLUE
	/// Tram hits before hazard warning
	var/hit_threshold = 0
	/// Tram hits
	var/hit_count = 0
	/// Shifts without delam
	var/last_delam = 0
	/// Delam record high-score
	var/delam_record = 0

/obj/machinery/incident_display/delam
	name = NAME_DELAM
	desc = DESC_DELAM
	sign_features = DISPLAY_DELAM

/obj/machinery/incident_display/tram
	name = NAME_TRAM
	desc = DESC_TRAM
	sign_features = DISPLAY_TRAM

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/incident_display/delam, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/incident_display/tram, 32)

/obj/machinery/incident_display/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/incident_display/post_machine_initialize()
	. = ..()
	GLOB.map_delamination_counters += src
	update_delam_count(SSpersistence.rounds_since_engine_exploded, SSpersistence.delam_highscore)
	RegisterSignal(SStransport, COMSIG_TRAM_COLLISION, PROC_REF(update_tram_count))

	update_appearance()

/obj/machinery/incident_display/Destroy()
	GLOB.map_delamination_counters -= src
	return ..()

/obj/machinery/incident_display/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE

	if(atom_integrity >= max_integrity && !(machine_stat & BROKEN))
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE

	balloon_alert(user, "repairing display...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE

	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

// Switch modes with multitool
/obj/machinery/incident_display/multitool_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE

	if(sign_features == DISPLAY_TRAM)
		tool.play_tool_sound(src)
		balloon_alert(user, "set to delam")
		name = NAME_DELAM
		desc = DESC_DELAM
		sign_features = DISPLAY_DELAM
		update_delam_count(SSpersistence.rounds_since_engine_exploded, SSpersistence.delam_highscore)
		update_appearance()
		return TRUE
	else
		tool.play_tool_sound(src)
		balloon_alert(user, "set to tram")
		name = NAME_TRAM
		desc = DESC_TRAM
		sign_features = DISPLAY_TRAM
		update_tram_count(src, SSpersistence.tram_hits_this_round)
		update_appearance()
		return TRUE

// EMP causes the display to display random numbers or outright break.
/obj/machinery/incident_display/emp_act(severity)
	. = ..()
	if(prob(50))
		set_machine_stat(machine_stat | BROKEN)
		update_appearance()
		return

	hit_threshold = rand(1,99)
	hit_count = rand(1,99)

	if(prob(33))
		last_delam = 0
		delam_record = 0
	else
		last_delam = rand(1,99)
		delam_record = rand(1,99)

	update_appearance()

/obj/machinery/incident_display/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/mineral/titanium(drop_location(), 2)
	new /obj/item/shard(drop_location())
	new /obj/item/shard(drop_location())

/obj/machinery/incident_display/proc/update_delam_count(new_count, record)
	delam_record = record
	last_delam = min(new_count, 199)
	update_appearance()

/obj/machinery/incident_display/proc/update_tram_count(source, tram_collisions)
	SIGNAL_HANDLER

	hit_count = min(tram_collisions, 199)
	update_appearance()

/obj/machinery/incident_display/update_appearance(updates = ALL)
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "display_normal"
		set_light(l_on = FALSE)
		return
	else if(machine_stat & BROKEN)
		icon_state = "display_broken"
		set_light(l_range = 1.7, l_power = 1.5, l_color = LIGHT_COLOR_FAINT_CYAN, l_on = TRUE)
	else if((sign_features & DISPLAY_DELAM) && last_delam <= 0)
		icon_state = "display_shame"
		set_light(l_range = 1.7, l_power = 1.5, l_color = COLOR_BIOLUMINESCENCE_PINK, l_on = TRUE)
	else
		icon_state = "display_normal"
		set_light(l_range = 1.7, l_power = 1.5, l_color = LIGHT_COLOR_FAINT_CYAN, l_on = TRUE)

/obj/machinery/incident_display/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	. += emissive_appearance(icon, "display_emissive", src, alpha = DISPLAY_BASE_ALPHA)

	if(sign_features & DISPLAY_DELAM)
		. += mutable_appearance(icon, "overlay_delam")
		. += emissive_appearance(icon, "overlay_delam", src, alpha = DISPLAY_PIXEL_ALPHA)

		var/delam_pos1 = clamp(last_delam, 0, 199) % 10
		var/mutable_appearance/delam_pos1_overlay = mutable_appearance(icon, "num_[delam_pos1]")
		var/mutable_appearance/delam_pos1_emissive = emissive_appearance(icon, "num_[delam_pos1]", src, alpha = DISPLAY_PIXEL_ALPHA)
		delam_pos1_overlay.color = delam_display_color
		delam_pos1_overlay.pixel_w = DISPLAY_PIXEL_1_W
		delam_pos1_emissive.pixel_w = DISPLAY_PIXEL_1_W
		delam_pos1_overlay.pixel_z = DISPLAY_PIXEL_1_Z
		delam_pos1_emissive.pixel_z = DISPLAY_PIXEL_1_Z
		. += delam_pos1_overlay
		. += delam_pos1_emissive

		var/delam_pos2 = (clamp(last_delam, 0, 199) / 10) % 10
		var/mutable_appearance/delam_pos2_overlay = mutable_appearance(icon, "num_[delam_pos2]")
		var/mutable_appearance/delam_pos2_emissive = emissive_appearance(icon, "num_[delam_pos2]", src, alpha = DISPLAY_PIXEL_ALPHA)
		delam_pos2_overlay.color = delam_display_color
		delam_pos2_overlay.pixel_w = DISPLAY_PIXEL_2_W
		delam_pos2_emissive.pixel_w = DISPLAY_PIXEL_2_W
		delam_pos2_overlay.pixel_z = DISPLAY_PIXEL_2_Z
		delam_pos2_emissive.pixel_z = DISPLAY_PIXEL_2_Z
		. += delam_pos2_overlay
		. += delam_pos2_emissive

		if(last_delam >= 100)
			. += mutable_appearance(icon, "num_100_red")
			. += emissive_appearance(icon, "num_100_red", src, alpha = DISPLAY_BASE_ALPHA)

		if(last_delam == delam_record)
			var/mutable_appearance/delam_trend_overlay = mutable_appearance(icon, TREND_RISING)
			var/mutable_appearance/delam_trend_emissive = emissive_appearance(icon, "[TREND_RISING]", src, alpha = DISPLAY_PIXEL_ALPHA)
			delam_trend_overlay.color = COLOR_DISPLAY_GREEN
			. += delam_trend_overlay
			. += delam_trend_emissive
		else
			var/mutable_appearance/delam_trend_overlay = mutable_appearance(icon, TREND_FALLING)
			var/mutable_appearance/delam_trend_emissive = emissive_appearance(icon, "[TREND_FALLING]", src, alpha = DISPLAY_PIXEL_ALPHA)
			delam_trend_overlay.color = COLOR_DISPLAY_RED
			. += delam_trend_overlay
			. += delam_trend_emissive

	if(sign_features & DISPLAY_TRAM)
		. += mutable_appearance(icon, "overlay_tram")
		. += emissive_appearance(icon, "overlay_tram", src, alpha = DISPLAY_PIXEL_ALPHA)

		var/tram_pos1 = hit_count % 10
		var/mutable_appearance/tram_pos1_overlay = mutable_appearance(icon, "num_[tram_pos1]")
		var/mutable_appearance/tram_pos1_emissive = emissive_appearance(icon, "num_[tram_pos1]", src, alpha = DISPLAY_PIXEL_ALPHA)
		tram_pos1_overlay.color = tram_display_color
		tram_pos1_overlay.pixel_w = DISPLAY_PIXEL_1_W
		tram_pos1_emissive.pixel_w = DISPLAY_PIXEL_1_W
		tram_pos1_overlay.pixel_z = DISPLAY_PIXEL_1_Z
		tram_pos1_emissive.pixel_z = DISPLAY_PIXEL_1_Z
		. += tram_pos1_overlay
		. += tram_pos1_emissive

		var/tram_pos2 = (hit_count / 10) % 10
		var/mutable_appearance/tram_pos2_overlay = mutable_appearance(icon, "num_[tram_pos2]")
		var/mutable_appearance/tram_pos2_emissive = emissive_appearance(icon, "num_[tram_pos2]", src, alpha = DISPLAY_PIXEL_ALPHA)
		tram_pos2_overlay.color = tram_display_color
		tram_pos2_overlay.pixel_w = DISPLAY_PIXEL_2_W
		tram_pos2_emissive.pixel_w = DISPLAY_PIXEL_2_W
		tram_pos2_overlay.pixel_z = DISPLAY_PIXEL_2_Z
		tram_pos2_emissive.pixel_z = DISPLAY_PIXEL_2_Z
		. += tram_pos2_overlay
		. += tram_pos2_emissive

		if(hit_count >= 100)
			. += mutable_appearance(icon, "num_100_blue")
			. += emissive_appearance(icon, "num_100_blue", src, alpha = DISPLAY_BASE_ALPHA)

		if(hit_count > SSpersistence.tram_hits_last_round)
			var/mutable_appearance/tram_trend_overlay = mutable_appearance(icon, TREND_RISING)
			var/mutable_appearance/tram_trend_emissive = emissive_appearance(icon, "[TREND_RISING]_e", src, alpha = DISPLAY_PIXEL_ALPHA)
			tram_trend_overlay.color = COLOR_DISPLAY_RED
			. += tram_trend_overlay
			. += tram_trend_emissive
		else
			var/mutable_appearance/tram_trend_overlay = mutable_appearance(icon, TREND_FALLING)
			var/mutable_appearance/tram_trend_emissive = emissive_appearance(icon, "[TREND_FALLING]_e", src, alpha = DISPLAY_PIXEL_ALPHA)
			tram_trend_overlay.color = COLOR_DISPLAY_GREEN
			. += tram_trend_overlay
			. += tram_trend_emissive

/obj/machinery/incident_display/examine(mob/user)
	. = ..()
	if(sign_features & DISPLAY_DELAM)
		if(last_delam >= 0)
			. += span_info("It has been [last_delam] shift\s since the last delamination event at this Nanotrasen facility.")
			switch(last_delam)
				if(0)
					. += span_info("Let's do better today.<br/>")
				if(1 to 5)
					. += span_info("There's room for improvement.<br/>")
				if(6 to 10)
					. += span_info("Good work!<br/>")
				if(69)
					. += span_info("Nice.<br/>")
				else
					. += span_info("Incredible!<br/>")
		else
			. += span_info("The supermatter crystal has delaminated, in case you didn't notice.")

	if(sign_features & DISPLAY_TRAM)
		. += span_info("The station has had [hit_count] tram incident\s this shift.")
		switch(hit_count)
			if(0)
				. += span_info("Fantastic! Champions of safety.<br/>")
			if(1)
				. += span_info("Let's do better tomorrow.<br/>")
			if(2 to 5)
				. += span_info("There's room for improvement.<br/>")
			if(6 to 10)
				. += span_info("Good work! Nanotrasen's finest!<br/>")
			if(69)
				. += span_info("Nice.<br/>")
			else
				. += span_info("Incredible! You're probably reading this from medbay.<br/>")

#undef DISPLAY_DELAM
#undef DISPLAY_TRAM

#undef NAME_DELAM
#undef NAME_TRAM

#undef DESC_DELAM
#undef DESC_TRAM

#undef TREND_RISING
#undef TREND_FALLING

#undef DISPLAY_PIXEL_1_W
#undef DISPLAY_PIXEL_1_Z
#undef DISPLAY_PIXEL_2_W
#undef DISPLAY_PIXEL_2_Z
#undef DISPLAY_BASE_ALPHA
#undef DISPLAY_PIXEL_ALPHA
