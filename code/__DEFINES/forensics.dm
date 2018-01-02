#define IF_HAS_BLOOD_DNA(__thing) GET_COMPONENT_FROM(__FR##__thing, /datum/component/forensics, __thing); if(__FR##__thing && length(__FR##__thing.blood_DNA))
#define IF_HAS_BLOOD_DNA_AND(__thing, __conditions...) GET_COMPONENT_FROM(__FR##__thing, /datum/component/forensics, __thing); if(__FR##__thing && length(__FR##__thing.blood_DNA) && (##__conditions))
