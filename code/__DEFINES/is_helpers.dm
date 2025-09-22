// simple is_type and similar inline helpers

#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

/// Within given range and on the same z level (get dist is WEIRD bro)
#define IN_GIVEN_RANGE(source, other, given_range) (get_dist(source, other) <= given_range && (get_step(source, 0)?:z) == (get_step(other, 0)?:z))

#define isatom(A) (isloc(A))

#define isdatum(thing) (istype(thing, /datum))

#define isweakref(D) (istype(D, /datum/weakref))

#define isimage(thing) (istype(thing, /image))

GLOBAL_VAR_INIT(magic_appearance_detecting_image, new /image) // appearances are awful to detect safely, but this seems to be the best way ~ninjanomnom
#define isappearance(thing) (!isimage(thing) && !ispath(thing) && istype(GLOB.magic_appearance_detecting_image, thing))

// The filters list has the same ref type id as a filter, but isnt one and also isnt a list, so we have to check if the thing has Cut() instead
GLOBAL_VAR_INIT(refid_filter, TYPEID(filter(type="angular_blur")))
#define isfilter(thing) (!hascall(thing, "Cut") && TYPEID(thing) == GLOB.refid_filter)

#define isgenerator(A) (istype(A, /generator))

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/open/space,
	/turf/open/chasm,
	/turf/open/lava,
	/turf/open/water,
	/turf/open/openspace,
	/turf/open/space/openspace
	)))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))

GLOBAL_LIST_INIT(turfs_no_slip_water, typecacheof(list(
	/turf/open/misc/asteroid,
	/turf/open/misc/dirt,
	/turf/open/misc/grass,
	/turf/open/misc/basalt,
	/turf/open/misc/ashplanet,
	/turf/open/misc/snow,
	/turf/open/misc/sandy_dirt,
	/turf/open/floor/noslip,
	)))

#define isnoslipturf(A) (is_type_in_typecache(A, GLOB.turfs_no_slip_water))

GLOBAL_LIST_INIT(turfs_openspace, typecacheof(list(
	/turf/open/openspace,
	/turf/open/space/openspace
	)))

#define isopenspaceturf(A) (is_type_in_typecache(A, GLOB.turfs_openspace))

#define isopenturf(A) (istype(A, /turf/open))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define is_space_or_openspace(A) (isopenspaceturf(A) || isspaceturf(A))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define ismiscturf(A) (istype(A, /turf/open/misc))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/closed/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/lava))

#define ischasm(A) (istype(A, /turf/open/chasm))

#define isplatingturf(A) (istype(A, /turf/open/floor/plating))

#define iscatwalkturf(A) (istype(A, /turf/open/floor/catwalk_floor))

#define isasteroidturf(A) (istype(A, /turf/open/misc/asteroid))

#define istransparentturf(A) (HAS_TRAIT(A, TURF_Z_TRANSPARENT_TRAIT))

#define iscliffturf(A) (istype(A, /turf/open/cliff))

#define iswaterturf(A) (istype(A, /turf/open/water))

GLOBAL_LIST_INIT(turfs_pass_meteor, typecacheof(list(
	/turf/closed/mineral,
	/turf/open/misc/asteroid,
	/turf/open/openspace,
	/turf/open/space
)))

#define ispassmeteorturf(A) (is_type_in_typecache(A, GLOB.turfs_pass_meteor))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isdummy(A) (istype(A, /mob/living/carbon/human/dummy))

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isghostspecies(A) (is_species(A, /datum/species/ghost))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isashwalker(A) (is_species(A, /datum/species/lizard/ashwalker))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispodperson(A) (is_species(A, /datum/species/pod))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isjellyperson(A) (is_species(A, /datum/species/jelly))
#define isslimeperson(A) (is_species(A, /datum/species/jelly/slime))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ismoth(A) (is_species(A, /datum/species/moth))
#define isfelinid(A) (is_species(A, /datum/species/human/felinid))
#define isethereal(A) (is_species(A, /datum/species/ethereal))
#define isvampire(A) (is_species(A,/datum/species/human/vampire))
#define isdullahan(A) (is_species(A, /datum/species/dullahan))
#define ismonkey(A) (is_species(A, /datum/species/monkey))
#define isandroid(A) (is_species(A, /datum/species/android))
#define isnightmare(A) (is_species(A, /datum/species/shadow/nightmare))


