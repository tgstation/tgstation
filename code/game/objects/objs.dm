<<<<<<< HEAD
/obj
	languages_spoken = HUMAN
	languages_understood = HUMAN
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 0
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	var/burn_state = FIRE_PROOF // LAVA_PROOF | FIRE_PROOF | FLAMMABLE | ON_FIRE
	var/burntime = 10 //How long it takes to burn to ashes, in seconds
	var/burn_world_time //What world time the object will burn up completely
	var/being_shocked = 0

	var/on_blueprints = FALSE //Are we visible on the station blueprints at roundstart?
	var/force_blueprints = FALSE //forces the obj to be on the blueprints, regardless of when it was created.

/obj/New()
	..()

	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		if(force_blueprints)
			T.add_blueprints(src)
		else
			T.add_blueprints_preround(src)

/obj/Destroy()
	if(!istype(src, /obj/machinery))
		STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	SStgui.close_uis(src)
	return ..()

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process

	if(breath_request>0)
		var/datum/gas_mixture/environment = return_air()
		var/breath_percentage = BREATH_VOLUME / environment.return_volume()
		return remove_air(environment.total_moles() * breath_percentage)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot) || IsAdminGhost(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!(usr in nearby))
				if(usr.client && usr.machine==src)
					if(H.dna.check_mutation(TK))
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0


/obj/attack_ghost(mob/user)
	if(ui_interact(user) != -1)
		return
	..()

/obj/proc/container_resist()
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/ex_act(severity, target)
	if(severity == 1 || target == src)
		qdel(src)
	else if(severity == 2)
		if(prob(50))
			qdel(src)
	if(!qdeleted(src))
		..()

//If a mob logouts/logins in side of an object you can use this proc
/obj/proc/on_log()
	..()
	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()

/obj/singularity_act()
	ex_act(1)
	if(src && !qdeleted(src))
		qdel(src)
	return 2

/obj/singularity_pull(S, current_size)
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src,S)

/obj/proc/Deconstruct()
	qdel(src)

/obj/get_spans()
	return ..() | SPAN_ROBOT

/obj/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	var/turf/T = get_turf(src)
	return T.storage_contents_dump_act(src_object, user)

/obj/fire_act(global_overlay=1)
	if(!burn_state)
		burn_state = ON_FIRE
		SSobj.burning += src
		burn_world_time = world.time + burntime*rand(10,20)
		if(global_overlay)
			add_overlay(fire_overlay)
		return 1

/obj/proc/burn()
	empty_object_contents(1, src.loc)
	var/obj/effect/decal/cleanable/ash/A = new(src.loc)
	A.desc = "Looks like this used to be a [name] some time ago."
	SSobj.burning -= src
	qdel(src)

/obj/proc/extinguish()
	if(burn_state == ON_FIRE)
		burn_state = FLAMMABLE
		overlays -= fire_overlay
		SSobj.burning -= src

/obj/proc/empty_object_contents(burn = 0, new_loc = src.loc)
	for(var/obj/item/Item in contents) //Empty out the contents
		Item.loc = new_loc
		if(burn)
			Item.fire_act() //Set them on fire, too

/obj/proc/tesla_act(var/power)
	being_shocked = 1
	var/power_bounced = power / 2
	tesla_zap(src, 3, power_bounced)
	addtimer(src, "reset_shocked", 10)

/obj/proc/reset_shocked()
	being_shocked = 0

/obj/proc/CanAStarPass()
	. = !density
=======
var/global/list/reagents_to_log = list(FUEL, PLASMA, PACID, SACID, AMUTATIONTOXIN, MINDBREAKER, SPIRITBREAKER, CYANIDE, IMPEDREZENE)
/obj
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/siemens_coefficient = 0 // for electrical admittance/conductance (electrocution checks and shit) - 0 is not conductive, 1 is conductive - this is a range, not binary
	var/sharpness = 0 //not a binary - rough guide is 0.8 cutting, 1 cutting well, 1.2 specifically sharp (knives, etc) 1.5 really sharp (scalpels, e-weapons)
	var/heat_production = 0

	var/edge = 0
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	//Should we alert about reagents that should be logged?
	var/log_reagents = 1

	var/list/mob/_using // All mobs dicking with us.

	// Shit for mechanics. (MECH_*)
	var/mech_flags=0

	var/holomap = FALSE // Whether we should be on the holomap.
	var/auto_holomap = FALSE // Whether we automatically soft-add ourselves to the holomap in New(), make sure this is false is something does it manually.
	plane = PLANE_OBJ

