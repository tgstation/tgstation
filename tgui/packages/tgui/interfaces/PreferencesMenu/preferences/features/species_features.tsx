import {
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureColorInput,
  type FeatureValueProps,
} from './base';
import { FeatureDropdownInput } from './dropdowns';

export const eye_color: Feature<string> = {
  name: 'Глаза - цвет',
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: 'Лицевая растительность - цвет',
  component: FeatureColorInput,
};

export const facial_hair_gradient: FeatureChoiced = {
  name: 'Лицевая растительность - градиент',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const facial_hair_gradient_color: Feature<string> = {
  name: 'Лицевая растительность - цвет градиента',
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: 'Волосы - цвет',
  component: FeatureColorInput,
};

export const hair_gradient: FeatureChoiced = {
  name: 'Волосы - градиент',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const hair_gradient_color: Feature<string> = {
  name: 'Волосы - цвет градиента',
  component: FeatureColorInput,
};

export const feature_cat_ears: FeatureChoiced = {
  name: 'Уши',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_cat_tail: FeatureChoiced = {
  name: 'Хвост',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_monkey_tail: FeatureChoiced = {
  name: 'Хвост',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Ноги',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_spines: FeatureChoiced = {
  name: 'Шипы',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_tail: FeatureChoiced = {
  name: 'Хвост',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor: Feature<string> = {
  name: 'Цвет мутанта',
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Нижнее белье - цвет',
  component: FeatureColorInput,
};

export const feature_vampire_status: Feature<string> = {
  name: 'Статус вампира',
  component: FeatureDropdownInput,
};

export const heterochromatic: Feature<string> = {
  name: 'Глаза - цвет гетерохромии (правый глаз)',
  component: FeatureColorInput,
};

// BANDASTATION EDIT START
// MARK: Vulpkanin features
export const feature_vulpkanin_tail: FeatureChoiced = {
  name: 'Хвост',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_vulpkanin_head_markings: FeatureChoiced = {
  name: 'Раскраска головы',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const vulpkanin_head_markings_color: Feature<string> = {
  name: 'Раскраска головы - цвет',
  component: FeatureColorInput,
};

export const vulpkanin_body_markings_color: Feature<string> = {
  name: 'Раскраска тела - цвет',
  component: FeatureColorInput,
};

export const feature_vulpkanin_head_accessories: FeatureChoiced = {
  name: 'Кастомизация головы',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const vulpkanin_head_accessories_color: Feature<string> = {
  name: 'Кастомизация головы - цвет',
  component: FeatureColorInput,
};

export const feature_vulpkanin_facial_hair: FeatureChoiced = {
  name: 'Волосы на лице',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const vulpkanin_facial_hair_color: Feature<string> = {
  name: 'Волосы на лице - цвет',
  component: FeatureColorInput,
};

export const feature_vulpkanin_tail_markings: FeatureChoiced = {
  name: 'Хвост - раскраска',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const vulpkanin_tail_markings_color: Feature<string> = {
  name: 'Хвост - цвет',
  component: FeatureColorInput,
};

// MARK: Tajaran features
export const feature_tajaran_tail: FeatureChoiced = {
  name: 'Хвост',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_tajaran_head_markings: FeatureChoiced = {
  name: 'Узор меха головы',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const tajaran_head_markings_color: Feature<string> = {
  name: 'Узор меха головы - цвет',
  component: FeatureColorInput,
};

export const tajaran_body_markings_color: Feature<string> = {
  name: 'Узор меха - цвет',
  component: FeatureColorInput,
};

export const feature_tajaran_facial_hair: FeatureChoiced = {
  name: 'Растительность на лице',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const tajaran_facial_hair_color: Feature<string> = {
  name: 'Растительность на лице - цвет',
  component: FeatureColorInput,
};

export const feature_tajaran_tail_markings: FeatureChoiced = {
  name: 'Хвост - узор',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const tajaran_tail_markings_color: Feature<string> = {
  name: 'Хвост - цвет узора',
  component: FeatureColorInput,
};

// MARK: Skrell features
export const skrell_head_tentacle_color: Feature<string> = {
  name: 'Щупальца на голове: цвет',
  component: FeatureColorInput,
};

export const feature_skrell_head_tentacle_ornament: FeatureChoiced = {
  name: 'Украшение для щупалец',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_skrell_cloth_wrap_toggle: FeatureChoiced = {
  name: 'Ткань для щупалец',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const skrell_cloth_wrap_color: Feature<string> = {
  name: 'Ткань для щупалец: цвет',
  component: FeatureColorInput,
};
