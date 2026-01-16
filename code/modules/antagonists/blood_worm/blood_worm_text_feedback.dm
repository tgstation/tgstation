// Any proc that communicates text to/from a blood worm goes here.
// These procs are usually pretty big and there are quite a few of them.

/mob/living/basic/blood_worm/examining(atom/target, list/result)
	add_special_examining_messages(target, result)

/mob/living/basic/blood_worm/proc/on_host_examining(datum/source, atom/target, list/examine_strings)
	SIGNAL_HANDLER
	add_special_examining_messages(target, examine_strings)

/mob/living/basic/blood_worm/proc/add_special_examining_messages(atom/target, list/result)
	if (!isliving(target) || target == host)
		return

	var/mob/living/bloodbag = target

	var/cached_blood_volume = bloodbag.get_blood_volume()

	if (cached_blood_volume <= 0)
		return

	var/list/blood_data = bloodbag.get_blood_data()

	var/synth_content = blood_data?[BLOOD_DATA_SYNTH_CONTENT]
	if (!isnum(synth_content))
		synth_content = 0 // Otherwise the switch statement breaks.

	var/normal_content = 1 - synth_content

	var/normal_blood_after = consumed_normal_blood + cached_blood_volume * normal_content
	var/synth_blood_after = min(consumed_synth_blood + cached_blood_volume * synth_content * synth_blood_efficiency, maximum_synth_blood)

	var/total_blood_now = get_consumed_blood()
	var/total_blood_after = normal_blood_after + synth_blood_after

	var/potential_gain = total_blood_after - total_blood_now

	var/rounded_volume = CEILING(cached_blood_volume, 1)

	var/growth_string = ""
	if (HAS_TRAIT(bloodbag, TRAIT_BLOOD_WORM_HOST))
		growth_string = ", but consuming it is impossible, as they are a host"
	else if (total_blood_now < cocoon_action?.total_blood_required)
		var/rounded_growth = CEILING(potential_gain / cocoon_action.total_blood_required * 100, 1)
		if (rounded_growth > 0)
			growth_string = ", consuming it would contribute <b>[rounded_growth]%</b> to your growth"
		else
			growth_string = ", but consuming it wouldn't contribute to your growth"
	else
		if (!istype(src, /mob/living/basic/blood_worm/adult))
			growth_string = ". You are already ready to mature"
		else
			growth_string = ". You are already fully grown"

	var/synth_string = "[CEILING(synth_content * 100, 1)]%"
	switch(synth_content)
		if (-INFINITY to 0)
			synth_string = "not"
		if (1 to INFINITY)
			synth_string = "fully"
		if (0 to 1)
			synth_string = "[CEILING(synth_content * 100, 1)]%"

	result += span_notice("[target.p_They()] [target.p_have()] [rounded_volume] unit[rounded_volume == 1 ? "" : "s"] of blood[growth_string]. [target.p_Their()] blood is <b>[synth_string]</b> synthetic.")

/mob/living/basic/blood_worm/get_status_tab_items()
	return ..() + get_special_status_tab_items()

/mob/living/basic/blood_worm/proc/on_host_get_status_tab_items(datum/source, list/items)
	SIGNAL_HANDLER
	items += "Worm Health: [round((health / maxHealth) * 100)]%"
	items += get_special_status_tab_items()

/mob/living/basic/blood_worm/proc/get_special_status_tab_items()
	. = list()

	var/normal = consumed_normal_blood
	var/synth = consumed_synth_blood
	var/total = normal + synth

	var/total_required = cocoon_action?.total_blood_required

	if (total_required > 0)
		. += "Growth: [FLOOR(total / total_required * 100, 1)]%"
	. += "Blood Consumed"
	. += "- Normal: [CEILING(normal, 1)]u"
	. += "- Synthetic: [CEILING(synth, 1)]u (MAX: [maximum_synth_blood]u)"
	. += "- Total: [CEILING(total, 1)]u (REQ: [total_required]u)"

/// Sends text to the blood worm, whether they are possessing a host or not.
/mob/living/basic/blood_worm/proc/to_chat_self(text)
	to_chat(is_possessing_host ? host : src, text)

/// Sends a balloon alert to the blood worm, whether they are possessing a host or not.
/mob/living/basic/blood_worm/proc/balloon_alert_self(text)
	var/mob/living/self = is_possessing_host ? host : src
	self.balloon_alert(self, text)
