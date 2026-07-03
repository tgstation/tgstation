import { binaryInsertWith } from 'common/collections';
import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Button,
  FitText,
  Icon,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../../backend';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { Name } from '../types';
import { useServerPrefs } from '../useServerPrefs';

type NameInputProps = {
  name: string;
  nameType: string;
  canRandomize: BooleanLike;
  large?: boolean;
};

export function NameInput(props: NameInputProps) {
  const { name, nameType, canRandomize, large } = props;
  const { act } = useBackend();
  const [lastNameBeforeEdit, setLastNameBeforeEdit] = useState<string | null>(
    null,
  );

  const editing = lastNameBeforeEdit === name;
  function updateName(value) {
    setLastNameBeforeEdit(null);
    act('set_preference', {
      preference: nameType,
      value,
    });
  }

  return (
    <Stack fill fontSize={large && 1.33}>
      <Stack.Item grow className="PreferencesMenu__Name">
        <Button
          fluid
          captureKeys={!editing}
          onClick={() => setLastNameBeforeEdit(name)}
        >
          <Stack fill>
            {large && !editing && (
              <Stack.Item>
                <Icon name="edit" />
              </Stack.Item>
            )}
            <Stack.Item grow>
              {editing ? (
                <>
                  <Input
                    autoSelect
                    value={name}
                    onBlur={updateName}
                    onEscape={() => {
                      setLastNameBeforeEdit(null);
                    }}
                  />
                  <Icon name="question" /> {/* Save layout on edit */}
                </>
              ) : (
                <FitText maxFontSize={large ? 16 : 13} maxWidth={130}>
                  {name || '(нет имени)'}
                </FitText>
              )}
            </Stack.Item>
          </Stack>
        </Button>
      </Stack.Item>
      {!!canRandomize && !editing && (
        <Stack.Item>
          <Button
            icon="dice"
            tooltip="Рандомизировать"
            tooltipPosition="right"
            onClick={() => act('randomize_name', { preference: nameType })}
          />
        </Stack.Item>
      )}
    </Stack>
  );
}

type NameWithKey = {
  key: string;
  name: Name;
};

function binaryInsertName(
  collection: NameWithKey[],
  value: NameWithKey,
): NameWithKey[] {
  return binaryInsertWith(collection, value, ({ key }) => key);
}

function sortNameWithKeyEntries(array: [string, NameWithKey[]][]) {
  return sortBy(array, [([key]) => key]);
}

type MultiNameProps = {
  names: Record<string, string>;
};

export function AlternativeNames(props: MultiNameProps) {
  const data = useServerPrefs();
  if (!data) {
    return <LoadingScreen />;
  }

  const namesIntoGroups: Record<string, NameWithKey[]> = {};
  for (const [key, name] of Object.entries(data.names.types)) {
    namesIntoGroups[name.group] = binaryInsertName(
      namesIntoGroups[name.group] || [],
      {
        key,
        name,
      },
    );
  }

  return (
    <Section fill scrollable title="Альтернативные имена">
      <Stack vertical>
        {sortNameWithKeyEntries(Object.entries(namesIntoGroups)).map(
          ([_, names], index, collection) =>
            index !== 0 &&
            names.map(({ key, name }) => {
              return (
                <Stack key={key} vertical className="PreferencesMenu__AltName">
                  <Stack.Item className="PreferencesMenu__AltName--explanation">
                    {name.explanation}
                  </Stack.Item>
                  <NameInput
                    name={props.names[key]}
                    nameType={key}
                    canRandomize={name.can_randomize}
                  />
                </Stack>
              );
            }),
        )}
      </Stack>
    </Section>
  );
}
