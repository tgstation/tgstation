#define ROTATION_ALTCLICK 1
#define ROTATION_WRENCH 2
#define ROTATION_CLOCKWISE 4

/datum/component/simple_rotation
	var/datum/callback/can_user_rotate //Checks if user can rotate
	var/datum/callback/can_be_rotated  //Check if object can be rotated at all
	var/datum/callback/after_rotation     //Additional stuff to do after rotation
	
	var/rotation_flags = NONE

	//verbs ? 
	//flipping ?

/datum/component/simple_rotation/Initialize(rotation_flags = NONE ,can_user_rotate,can_be_rotated,after_rotation)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.rotation_flags = rotation_flags

	if(can_user_rotate)
		src.can_user_rotate = can_user_rotate
	else
		src.can_user_rotate = CALLBACK(src,.proc/default_can_user_rotate)
	
	if(can_be_rotated)
		src.can_be_rotated = can_be_rotated
	else
		src.can_be_rotated = CALLBACK(src,.proc/default_can_be_rotated)

	if(after_rotation)
		src.after_rotation = after_rotation
	else
		src.after_rotation = CALLBACK(src,.proc/default_after_rotation)

	if(src.rotation_flags & ROTATION_ALTCLICK)
		RegisterSignal(COMSIG_CLICK_ALT, .proc/HandRot)
		RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/ExamineMessage)
	if(src.rotation_flags & ROTATION_WRENCH)
		RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/WrenchRot)

/datum/component/simple_rotation/proc/ExamineMessage(mob/user)
	if(rotation_flags & ROTATION_ALTCLICK)
		to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/datum/component/simple_rotation/proc/HandRot(mob/user)
	if(!can_be_rotated.Invoke(user) || !can_user_rotate.Invoke(user))
		return
	BaseRot(user)

/datum/component/simple_rotation/proc/WrenchRot(obj/item/I, mob/living/user)
	if(!can_be_rotated.Invoke(user) || !can_user_rotate.Invoke(user))
		return
	if(istype(I,/obj/item/wrench))
		BaseRot(user)
		return COMPONENT_NO_AFTERATTACK

/datum/component/simple_rotation/proc/BaseRot(mob/user)
	var/atom/movable/AM = parent
	AM.setDir(turn(AM.dir,rotation_flags & ROTATION_CLOCKWISE ? 90 : -90))
	after_rotation.Invoke(user)

/datum/component/simple_rotation/proc/default_can_user_rotate(mob/living/user)
	if(!istype(user) || !user.Adjacent(parent) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	return TRUE

/datum/component/simple_rotation/proc/default_can_be_rotated(mob/user)
	var/atom/movable/AM = parent
	return !AM.anchored

/datum/component/simple_rotation/proc/default_after_rotation(mob/user)
	to_chat(user,"<span class='notice'>You rotate [parent]</span>")