//More carbon mobs
#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/adult) || istype(A, /mob/living/basic/alien))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/adult/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/adult/sentinel))

#define isalienroyal(A) (istype(A, /mob/living/carbon/alien/adult/royal))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/adult/royal/queen))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))
#define isAI(A) (istype(A, /mob/living/silicon/ai))
#define iscyborg(A) (istype(A, /mob/living/silicon/robot))
#define ispAI(A) (istype(A, /mob/living/silicon/pai))

///This is used to see if you have Silicon access. This includes things like Admins, Drones, Bots, and Human wands.
#define HAS_SILICON_ACCESS(possible_silicon) (HAS_TRAIT(possible_silicon, TRAIT_SILICON_ACCESS) || isAdminGhostAI(possible_silicon))
///This is used to see if you have the access of an AI. This doesn't mean you are an AI, just have the same access as one.
#define HAS_AI_ACCESS(possible_ai) (HAS_TRAIT(possible_ai, TRAIT_AI_ACCESS) || isAdminGhostAI(possible_ai))

// basic mobs
#define isbasicmob(A) (istype(A, /mob/living/basic))

#define isconstruct(A) (istype(A, /mob/living/basic/construct))

#define iscow(A) (istype(A, /mob/living/basic/cow))

#define isgorilla(A) (istype(A, /mob/living/basic/gorilla))

#define isshade(A) (istype(A, /mob/living/basic/shade))

#define is_simian(A) (isgorilla(A) || ismonkey(A))

/// returns whether or not the atom is either a basic mob OR simple animal
#define isanimal_or_basicmob(A) (istype(A, /mob/living/simple_animal) || istype(A, /mob/living/basic))

/// asteroid mobs, which are both simple and basic atm
#define ismining(A) (A.mob_biotypes & MOB_MINING)

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isrevenant(A) (istype(A, /mob/living/basic/revenant))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot) || istype(A, /mob/living/basic/bot))

#define isbasicbot(A) (istype(A, /mob/living/basic/bot))

#define ismouse(A) (istype(A, /mob/living/basic/mouse))

#define isslime(A) (istype(A, /mob/living/basic/slime))

#define isdrone(A) (istype(A, /mob/living/basic/drone))

#define iscat(A) (istype(A, /mob/living/basic/pet/cat))

#define isdog(A) (istype(A, /mob/living/basic/pet/dog))

#define iscorgi(A) (istype(A, /mob/living/basic/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isregalrat(A) (istype(A, /mob/living/basic/regal_rat))

#define isguardian(A) (istype(A, /mob/living/basic/guardian))

#define ismegafauna(A) (istype(A, /mob/living/simple_animal/hostile/megafauna) || istype(A, /mob/living/basic/boss))

#define isclown(A) (istype(A, /mob/living/basic/clown))

#define isspider(A) (istype(A, /mob/living/basic/spider))

//Eye mobs
#define iseyemob(A) (istype(A, /mob/eye))

#define isovermind(A) (istype(A, /mob/eye/blob))

#define iscameramob(A) (istype(A, /mob/eye/camera))

#define isaicamera(A) (istype(A, /mob/eye/camera/ai))

#define isremotecamera(A) (istype(A, /mob/eye/camera/remote))

//Dead mobs
#define isdead(A) (istype(A, /mob/dead))

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isfish(A) (istype(A, /obj/item/fish))

#define isstack(A) (istype(A, /obj/item/stack))

#define isgrenade(A) (istype(A, /obj/item/grenade))

#define islandmine(A) (istype(A, /obj/effect/mine))

#define iscloset(A) (istype(A, /obj/structure/closet))

