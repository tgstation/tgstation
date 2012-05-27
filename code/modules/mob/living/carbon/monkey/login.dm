/mob/living/carbon/monkey/Login()
	..()

	rebuild_appearance()
	/*
	if (!( src.primary ))
		var/t1 = rand(1000, 1500)
		dna_ident += t1
		if (dna_ident > 65536.0)
			dna_ident = rand(1, 1500)
		src.primary = new /datum/dna( null )
		src.primary.uni_identity = text("[]", dna_ident)
		while(length(src.primary.uni_identity) < 4)
			src.primary.uni_identity = text("0[]", src.primary.uni_identity)
		var/t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = text("[]", rand(1, 256))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		t2 = (src.gender == "male" ? text("[]", rand(1, 124)) : text("[]", rand(127, 250)))
		if (length(t2) < 2)
			src.primary.uni_identity = text("[]0[]", src.primary.uni_identity, t2)
		else
			src.primary.uni_identity = text("[][]", src.primary.uni_identity, t2)
		src.primary.spec_identity = "2B6696D2B127E5A4"
		src.primary.struc_enzymes = "CDEAF5B90AADBC6BA8033DB0A7FD613FA"
		src.primary.unique_enzymes = "C8FFFE7EC09D80AEDEDB9A5A0B4085B61"
		src.primary.n_chromo = 16
	*/

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghost
	if(src.name == "monkey")
		src.name = text("monkey ([rand(1, 1000)])")
	src.real_name = src.name
	return