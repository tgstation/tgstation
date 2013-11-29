/**
* DNA 2: The Spaghetti Strikes Back
*
* @author N3X15 <nexisentertainment@gmail.com>
*/

// What each index means:
#define DNA_OFF_LOWERBOUND 0
#define DNA_OFF_UPPERBOUND 1
#define DNA_ON_LOWERBOUND  2
#define DNA_ON_UPPERBOUND  3

#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095)

// Defines which values mean "on" or "off".
//  This is to make some of the more OP superpowers a larger PITA to activate,
//  and to tell our new DNA datum which values to set in order to turn something
//  on or off.
var/global/list/dna_activity_bounds[STRUCDNASIZE]

// Used to determine what each block means (admin hax, mostly)
var/global/list/assigned_blocks[STRUCDNASIZE]

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R      1
#define DNA_UI_HAIR_G      2
#define DNA_UI_HAIR_B      3
#define DNA_UI_BEARD_R     4
#define DNA_UI_BEARD_G     5
#define DNA_UI_BEARD_B     6
#define DNA_UI_SKIN_TONE   7
#define DNA_UI_EYES_R      8
#define DNA_UI_EYES_G      9
#define DNA_UI_EYES_B      10
#define DNA_UI_GENDER      11
#define DNA_UI_BEARD_STYLE 12
#define DNA_UI_HAIR_STYLE  13
#define DNA_UI_LENGTH      13 // Update this or you WILL break shit.

/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

/proc/GetDNABounds(var/block)
	var/list/BOUNDS=dna_activity_bounds[block]
	if(!istype(BOUNDS))
		return DNA_DEFAULT_BOUNDS
	return BOUNDS

/datum/dna
	// READ-ONLY, GETS OVERWRITTEN
	// DO NOT FUCK WITH THESE OR BYOND WILL EAT YOUR FACE
	var/uni_identity="" // Encoded UI
	var/struc_enzymes="" // Encoded SE
	var/unique_enzymes="" // MD5 of player name

	// Internal dirtiness checks
	var/dirtyUI=0
	var/dirtySE=0

	// Okay to read, but you're an idiot if you do.
	// BLOCK = VALUE
	var/list/SE[STRUCDNASIZE]
	var/list/UI[DNA_UI_LENGTH]

	// From old dna.
	var/b_type = "A+"  // Should probably change to an integer => string map but I'm lazy.
	var/mutantrace = null  // The type of mutant race the player is, if applicable (i.e. potato-man)
	var/real_name          // Stores the real name of the person who originally got this dna datum. Used primarily for changelings,

///////////////////////////////////////
// UNIQUE IDENTITY
///////////////////////////////////////

// Create random UI.
/datum/dna/proc/ResetUI(var/defer=0)
	for(var/i=1,i<=DNA_UI_LENGTH,i++)
		UI[i]=rand(0,4095)
	if(!defer)
		UpdateUI()

/datum/dna/proc/ResetUIFrom(var/mob/living/carbon/human/character)
	// INITIALIZE!
	ResetUI(1)
	// Hair
	// FIXME:  Species-specific defaults pls
	if(!character.h_style)
		character.h_style = "Skinhead"
	var/hair = hair_styles_list.Find(character.h_style)

	// Facial Hair
	if(!character.f_style)
		character.f_style = "Shaved"
	var/beard	= facial_hair_styles_list.Find(character.f_style)

	var/gender
	if(character.gender == MALE)
		gender = rand(1,(2050+BLOCKADD))
	else
		gender = rand((2051+BLOCKADD),4094)

	SetUIValue(DNA_UI_HAIR_R,   character.r_hair,              1)
	SetUIValue(DNA_UI_HAIR_G,   character.g_hair,              1)
	SetUIValue(DNA_UI_HAIR_B,   character.b_hair,              1)
	SetUIValue(DNA_UI_BEARD_R,  character.r_facial,            1)
	SetUIValue(DNA_UI_BEARD_G,  character.g_facial,            1)
	SetUIValue(DNA_UI_BEARD_B,  character.b_facial,            1)
	SetUIValue(DNA_UI_SKIN_TONE,(character.s_tone + 220) * 16, 1)
	SetUIValue(DNA_UI_BEARD_R,  character.r_eyes,              1)
	SetUIValue(DNA_UI_BEARD_G,  character.g_eyes,              1)
	SetUIValue(DNA_UI_BEARD_B,  character.b_eyes,              1)
	SetUIValue(DNA_UI_GENDER,   gender,                        1)

	SetUIValueRange(DNA_UI_HAIR_STYLE,  hair,  hair_styles_list.len,       1)
	SetUIValueRange(DNA_UI_BEARD_STYLE, beard, facial_hair_styles_list.len,1)

	UpdateUI()

// Set a DNA UI block's raw value.
/datum/dna/proc/SetUIValue(var/block,var/value,var/defer=0)
	ASSERT(value>=0)
	ASSERT(value<=4095)
	UI[block]=value
	if(defer)
		dirtyUI=1
	else
		UpdateUI()

// Get a DNA UI block's raw value.
/datum/dna/proc/GetUIValue(var/block)
	return UI[block]

// Set a DNA UI block's value, given a value and a max possible value.
// Used in hair and facial styles (value being the index and maxvalue being the len of the hairstyle list)
/datum/dna/proc/SetUIValueRange(var/block,var/value,var/maxvalue)
	ASSERT(maxvalue<=4095)
	var/range = round(4095 / maxvalue)
	if(value)
		SetUIValue(block,value * range - rand(1,range-1))

