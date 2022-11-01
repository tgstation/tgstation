// This file contains defines allowing targeting byond versions newer than the supported

#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif


#if DM_VERSION < 515
#define PROC_REF(X) (.proc/##X)
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
#define PROC_REF_STATIC(X) (.proc/##X)
#define GLOBAL_PROC_REF(X) (.proc/##X)
#else
#define PROC_REF(X) (src::##X())
#define TYPE_PROC_REF(TYPE, X) (##TYPE::/##X())
#define PROC_REF_STATIC(X) (type::##X())
#define GLOBAL_PROC_REF(X) (::##X())
#endif
