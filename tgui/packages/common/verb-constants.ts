export const ARG_TYPE_TEXT = 1 << 0;
export const ARG_TYPE_NUM = 1 << 1;
export const ARG_TYPE_MESSAGE = 1 << 2;
export const ARG_TYPE_SOUND = 1 << 3;
export const ARG_TYPE_ICON = 1 << 4;
export const ARG_TYPE_MOB = 1 << 5;
export const ARG_TYPE_OBJ = 1 << 6;
export const ARG_TYPE_TURF = 1 << 7;
export const ARG_TYPE_AREA = 1 << 8;
export const ARG_TYPE_DATUM = 1 << 9;
export const ARG_TYPE_ATOM = 1 << 10;
export const ARG_TYPE_TYPEPATH = 1 << 11;

export const ARG_TYPE_ENTITY =
  ARG_TYPE_MOB |
  ARG_TYPE_OBJ |
  ARG_TYPE_TURF |
  ARG_TYPE_AREA |
  ARG_TYPE_DATUM |
  ARG_TYPE_ATOM;

export const ARG_TYPE_PRIMITIVE =
  ARG_TYPE_TEXT |
  ARG_TYPE_NUM |
  ARG_TYPE_MESSAGE |
  ARG_TYPE_SOUND |
  ARG_TYPE_ICON |
  ARG_TYPE_TYPEPATH;

export const ARG_SOURCE_LIST = 'list';

export type VerbArgBase = {
  arg_type: number;
  source: string | null;
  options?: string[];
};

export function isTypepathArg(arg: VerbArgBase): boolean {
  return (arg.arg_type & ARG_TYPE_TYPEPATH) !== 0;
}

export function isEntityArg(arg: VerbArgBase): boolean {
  return (arg.arg_type & ARG_TYPE_ENTITY) !== 0;
}

export function isTextArg(arg: VerbArgBase): boolean {
  return (arg.arg_type & (ARG_TYPE_TEXT | ARG_TYPE_MESSAGE)) !== 0;
}

export function isListArg(arg: VerbArgBase): boolean {
  return (
    arg.source === ARG_SOURCE_LIST &&
    Array.isArray(arg.options) &&
    arg.options.length > 0
  );
}