/datum/dna/proc/GetUIValueRange(var/block,var/maxvalue)
	var/value = GetUIValue(block)
	return round(1 +(value / 4096)*maxvalue)

/datum/dna/proc/GetUIState(var/block)
	return UI[block] > 2050

/datum/dna/proc/SetUIState(var/block,var/on,var/defer=0)
	var/val
	if(on)
		val=rand(2050,4095)
	else
		val=rand(1,2049)
	SetUIValue(block,val,defer)

/datum/dna/proc/GetUIBlock(var/block)
	return EncodeDNABlock(GetUIValue(block))

// Do not use this unless you absolutely have to.
/datum/dna/proc/SetUIBlock(var/block,var/value,var/defer=0)
	return SetUIValue(block,hex2num(value),defer)

/datum/dna/proc/GetUISubBlock(var/block,var/subBlock)
	return copytext(GetUIBlock(block),subBlock,subBlock+1)

/datum/dna/proc/SetUISubBlock(var/block,var/subBlock, var/newSubBlock, var/defer=0)
	var/oldBlock=GetUIBlock(block)
	var/newBlock=""
	for(var/i=1, i<=length(oldBlock), i++)
		if(i==subBlock)
			newBlock+=newSubBlock
		else
			newBlock+=copytext(oldBlock,i,i+1)
	SetUIBlock(block,newBlock,defer)

///////////////////////////////////////
// STRUCTURAL ENZYMES
///////////////////////////////////////

// Zeroes out all of the blocks.
/datum/dna/proc/ResetSE()
	for(var/i = 1, i <= STRUCDNASIZE, i++)
		SetSEValue(i,rand(1,1024),1)

	UpdateSE()

// Set a DNA SE block's raw value.
/datum/dna/proc/SetSEValue(var/block,var/value,var/defer=0)
	ASSERT(value>=0)
	ASSERT(value<=4095)
	SE[block]=value
	if(defer)
		dirtySE=1
	else
		UpdateSE()

// Get a DNA SE block's raw value.
/datum/dna/proc/GetSEValue(var/block)
	return SE[block]

// Set a DNA SE block's value, given a value and a max possible value.
// Might be used for species?
/datum/dna/proc/SetSEValueRange(var/block,var/value,var/maxvalue)
	ASSERT(maxvalue<=4095)
	var/range = round(4095 / maxvalue)
	if(value)
		SetSEValue(block, value * range - rand(1,range-1))

/datum/dna/proc/GetSEState(var/block)
	var/list/BOUNDS=GetDNABounds(block)
	var/value=GetSEValue(block)
	return (value > BOUNDS[DNA_ON_LOWERBOUND])

/datum/dna/proc/SetSEState(var/block,var/on,var/defer=0)
	var/list/BOUNDS=GetDNABounds(block)
	var/val
	if(on)
		val=rand(BOUNDS[DNA_ON_LOWERBOUND],BOUNDS[DNA_ON_UPPERBOUND])
	else
		val=rand(BOUNDS[DNA_OFF_LOWERBOUND],BOUNDS[DNA_OFF_UPPERBOUND])
	SetSEValue(block,val,defer)

/datum/dna/proc/GetSEBlock(var/block)
	return EncodeDNABlock(GetSEValue(block))

// Do not use this unless you absolutely have to.
/datum/dna/proc/SetSEBlock(var/block,var/value,var/defer=0)
	var/nval=hex2num(value)
	testing("SetSESBlock([block],[value],[defer]): [value] -> [nval]")
	return SetSEValue(block,nval,defer)

/datum/dna/proc/GetSESubBlock(var/block,var/subBlock)
	return copytext(GetSEBlock(block),subBlock,subBlock+1)

/datum/dna/proc/SetSESubBlock(var/block,var/subBlock, var/newSubBlock, var/defer=0)
	var/oldBlock=GetSEBlock(block)
	var/newBlock=""
	for(var/i=1, i<=length(oldBlock), i++)
		if(i==subBlock)
			newBlock+=newSubBlock
		else
			newBlock+=copytext(oldBlock,i,i+1)
	SetSEBlock(block,newBlock,defer)


/proc/EncodeDNABlock(var/value)
	return add_zero2(num2hex(value,1), 3)

/datum/dna/proc/UpdateUI()
	src.unique_enzymes=""
	for(var/block in UI)
		unique_enzymes += EncodeDNABlock(block)
	dirtyUI=0

/datum/dna/proc/UpdateSE()
	var/oldse=struc_enzymes
	struc_enzymes=""
	for(var/block in SE)
		struc_enzymes += EncodeDNABlock(block)
	testing("Old SE: [oldse]")
	testing("New SE: [struc_enzymes]")
	dirtySE=0

// BACK-COMPAT!
//  Just checks our character has all the crap it needs.
/datum/dna/proc/check_integrity(var/mob/living/carbon/human/character)
	if(character)
		if(UI.len != DNA_UI_LENGTH)
			ResetUIFrom(character)

		if(length(struc_enzymes)!= 3*STRUCDNASIZE)
			ResetSE()

		if(length(unique_enzymes) != 32)
			unique_enzymes = md5(character.real_name)
	else
		if(length(uni_identity) != 3*DNA_UI_LENGTH)
			uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		if(length(struc_enzymes)!= 3*STRUCDNASIZE)
			struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"

// BACK-COMPAT!
//  Initial DNA setup.  I'm kind of wondering why the hell this doesn't just call the above.
/datum/dna/proc/ready_dna(mob/living/carbon/human/character)
	ResetUIFrom(character)

	ResetSE()

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

