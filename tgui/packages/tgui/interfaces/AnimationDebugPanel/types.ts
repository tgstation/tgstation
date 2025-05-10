type AnimateFlag = {
  description: string;
  value: number;
};

type AnimateEasing = {
  description: string;
  value: number;
};

type AnimateEasingFlag = AnimateFlag;

type AnimateChain = {
  next: AnimateChain | undefined;
  chain_index: number;
  var_list: Record<string, string | number> | undefined;
  appearance: undefined;
  time: number | undefined;
  loop: number | undefined;
  easing: number | undefined;
  easing_flags: number | undefined;
  flags: number | undefined;
  a_tag: string | undefined;
  command: string | undefined;
};

type AnimateArgument = {
  name: string;
  description: string;
  allowed_types: AnimateArgumentType[];
};

enum AnimateArgumentType {
  number = 'number',
  string = 'string',

  atom = '/atom',
  image = '/image',
  client = '/client',
  mutable_appearance = '/mutable_appearance',
  list = '/list',
  animate_easing = '/datum/animate_easing',
  animate_easing_flag = '/datum/animate_easing_flag',
  animate_flag = '/datum/animate_flag',
}

type AnimationDebugPanelData = {
  animate_flags: Record<string, AnimateFlag>;
  animate_easings: Record<string, AnimateEasing>;
  animate_easing_flags: Record<string, AnimateEasingFlag>;
  animate_arguments: Record<string, AnimateArgument>;
  target: string;
  chain: AnimateChain;
};