/obj/New()
	..()
	if (auto_holomap && isturf(loc))
		var/turf/T = loc
		T.soft_add_holomap(src)

/obj/Destroy()
	for(var/mob/user in _using)
		user.unset_machine()

	if(src in processing_objects)
		processing_objects -= src

	..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/recycle(var/datum/materials/rec)
	if(..())
		return 1
	return w_type

/*
/obj/melt()
	var/obj/effect/decal/slag/slag=locate(/obj/effect/decal/slag) in get_turf(src)
	if(!slag)
		slag = new(get_turf(src))
	slag.slaggify(src)
*/

/obj/proc/is_conductor(var/siemens_min = 0.5)
	if(src.siemens_coefficient >= siemens_min)
		return 1
	return

/obj/proc/cultify()
	qdel(src)

/obj/proc/wrenchable()
	return 0

/obj/proc/can_wrench_shuttle()
	return 0

/obj/proc/is_sharp()
	return sharpness

/obj/proc/is_hot()
	return heat_production

/obj/proc/process()
	processing_objects.Remove(src)

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/atom/movable/proc/initialize()
	return

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		if(_using && _using.len)
			var/list/nearby = viewers(1, src)
			for(var/mob/M in _using) // Only check things actually messing with us.
				if (!M || !M.client || M.machine != src)
					_using.Remove(M)
					continue

				if(!M in nearby) // NOT NEARBY
					// AIs/Robots can do shit from afar.
					if (isAI(M) || isrobot(M))
						is_in_use = 1
						src.attack_ai(M)

					// check for TK users
					if(M.mutations && M.mutations.len)
						if(M_TK in M.mutations)
							is_in_use = 1
							src.attack_hand(M, TRUE) // The second param is to make sure brain damage on the user doesn't cause the UI to not update but the action to still happen.
					else
						// Remove.
						_using.Remove(M)
						continue
				else // EVERYTHING FROM HERE DOWN MUST BE NEARBY
					is_in_use = 1
					attack_hand(M, TRUE)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in _using) // Only check things actually messing with us.
			// Not actually using the fucking thing?
			if (!M || !M.client || M.machine != src)
				_using.Remove(M)
				continue
			// Not robot or AI, and not nearby?
			if(!isAI(M) && !isrobot(M) && !(M in nearby))
				_using.Remove(M)
				continue
			is_in_use = 1
			src.interact(M)
		in_use = is_in_use

/obj/proc/interact(mob/user)
	return

/obj/singularity_act()
	if(flags & INVULNERABLE)
		return
	ex_act(1)
	if(src)
		qdel(src)
	return 2

/obj/shuttle_act(datum/shuttle/S)
	return qdel(src)

/obj/singularity_pull(S, current_size)
	if(anchored)
		if(current_size >= STAGE_FIVE)
			anchored = 0
			step_towards(src, S)
	else step_towards(src, S)

/obj/proc/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return "<b>NO MULTITOOL_MENU!</b>"

/obj/proc/linkWith(var/mob/user, var/obj/buffer, var/link/context)
	return 0

/obj/proc/unlinkFrom(var/mob/user, var/obj/buffer)
	return 0

/obj/proc/canLink(var/obj/O, var/link/context)
	return 0

/obj/proc/isLinkedWith(var/obj/O)
	return 0

/obj/proc/getLink(var/idx)
	return null

/obj/proc/canClone(var/obj/O)
	return 0

/obj/proc/clone(var/obj/O)
	return 0

/obj/proc/linkMenu(var/obj/O)
	var/dat=""
	if(canLink(O, list()))
		dat += " <a href='?src=\ref[src];link=1'>\[Link\]</a> "
	return dat

