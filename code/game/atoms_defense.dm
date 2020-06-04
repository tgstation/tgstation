//Collection of procs that handle atom integrity

/// To be ran during initialization of any subclass of atom that needs integrity, IE /obj, /turf.
/atom/proc/set_up_integrity()
	if(atom_integrity == null)
		atom_integrity = max_integrity
	if (islist(armor))
		armor = getArmor(arglist(armor))
	else if (!armor)
		armor = getArmor()
	else if (!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /atom Initialize()")

///the essential proc to call when an atom must receive damage of any kind.
/atom/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
    if(QDELETED(src))
        stack_trace("[src] taking damage after deletion")
        return
    if(sound_effect)
        play_attack_sound(damage_amount, damage_type, damage_flag)
    if((resistance_flags & INDESTRUCTIBLE) || atom_integrity <= 0)
        return
    damage_amount = run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
    if(damage_amount < DAMAGE_PRECISION)
        return
    . = damage_amount
    atom_integrity = max(atom_integrity - damage_amount, 0)
    //BREAKING FIRST
    if(integrity_failure && atom_integrity <= integrity_failure * max_integrity)
        atom_break(damage_flag)
    //DESTROYING SECOND
    if(atom_integrity <= 0)
        atom_destruction(damage_flag)

///returns the damage value of the attack after processing the atom's various armor protections
/atom/proc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	if(damage_amount < damage_deflection)
		return 0
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp(armor_protection - armour_penetration, min(armor_protection, 0), 100)
	return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)

///the sound played when the atom is damaged.
/atom/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

///changes max_integrity while retaining current health percentage, returns TRUE if the atom got broken.
/atom/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE)
	var/current_integrity = atom_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))	//don't destroy it as a result
		atom_integrity = current_integrity

	max_integrity = new_max

	if(can_break && integrity_failure && current_integrity <= integrity_failure * max_integrity)
		atom_break(damage_type)
		return TRUE
	return FALSE

///what happens when the atom's integrity reaches zero. to be overridden.
/atom/proc/atom_destruction(damage_flag)
	return

///called after the atom takes damage and integrity is below integrity_failure level. to be overridden.
/atom/proc/atom_break(damage_flag)
	return

///Called to get the damage that hulks will deal to the atom.
/atom/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this object, is affected by melee armor

