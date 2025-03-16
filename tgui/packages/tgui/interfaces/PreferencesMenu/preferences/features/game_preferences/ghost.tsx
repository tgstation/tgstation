import { binaryInsertWith } from 'common/collections';
import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Flex } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { PreferencesMenuData } from '../../../types';
import {
  CheckboxInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureToggle,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const ghost_accs: FeatureChoiced = {
  name: 'Призрачные аксессуары',
  category: 'Призрак',
  description: 'Определяет, какие настройки будут у вашего призрака.',
  component: FeatureDropdownInput,
};

type GhostForm = {
  displayText: ReactNode;
  value: string;
};

function insertGhostForm(collection: GhostForm[], value: GhostForm) {
  return binaryInsertWith(collection, value, ({ value }) => value);
}

function GhostFormInput(
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) {
  const { data } = useBackend<PreferencesMenuData>();

  const serverData = props.serverData;
  if (!serverData) {
    return <> </>;
  }

  const displayNames = serverData.display_names;
  if (!displayNames) {
    return <Box color="red">No display names for ghost_form!</Box>;
  }

  const displayTexts = {};
  let options: {
    displayText: ReactNode;
    value: string;
  }[] = [];

  for (const [name, displayName] of Object.entries(displayNames)) {
    const displayText = (
      <Flex key={name}>
        <Flex.Item>
          <Box
            className={classes([`preferences32x32`, serverData.icons![name]])}
          />
        </Flex.Item>

        <Flex.Item grow={1}>{displayName}</Flex.Item>
      </Flex>
    );

    displayTexts[name] = displayText;

    const optionEntry = {
      displayText,
      value: name,
    };

    // Put the default ghost on top
    if (name === 'ghost') {
      options.unshift(optionEntry);
    } else {
      options = insertGhostForm(options, optionEntry);
    }
  }

  return (
    <Dropdown
      autoScroll={false}
      disabled={!data.content_unlocked}
      selected={props.value}
      placeholder={displayTexts[props.value]}
      onSelected={props.handleSetValue}
      width="100%"
      options={options}
    />
  );
}

export const ghost_form: FeatureChoiced = {
  name: 'Призрак форма',
  category: 'Призрак',
  description: 'Появление вашего призрака. Требуется подписка на BYOND.',
  component: GhostFormInput,
};

export const ghost_hud: FeatureToggle = {
  name: 'Призрак HUD',
  category: 'Призрак',
  description: 'Включите кнопки HUD для призраков.',
  component: CheckboxInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: 'Призрачная орбита',
  category: 'Призрак',
  description: `
    Форма, в которой ваш призрак будет вращаться по орбите.
    Требуется членство в BYOND.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const { data } = useBackend<PreferencesMenuData>();

    return (
      <FeatureDropdownInput {...props} disabled={!data.content_unlocked} />
    );
  },
};

export const ghost_others: FeatureChoiced = {
  name: 'Призраки других людей',
  category: 'Призрак',
  description: `
    Вы хотите, чтобы призраки других людей отображались в их собственных настройках, как
    их спрайты по умолчанию или всегда как белый призрак по умолчанию?
  `,
  component: FeatureDropdownInput,
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Призрачная любознательность',
  category: 'Призрак',
  description:
    'Нажав на что-то в качестве призрака, вы сможете изучить предметы.',
  component: CheckboxInput,
};

export const ghost_roles: FeatureToggle = {
  name: 'Получайте роли призраков',
  category: 'Призрак',
  description: `
    Если вы снимите этот флажок, вы больше никогда не увидите всплывающих окон с ролями-призраками!
    Все эти всплывающие окна будут отключены, когда вы будете
    отображаться как призрак. Очень полезно для тех, кого раздражают призрачные роли или
    всплывающие окна, используйте на свой страх и риск.
`,
  component: CheckboxInput,
};