#define issupplypod(A) (istype(A, /obj/structure/closet/supplypod))

#define isammocasing(A) (istype(A, /obj/item/ammo_casing))

#define isidcard(I) (istype(I, /obj/item/card/id))

#define isstructure(A) (istype(A, /obj/structure))

#define ismachinery(A) (istype(A, /obj/machinery))

#define istramwall(A) (istype(A, /obj/structure/tram))

#define isvendor(A) (istype(A, /obj/machinery/vending))

#define isvehicle(A) (istype(A, /obj/vehicle))

#define ismecha(A) (istype(A, /obj/vehicle/sealed/mecha))

#define isorgan(A) (istype(A, /obj/item/organ))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define ispickedupmob(A) (istype(A, /obj/item/mob_holder)) // Checks if clothing item is actually a held mob

#define iscash(A) (istype(A, /obj/item/coin) || istype(A, /obj/item/stack/spacecash) || istype(A, /obj/item/holochip))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

#define isprojectile(A) (istype(A, /obj/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

#define isammobox(A) (istype(A, /obj/item/ammo_box))

#define isinstrument(A) (istype(A, /obj/item/instrument) || istype(A, /obj/structure/musician))

#define is_reagent_container(O) (istype(O, /obj/item/reagent_containers))

#define isapc(A) (istype(A, /obj/machinery/power/apc))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

#define iseffect(O) (istype(O, /obj/effect))

#define isholoeffect(O) (istype(O, /obj/effect/holodeck_effect))

#define isshuttleturf(T) (!isnull(T.depth_to_find_baseturf(/turf/baseturf_skipover/shuttle)))

#define isProbablyWallMounted(O) (O.pixel_x > 20 || O.pixel_x < -20 || O.pixel_y > 20 || O.pixel_y < -20)
#define isbook(O) (is_type_in_typecache(O, GLOB.book_types))

// Is this an iron tile, or a material tile made from iron?
#define ismetaltile(tile_thing) (istype(tile_thing, /obj/item/stack/tile/iron) || istype(tile_thing, /obj/item/stack/tile/material) && tile_thing.has_material_type(/datum/material/iron))

GLOBAL_LIST_INIT(book_types, typecacheof(list(
	/obj/item/book,
	/obj/item/spellbook,
	/obj/item/infuser_book,
	/obj/item/storage/photo_album,
	/obj/item/storage/card_binder,
	/obj/item/codex_cicatrix,
	/obj/item/toy/eldritch_book,
	/obj/item/toy/talking/codex_gigas,
	/obj/item/book_of_babel,
)))

// Jobs
#define is_job(job_type)  (istype(job_type, /datum/job))
#define is_assistant_job(job_type) (istype(job_type, /datum/job/assistant))
#define is_bartender_job(job_type) (istype(job_type, /datum/job/bartender))
#define is_captain_job(job_type) (istype(job_type, /datum/job/captain))
#define is_chaplain_job(job_type) (istype(job_type, /datum/job/chaplain))
#define is_clown_job(job_type) (istype(job_type, /datum/job/clown))
#define is_mime_job(job_type) (istype(job_type, /datum/job/mime))
#define is_detective_job(job_type) (istype(job_type, /datum/job/detective))
#define is_scientist_job(job_type) (istype(job_type, /datum/job/scientist))
#define is_security_officer_job(job_type) (istype(job_type, /datum/job/security_officer))
#define is_research_director_job(job_type) (istype(job_type, /datum/job/research_director))
#define is_unassigned_job(job_type) (istype(job_type, /datum/job/unassigned))

#define isprojectilespell(thing) (istype(thing, /datum/action/cooldown/spell/pointed/projectile))
#define is_multi_tile_object(atom) (atom.bound_width > ICON_SIZE_X || atom.bound_height > ICON_SIZE_Y)

#define is_area_nearby_station(checked_area) (istype(checked_area, /area/space) || istype(checked_area, /area/space/nearstation) || istype(checked_area, /area/station/asteroid))
