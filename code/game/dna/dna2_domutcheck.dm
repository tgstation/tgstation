// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
#define MUTCHK_FORCED        1

/proc/domutcheck(var/mob/living/M, var/connected=null, var/flags=0)
	if(!M)
		//testing("[gene.name] has No mob")
		return

	for(var/gene_type in dna_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		//testing("Checking [gene.name]")
		if(!gene.block)
			//testing("[gene.name] has no block")
			continue
		/*
		if(istype(M,/mob/living/simple_animal/chicken) && M.dna)
			var/datum/dna/chicken_dna = M.dna
			if(chicken_dna.SE[DNA_SE_LENGTH] < 800)
				chicken_dna.chicken2vox(M,chicken_dna)//havinagiggle.tiff
		*/

		domutation(gene, M, connected, flags)
		// To prevent needless copy pasting of code i put this commented out section
		// into domutation so domutcheck and genemutcheck can both use it.
		/*
		// Sanity checks, don't skip.
		if(!gene.can_activate(M,flags))
			//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
			continue

		// Current state
		var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
		if(!gene_active)
			gene_active = M.dna.GetSEState(gene.block)

		// Prior state
		var/gene_prior_status = (gene.type in M.active_genes)
		var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

		// If gene state has changed:
		if(changed)
			// Gene active (or ALWAYS ACTIVATE)
			if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
				//testing("[gene.name] activated!")
				gene.activate(M,connected,flags)
				if(M)
					M.active_genes |= gene.type
					M.update_icon = 1
			// If Gene is NOT active:
			else
				//testing("[gene.name] deactivated!")
				gene.deactivate(M,connected,flags)
				if(M)
					M.active_genes -= gene.type
					M.update_icon = 1
		*/

// Use this to force a mut check on a single gene!
/proc/genemutcheck(var/mob/living/M, var/block, var/connected=null, var/flags=0)
	if(!M)
		return
	if(block < 0)
		return

	var/datum/dna/gene/gene = assigned_gene_blocks[block]
	domutation(gene, M, connected, flags)


/proc/domutation(var/datum/dna/gene/gene, var/mob/living/M, var/connected=null, var/flags=0)
	//testing("domutation on [gene.name] with [M] and [flags]")
	if(!gene || !istype(gene))
		return 0


	// Current state
	var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
	if(!gene_active)
		gene_active = M.dna.GetSEState(gene.block)

	// Prior state
	var/gene_prior_status = (gene.type in M.active_genes)
	var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
			// Sanity checks, don't skip.
			if(!gene.can_activate(M,flags))
				//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
				return 0

			//testing("[gene.name] activated!")
			gene.activate(M,connected,flags)
			if(M)
				M.active_genes |= gene.type
				M.update_icon = 1
		// If Gene is NOT active:
		else
			//testing("[gene.name] deactivated!")
			var/tempflag = flags
			if(ishuman(M))
				tempflag |= (((ishuman(M) && M:species) && gene.block in M:species:default_blocks) ? 4 : 0)
			gene.deactivate(M,connected,tempflag)
			if(M)
				//testing("Removing [gene.name]([gene.type]) from activegenes")
				if(!(tempflag & GENE_NATURAL))
					M.active_genes.Remove(gene.type)
					//testing("[M] [act ? "" : "un"]successfully removed [gene.type] from active_genes")
					M.update_icon = 1

/* Something for turkeyday
/datum/dna/proc/chicken2vox(var/mob/living/simple_animal/chicken/C, var/datum/dna/D)//sadly doesn't let you turn normal chicken into voxes since they don't have any DNA


	var/mob/living/carbon/human/vox/V = new(C.loc)

	if (D.GetUIState(DNA_UI_GENDER))
		V.setGender(FEMALE)
	else
		V.setGender(MALE)

	if(C.mind)
		C.mind.transfer_to(V)

	qdel(C)
*/