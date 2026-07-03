import {
  Button,
  Collapsible,
  Dropdown,
  Icon,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { BodyModification, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

type BodyModificationsProps = {
  handleClose: () => void;
};

export const BodyModificationsPage = (props: BodyModificationsProps) => {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <Modal className="PreferencesMenu__Augmentations">
      <Section
        fill
        scrollable
        title={
          <Stack fill className="PreferencesMenu__AugmentationsTitle">
            <Stack.Item>
              <Icon name="robot" />
            </Stack.Item>
            <Stack.Item grow>Модификации тела</Stack.Item>
            <Stack.Item>
              <Button
                fontSize={1.1}
                icon="times"
                color="red"
                tooltip="Закрыть"
                tooltipPosition="top"
                onClick={props.handleClose}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <BodyModificationsPageInner
          bodyModification={serverData.body_modifications}
        />
      </Section>
    </Modal>
  );
};

const BodyModificationsPageInner = (props: {
  bodyModification: BodyModification[];
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    applied_body_modifications = [],
    incompatible_body_modifications = [],
  } = data;

  const appliedModifications = props.bodyModification.filter((mod) =>
    applied_body_modifications.includes(mod.key),
  );

  const modificationsByCategory: Record<string, BodyModification[]> = {};
  props.bodyModification.forEach((mod) => {
    const category = mod.category;
    if (category) {
      if (!modificationsByCategory[category]) {
        modificationsByCategory[category] = [];
      }
      modificationsByCategory[category].push(mod);
    }
  });

  return (
    <>
      {appliedModifications.length > 0 && (
        <Collapsible open title="Применённые модификации" color="blue">
          <Stack vertical>
            {appliedModifications.map((mod, index) => (
              <BodyModificationRow
                key={mod.key}
                added
                index={index}
                bodyModification={mod}
              />
            ))}
          </Stack>
        </Collapsible>
      )}
      {Object.entries(modificationsByCategory).map(([category, mods]) => (
        <Collapsible key={category} title={category} open>
          <Stack vertical>
            {mods.map((mod, index) => (
              <BodyModificationRow
                key={mod.key}
                index={index}
                bodyModification={mod}
                usedKeys={[
                  ...applied_body_modifications,
                  ...incompatible_body_modifications,
                ]}
              />
            ))}
          </Stack>
        </Collapsible>
      ))}
    </>
  );
};

const BodyModificationRow = (props: {
  bodyModification: BodyModification;
  added?: boolean;
  usedKeys?: string[];
  index: number;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const isUsed = props.usedKeys?.includes(props.bodyModification.key) || false;
  const manufacturers =
    data.manufacturers?.[props.bodyModification.key] || null;
  const selectedBrand =
    data.selected_manufacturer?.[props.bodyModification.key] ||
    (manufacturers ? manufacturers[0] : null);

  return (
    <Stack fill className="PreferencesMenu__AugmentationsRow">
      <Stack.Item className="PreferencesMenu__AugmentationsRow--name">
        {props.bodyModification.name}
      </Stack.Item>
      <Stack className="PreferencesMenu__AugmentationsRow--actions">
        {Array.isArray(manufacturers) && props.added && (
          <Dropdown
            width={7.5}
            menuWidth={17.5}
            selected={selectedBrand ?? ''}
            options={manufacturers.map((brand: string) => ({
              value: brand,
              displayText: brand === 'None' ? 'Без протеза' : brand,
            }))}
            onSelected={(brand) =>
              act('set_body_modification_manufacturer', {
                body_modification_key: props.bodyModification.key,
                manufacturer: brand,
              })
            }
          />
        )}
        {props.added ? (
          <Button
            fluid
            icon="times"
            color="red"
            onClick={() =>
              act('remove_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
          >
            Удалить
          </Button>
        ) : (
          <Button
            fluid
            icon="plus"
            color={isUsed ? 'grey' : 'green'}
            disabled={isUsed}
            onClick={() =>
              act('apply_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
          >
            Добавить
          </Button>
        )}
      </Stack>
    </Stack>
  );
};