/obj/proc/format_tag(var/label,var/varname, var/act="set_tag")
	var/value = vars[varname]
	if(!value || value=="")
		value="-----"
	return "<b>[label]:</b> <a href=\"?src=\ref[src];[act]=[varname]\">[value]</a>"


/obj/proc/update_multitool_menu(mob/user as mob)
	var/obj/item/device/multitool/P = get_multitool(user)

	if(!istype(P))
		return 0

	// Cloning stuff goes here.
	if(P.clone && P.buffer) // Cloning is on.
		if(!canClone(P.buffer))
			to_chat(user, "<span class='attack'>A red light flashes on \the [P]; you cannot clone to this device!</span>")
			return

		if(!clone(P.buffer))
			to_chat(user, "<span class='attack'>A red light flashes on \the [P]; something went wrong when cloning to this device!</span>")
			return

		to_chat(user, "<span class='confirm'>A green light flashes on \the [P], confirming the device was cloned to.</span>")
		return

	var/dat = {"<html>
	<head>
		<title>[name] Configuration</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
"}
	dat += multitool_menu(user,P)
	if(P)
		if(P.buffer)
			var/id = null
			if(istype(P.buffer, /obj/machinery/telecomms))
				var/obj/machinery/telecomms/buffer = P.buffer//Casting is better than using colons
				id = buffer.id
			else if(P.buffer.vars["id_tag"])//not doing in vars here incase the var is empty, it'd show ()
				id = P.buffer:id_tag//sadly, : is needed

			dat += "<p><b>MULTITOOL BUFFER:</b> [P.buffer] [id ? "([id])" : ""]"//If you can't into the ? operator, that will make it not display () if there's no ID.

			dat += linkMenu(P.buffer)

			if(P.buffer)
				dat += "<a href='?src=\ref[src];flush=1'>\[Flush\]</a>"
			dat += "</p>"
		else
			dat += "<p><b>MULTITOOL BUFFER:</b> <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a></p>"
	dat += "</body></html>"
	user << browse(dat, "window=mtcomputer")
	user.set_machine(src)
	onclose(user, "mtcomputer")

/obj/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		if(machine._using)
			machine._using -= src

			if(!machine._using.len)
				machine._using = null

		machine = null

/mob/proc/set_machine(const/obj/O)
	unset_machine()

	if(istype(O))
		machine = O

		if(!machine._using)
			machine._using = new

		machine._using += src
		machine.in_use = 1

/obj/proc/wrenchAnchor(var/mob/user) //proc to wrench an object that can be secured
	for(var/obj/other in loc) //ensure multiple things aren't anchored in one place
		if(other.anchored == 1 && other.density == 1 && density && !anchored)
			to_chat(user, "\The [other] is already anchored in this location.")
			return -1
	if(!anchored)
		if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
			if(istype(src.loc, /turf/simulated/shuttle) && !can_wrench_shuttle()) //If on the shuttle and not wrenchable to shuttle
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to this!</span>")
				return -1
			if(istype(src.loc, /turf/space)) //if on a space tile
				to_chat(user, "<span class = 'notice'>You can't secure \the [src] to space!</span>")
				return -1
	user.visible_message(	"[user] begins to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.",
							"You begin to [anchored ? "unbolt" : "bolt"] \the [src] [anchored ? "from" : "to" ] the floor.")
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(user, src, 30))
		anchored = !anchored
		user.visible_message(	"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
								"<span class='notice'>[bicon(src)] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
								"<span class='notice'>You hear a ratchet.</span>")
		return 1
	return -1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/proc/container_resist()
	return

/obj/proc/can_pickup(mob/living/user)
	return 0

/obj/proc/verb_pickup(mob/living/user)
	return 0

/obj/proc/can_quick_store(var/obj/item/I) //proc used to check that the current object can store another through quick equip
	return 0

/obj/proc/quick_store(var/obj/item/I) //proc used to handle quick storing
	return 0

/**
 * If a mob logouts/logins in side of an object you can use this proc.
 */
/obj/proc/on_log()
	if (isobj(loc))
		var/obj/location = loc
		location.on_log()

// Dummy to give items special techlist for the purposes of the Device Analyser, in case you'd ever need them to give them different tech levels depending on special checks.
/obj/proc/give_tech_list()
	return null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
