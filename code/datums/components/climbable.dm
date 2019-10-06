///This components makes it possible to climb (forcemove yourself) onto an atom by clicking dragging onto it.
/datum/component/climbable
	///How long the climb act takes.
	var/climb_time
	///How long the climb act stuns the climber
	var/climb_stun
	///If the parent exhibits tablelike behaviour. Basically this means that by dragging your active item onto it, you place it onto the table.
	var/table_behaviour
	///What mobs are currently climbing the parent.
	var/list/structureclimbers

/datum/component/climbable/Initialize(climb_time = 20, climb_stun = 20, table_behaviour = TRUE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.climb_time = climb_time
	src.climb_stun = climb_stun
	src.table_behaviour = table_behaviour

/datum/component/climbable/Destroy()
	structureclimbers = null
	return ..()

/datum/component/climbable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, list(COMSIG_ATOM_BUMPED), .proc/on_bumped)
	RegisterSignal(parent, list(COMSIG_MOUSEDROPPED_ONTO), .proc/on_MouseDrop_T)
	RegisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND), .proc/on_attack_hand)
	if(istype(parent, /obj/structure/closet))
		RegisterSignal(parent, list(COMSIG_CLOSET_CLOSE), .proc/on_closet_close)
		RegisterSignal(parent, list(COMSIG_CLOSET_OPEN), .proc/on_closet_open)

///Handles the actual act of moving
/datum/component/climbable/proc/do_climb(atom/source, atom/movable/A)
	var/dense = source.density //Hacky... alternative solution
	source.density = FALSE
	step(A, get_dir(A, source))
	source.density = dense

///Handles how long climbing takes and if it is successful + feedback
/datum/component/climbable/proc/climb_structure(atom/source, mob/living/user)
	if(!structureclimbers)
		structureclimbers = list()
	if(structureclimbers[user])
		to_chat(user, "<span class='notice'>You are already climbing onto [source]</span>")
		return
	structureclimbers[user] = TRUE
	source.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [source].</span>", \
								"<span class='notice'>You start climbing onto [source]...</span>")

	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8

	if(do_after(user, adjusted_climb_time, target = source))
		do_climb(source, user)
		user.visible_message("<span class='warning'>[user] climbs onto [source].</span>", \
							"<span class='notice'>You climb onto [source].</span>")
		log_combat(user, source, "climbed onto")
		if(climb_stun)
			user.Stun(climb_stun)
	else
		to_chat(user, "<span class='warning'>You fail to climb onto [source].</span>")
	structureclimbers -= user
	if(!LAZYLEN(structureclimbers))
		structureclimbers = null

///Called on COMSIG_ATOM_ATTACK_HAND. Bumps the current climbers off the table.
/datum/component/climbable/proc/on_attack_hand(datum/source, mob/user)
	if(structureclimbers && !(user in structureclimbers) && user.a_intent != INTENT_HELP)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(source)
		for(var/i in structureclimbers)
			var/mob/living/structureclimber = i
			structureclimber.Paralyze(40)
			structureclimber.visible_message("<span class='warning'>[structureclimber] has been knocked off [source].", "You're knocked off [source]!", "You see [structureclimber] get knocked off [source].</span>")
		return COMPONENT_NO_ATTACK_HAND

///Called on COMSIG_MOUSEDROPPED_ONTO.
/datum/component/climbable/proc/on_MouseDrop_T(atom/source, atom/movable/O, mob/user)
	if(user == O && iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.mobility_flags & MOBILITY_MOVE)
			climb_structure(source, user)


///Let's a mob pass over structures if the movement is forced and that's enabled.
/datum/component/climbable/proc/on_bumped(atom/source, atom/movable/bumper)
	if(bumper.force_moving?.allow_climbing)
		do_climb(source, bumper)

/datum/component/climbable/proc/on_closet_close()
	climb_time *= 2

/datum/component/climbable/proc/on_closet_open()
	climb_time *= 0.5
