//Function Call verb: Calls forth a Ratvarian spear.
/mob/living/carbon/human/proc/function_call()
	set name = "Function Call"
	set desc = "Calls forth your Ratvarian spear."
	set category = "Clockwork"

	if(usr.l_hand && usr.r_hand)
		usr << "<span class='warning'>You need an empty to hand to call forth your spear!</span>"
		return 0
	usr.visible_message("<span class='warning'>A strange spear materializes in [usr]'s hands!</span>", "<span class='brass'>You call forth your spear!</span>")
	var/obj/item/clockwork/ratvarian_spear/R = new(get_turf(usr))
	usr.put_in_hands(R)
	usr.verbs -= /mob/living/carbon/human/proc/function_call
	return 1

//allows a mob to select a target to gate to
/atom/movable/proc/procure_gateway(mob/living/invoker, time_duration, gateway_uses, two_way)
	var/list/possible_targets = list()
	var/list/teleportnames = list()
	var/list/duplicatenamecount = list()

	for(var/obj/structure/clockwork/powered/clockwork_obelisk/O in all_clockwork_objects)
		if(!O.Adjacent(invoker) && O != src && (O.z <= ZLEVEL_SPACEMAX)) //don't list obelisks that we're next to
			var/area/A = get_area(O)
			var/locname = initial(A.name)
			var/resultkey = "[locname] [O.name]"
			if(resultkey in teleportnames) //why the fuck did you put two obelisks in the same area
				duplicatenamecount[resultkey]++
				resultkey = "[resultkey] ([duplicatenamecount[resultkey]])"
			else
				teleportnames.Add(resultkey)
				duplicatenamecount[resultkey] = 1
			possible_targets[resultkey] = O

	for(var/mob/living/L in living_mob_list)
		if(!L.stat && is_servant_of_ratvar(L) && !L.Adjacent(invoker) && L != invoker && (L.z <= ZLEVEL_SPACEMAX)) //People right next to the invoker can't be portaled to, for obvious reasons
			var/resultkey = "[L.name] ([L.real_name])"
			if(resultkey in teleportnames)
				duplicatenamecount[resultkey]++
				resultkey = "[resultkey] ([duplicatenamecount[resultkey]])"
			else
				teleportnames.Add(resultkey)
				duplicatenamecount[resultkey] = 1
			possible_targets[resultkey] = L

	if(!possible_targets.len)
		invoker << "<span class='warning'>There are no other eligible targets for a Spatial Gateway!</span>"
		return 0
	var/input_target_key = input(invoker, "Choose a target to form a rift to.", "Spatial Gateway") as null|anything in possible_targets
	var/atom/movable/target = possible_targets[input_target_key]
	if(!target || !invoker.canUseTopic(src, be_close = 1))
		return 0
	var/istargetobelisk = istype(target, /obj/structure/clockwork/powered/clockwork_obelisk)
	if(istargetobelisk)
		gateway_uses *= 2
		time_duration *= 2
	invoker.visible_message("<span class='warning'>The air in front of [invoker] ripples before suddenly tearing open!</span>", \
	"<span class='brass'>With a word, you rip open a [two_way ? "two-way":"one-way"] rift to [input_target_key]. It will last for [time_duration / 10] seconds and has [gateway_uses] use[gateway_uses > 1 ? "s" : ""].</span>")
	var/obj/effect/clockwork/spatial_gateway/S1 = new(istype(src, /obj/structure/clockwork/powered/clockwork_obelisk) ? src.loc : get_step(invoker, invoker.dir))
	var/obj/effect/clockwork/spatial_gateway/S2 = new(istargetobelisk ? target.loc : get_step(target, target.dir))

	//Set up the portals now that they've spawned
	S1.setup_gateway(S2, time_duration, gateway_uses, two_way)
	S2.visible_message("<span class='warning'>The air in front of [target] ripples before suddenly tearing open!</span>")
	return 1

/*

The Ratvarian Language

	In the lore of the Servants of Ratvar, the Ratvarian tongue is a timeless language and full of power. It sounds like gibberish, much like Nar-Sie's language, but is in fact derived from
aforementioned language, and may induce miracles when spoken in the correct way with an amplifying tool (similar to runes used by the Nar-Sian cult).

	While the canon states that the language of Ratvar and his servants is incomprehensible to the unenlightened as it is a derivative of the most ancient known language, in reality it is
actually very simple. To translate a plain English sentence to Ratvar's tongue, simply move all of the letters thirteen places ahead, starting from "a" if the end of the alphabet is reached.
This cipher is known as "rot13" for "rotate 13 places" and there are many sites online that allow instant translation between English and rot13 - one of the benefits is that moving the translated
sentence thirteen places ahead changes it right back to plain English.

	There are, however, a few parts of the Ratvarian tongue that aren't typical and are implemented for fluff reasons. Some words may have apostrophes, hyphens, and spaces, making the plain
English translation apparent but disjoined (for instance, "Oru`byq zl-cbjre!" translates directly to "Beh'old my-power!") although this can be ignored without impacting overall quality. When
translating from Ratvar's tongue to plain English, simply remove the disjointments and use the finished sentence. This would make "Oru`byq zl-cbjre!" into "Behold my power!" after removing the
abnormal spacing, hyphens, and grave accents.

List of nuances:

- Any time the word "of" occurs, it is linked to the previous word by a hyphen. If it is the first word, nothing is done. (i.e. "V nz-bs Ratvar." directly translates to "I am-of Ratvar.")
- Although "Ratvar" translates to "Engine" in English, the word "Ratvar" is used regardless of language as it is a proper noun.
 - The same rule applies to Ratvar's four generals: Nezbere (Armorer), Sevtug (Fright), Nzcrentr (Amperage), and Inath-Neq (Vangu-Ard), although these words can be used in proper context if one is
   not referring to the four generals and simply using the words themselves.

*/
