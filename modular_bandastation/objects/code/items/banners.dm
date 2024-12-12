// MARK: Banners
/obj/item/banner
	icon = 'modular_bandastation/objects/icons/obj/items/banner.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/banners_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/banners_righthand.dmi'

/obj/item/banner/atmos
	name = "atmosia banner"
	desc = "Баннер Атмосии. Молитва на воздуховодную трубу и плазму."
	icon_state = "banner_atmos"
	inhand_icon_state = "banner_atmos"

/obj/item/banner/atmos/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_ENGINEERING

/obj/item/banner/atmos/mundane
	inspiration_available = FALSE

/obj/item/banner/clown
	name = "clown banner"
	desc = "Баннер клоуна. Во имя Хонкомамы с бананчиком в руке."
	icon_state = "banner_clown"
	inhand_icon_state = "banner_clown"

/obj/item/banner/clown/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_SERVICE

/obj/item/banner/clown/mundane
	inspiration_available = FALSE

/obj/item/banner/mime
	name = "mime banner"
	desc = "..."
	icon_state = "banner_mime"
	inhand_icon_state = "banner_mime"

/obj/item/banner/mime/Initialize(mapload)
	. = ..()
	job_loyalties = DEPARTMENT_BITFLAG_SERVICE

/obj/item/banner/mime/mundane
	inspiration_available = FALSE

/obj/item/banner/ian
	name = "Ian banner"
	desc = "Баннер во славу Иана, потому что СКВИИИК."
	icon_state = "banner_ian"
	inhand_icon_state = "banner_ian"

/obj/item/banner/ian/mundane
	inspiration_available = FALSE

/obj/item/banner/cult
	name = "cult banner"
	desc = "Баннер культистов. Это не очень хорошо. Или хорошо, смотря с какой стороны посмотреть."
	icon_state = "banner_cult"
	inhand_icon_state = "banner_cult"

/obj/item/banner/cult/mundane
	inspiration_available = FALSE

/obj/item/banner/ninja
	name = "spider clan banner"
	desc = "Баннер клана Паука. Навивает тревожное чувство паранои."
	icon_state = "banner_ninja"
	inhand_icon_state = "banner_ninja"

/obj/item/banner/ninja/mundane
	inspiration_available = FALSE

/obj/item/banner/syndicate
	name = "syndicate banner"
	desc = "Баннер, на котором гордо развевается красные и черные цвета Синдиката, крупнейшей организованной преступной структуры в Секторе."
	icon_state = "banner_syndicate"
	inhand_icon_state = "banner_syndicate"

/obj/item/banner/syndicate/mundane
	inspiration_available = FALSE

/obj/item/banner/solgov
	name = "solgov banner"
	desc = "На баннере гордо развевается золотое солнце Транс-Солнечной Федерации, де-факто милитаристской сверхдержавы Сектора."
	icon_state = "banner_solgov"
	inhand_icon_state = "banner_solgov"

/obj/item/banner/solgov/mundane
	inspiration_available = FALSE

/obj/item/banner/ussp
	name = "ussp banner"
	desc = "На баннере гордо развевается серп и молот КСП, могущественной социалистической державы."
	icon_state = "banner_ussp"
	inhand_icon_state = "banner_ussp"

/obj/item/banner/ussp/mundane
	inspiration_available = FALSE

/obj/item/banner/wizard
	name = "wizard banner"
	desc = "Баннер с эмблемой Федерации магов, объединяющей террористические ячейки магов."
	icon_state = "banner_wizard"
	inhand_icon_state = "banner_wizard"

/obj/item/banner/wizard/mundane
	inspiration_available = FALSE

// MARK: Species banners
/obj/item/banner/species
	icon_state = null

/obj/item/banner/species/vox
	name = "vox banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Воксов."
	icon_state = "banner_vox"
	inhand_icon_state = "banner_vox"

/obj/item/banner/species/vox/mundane
	inspiration_available = FALSE

/obj/item/banner/species/diona
	name = "dionas banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Дион."
	icon_state = "banner_diona"
	inhand_icon_state = "banner_diona"

/obj/item/banner/species/diona/mundane
	inspiration_available = FALSE

/obj/item/banner/species/grey
	name = "greytide banner"
	desc = "Баннер, сделаный из старого серого комбинезона."
	icon_state = "banner_grey"
	inhand_icon_state = "banner_grey"

/obj/item/banner/species/grey/mundane
	inspiration_available = FALSE

/obj/item/banner/species/greys
	name = "greys banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Греев."
	icon_state = "banner_greys"
	inhand_icon_state = "banner_greys"

/obj/item/banner/species/greys/mundane
	inspiration_available = FALSE

/obj/item/banner/species/human
	name = "humans banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Людей."
	icon_state = "banner_human"
	inhand_icon_state = "banner_human"

/obj/item/banner/species/human/mundane
	inspiration_available = FALSE

/obj/item/banner/species/vulpkanin
	name = "vulpkanin banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Вульпканинов."
	icon_state = "banner_vulpkanin"
	inhand_icon_state = "banner_vulpkanin"

/obj/item/banner/species/vulpkanin/mundane
	inspiration_available = FALSE

/obj/item/banner/species/drask
	name = "drask banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Драсков."
	icon_state = "banner_drask"
	inhand_icon_state = "banner_drask"

/obj/item/banner/species/drask/mundane
	inspiration_available = FALSE

/obj/item/banner/species/nian
	name = "nian banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Ниан."
	icon_state = "banner_nian"
	inhand_icon_state = "banner_nian"

/obj/item/banner/species/nian/mundane
	inspiration_available = FALSE

/obj/item/banner/species/tajaran
	name = "tajaran banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Таяран."
	icon_state = "banner_tajaran"
	inhand_icon_state = "banner_tajaran"

/obj/item/banner/species/tajaran/mundane
	inspiration_available = FALSE

/obj/item/banner/species/unathi
	name = "unathi banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Унати."
	icon_state = "banner_unathi"
	inhand_icon_state = "banner_unathi"

/obj/item/banner/species/unathi/mundane
	inspiration_available = FALSE

/obj/item/banner/species/machine
	name = "plasmaman banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Плазмаменов."
	icon_state = "banner_plasma"
	inhand_icon_state = "banner_plasma"

/obj/item/banner/species/machine/mundane
	inspiration_available = FALSE

/obj/item/banner/species/skrell
	name = "skrell banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Скреллов."
	icon_state = "banner_skrell"
	inhand_icon_state = "banner_skrell"

/obj/item/banner/species/skrell/mundane
	inspiration_available = FALSE

/obj/item/banner/species/slime
	name = "slime banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Слаймов."
	icon_state = "banner_slime"
	inhand_icon_state = "banner_slime"

/obj/item/banner/species/slime/mundane
	inspiration_available = FALSE

/obj/item/banner/species/kidan
	name = "kidan banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Киданов."
	icon_state = "banner_kidan"
	inhand_icon_state = "banner_kidan"

/obj/item/banner/species/kidan/mundane
	inspiration_available = FALSE

/obj/item/banner/species/machine
	name = "machine banner"
	desc = "Баннер, гордо провозглашающий превосходящее влияние Синтетиков."
	icon_state = "banner_machine"
	inhand_icon_state = "banner_machine"

/obj/item/banner/species/machine/mundane
	inspiration_available = FALSE

// MARK: Override to defaults
/obj/item/banner/red
	icon = 'icons/obj/banner.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'

/obj/item/banner/blue
	icon = 'icons/obj/banner.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
