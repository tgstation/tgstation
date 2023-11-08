/datum/component/dart_insert
	var/list/var_modifiers
	var/obj/item/ammo_casing/holder_casing
	var/obj/projectile/holder_projectile
	var/casing_overlay_icon
	var/casing_overlay_icon_state
	var/projectile_overlay_icon
	var/projectile_overlay_icon_state

/datum/component/dart_insert/Initialize(_casing_overlay_icon, _casing_overlay_icon_state, _projectile_overlay_icon, _projectile_overlay_icon_state)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	casing_overlay_icon = _casing_overlay_icon
	casing_overlay_icon_state = _casing_overlay_icon_state
	projectile_overlay_icon = _projectile_overlay_icon
	projectile_overlay_icon_state = _projectile_overlay_icon_state
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_preattack))

/datum/component/dart_insert/proc/on_preattack(datum/source, atom/target, mob/user, params)
	var/obj/item/ammo_casing/foam_dart/dart = target
	if(!istype(dart))
		return
	if(!dart.modified)
		to_chat(user, span_warning("The safety cap prevents you from inserting [parent] into [dart]."))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(HAS_TRAIT(dart, TRAIT_DART_HAS_INSERT))
		to_chat(user, span_warning("There's already something in [dart]."))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	add_to_dart(dart, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/dart_insert/proc/add_to_dart(obj/item/ammo_casing/dart, mob/user)
	var/obj/projectile/dart_projectile = dart.loaded_projectile
	var/obj/item/parent_item = parent
	if(user)
		if(!user.transferItemToLoc(parent_item, dart_projectile))
			return
		to_chat(user, span_notice("You insert [parent_item] into [dart]."))
	else
		parent_item.forceMove(dart_projectile)
	ADD_TRAIT(dart, TRAIT_DART_HAS_INSERT, REF(src))
	RegisterSignal(dart, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_dart_attack_self))
	RegisterSignal(dart, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_dart_examine_more))
	RegisterSignals(parent, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(on_leave_dart))
	RegisterSignal(dart, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_casing_update_overlays))
	RegisterSignal(dart_projectile, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_projectile_update_overlays))
	RegisterSignals(dart_projectile, list(COMSIG_PROJECTILE_ON_SPAWN_DROP, COMSIG_PROJECTILE_ON_SPAWN_EMBEDDED), PROC_REF(on_spawn_drop))
	apply_var_modifiers(dart_projectile)
	dart.harmful = dart_projectile.damage > 0 || dart_projectile.wound_bonus > 0 || dart_projectile.bare_wound_bonus > 0
	SEND_SIGNAL(parent, COMSIG_DART_INSERT_ADDED, dart)
	dart.update_appearance()
	dart_projectile.update_appearance()
	holder_casing = dart
	holder_projectile = dart_projectile

/datum/component/dart_insert/proc/remove_from_dart(obj/item/ammo_casing/dart, obj/projectile/projectile, mob/user)
	holder_casing = null
	holder_projectile = null
	if(istype(dart))
		UnregisterSignal(dart, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ATOM_EXAMINE_MORE, COMSIG_ATOM_UPDATE_OVERLAYS))
		REMOVE_TRAIT(dart, TRAIT_DART_HAS_INSERT, REF(src))
		dart.update_appearance()
	if(istype(projectile))
		remove_var_modifiers(projectile)
		UnregisterSignal(projectile, list(COMSIG_PROJECTILE_ON_SPAWN_DROP, COMSIG_PROJECTILE_ON_SPAWN_EMBEDDED, COMSIG_ATOM_UPDATE_OVERLAYS))
		if(dart?.loaded_projectile == projectile)
			dart.harmful = projectile.damage > 0 || projectile.wound_bonus > 0 || projectile.bare_wound_bonus > 0
		projectile.update_appearance()
	SEND_SIGNAL(parent, COMSIG_DART_INSERT_REMOVED, dart, projectile, user)
	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	if(user)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), parent)
		to_chat(user, span_notice("You remove [parent] from [dart]."))

/datum/component/dart_insert/proc/on_dart_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	remove_from_dart(holder_casing, holder_projectile, user)

/datum/component/dart_insert/proc/on_dart_examine_more(datum/source, mob/user, list/examine_list)
	var/obj/item/parent_item = parent
	examine_list += span_notice("You can see a [parent_item.name] inserted into it.")

/datum/component/dart_insert/proc/on_leave_dart()
	SIGNAL_HANDLER
	remove_from_dart(holder_casing, holder_projectile)

/datum/component/dart_insert/proc/on_spawn_drop(datum/source, obj/item/ammo_casing/new_casing)
	SIGNAL_HANDLER
	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	add_to_dart(new_casing)

/datum/component/dart_insert/proc/on_casing_update_overlays(datum/source, list/new_overlays)
	SIGNAL_HANDLER
	new_overlays += mutable_appearance(casing_overlay_icon, casing_overlay_icon_state)

/datum/component/dart_insert/proc/on_projectile_update_overlays(datum/source, list/new_overlays)
	SIGNAL_HANDLER
	new_overlays += mutable_appearance(projectile_overlay_icon, projectile_overlay_icon_state)

/datum/component/dart_insert/proc/apply_var_modifiers(obj/projectile/projectile)
	LAZYINITLIST(var_modifiers)
	SEND_SIGNAL(parent, COMSIG_DART_INSERT_GET_VAR_MODIFIERS, var_modifiers)
	projectile.damage += var_modifiers["damage"]
	if(var_modifiers["speed"])
		var_modifiers["speed"] = reciprocal_add(projectile.speed, var_modifiers["speed"]) - projectile.speed
	projectile.speed += var_modifiers["speed"]
	projectile.armour_penetration += var_modifiers["armour_penetration"]
	projectile.wound_bonus += var_modifiers["wound_bonus"]
	projectile.bare_wound_bonus += var_modifiers["bare_wound_bonus"]
	projectile.demolition_mod += var_modifiers["demolition_mod"]
	if(islist(var_modifiers["embedding"]))
		var/list/embed_params = var_modifiers["embedding"]
		for(var/embed_param in embed_params - "ignore_throwspeed_threshold")
			LAZYADDASSOC(projectile.embedding, embed_param, embed_params[embed_param])
		projectile.updateEmbedding()

/datum/component/dart_insert/proc/remove_var_modifiers(obj/projectile/projectile)
	projectile.damage -= var_modifiers["damage"]
	projectile.speed -= var_modifiers["speed"]
	projectile.armour_penetration -= var_modifiers["armour_penetration"]
	projectile.wound_bonus -= var_modifiers["wound_bonus"]
	projectile.bare_wound_bonus -= var_modifiers["bare_wound_bonus"]
	projectile.demolition_mod -= var_modifiers["demolition_mod"]
	if(islist(var_modifiers["embedding"]))
		var/list/embed_params = var_modifiers["embedding"]
		for(var/embed_param in embed_params - "ignore_throwspeed_threshold")
			LAZYADDASSOC(projectile.embedding, embed_param, -embed_params[embed_param])
		projectile.updateEmbedding()
	var_modifiers.Cut()
