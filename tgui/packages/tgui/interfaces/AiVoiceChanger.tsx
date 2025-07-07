import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  loud: BooleanLike;
  name: string;
  on: BooleanLike;
  say_verb: string;
  selected: string;
  voices: string[];
};

export function AiVoiceChanger(props) {
  const { act, data } = useBackend<Data>();
  const { loud, name, on, say_verb, voices, selected } = data;

  return (
    <Window title="Voice changer settings" width={400} height={200}>
      <Section fill>
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon={on ? 'power-off' : 'times'}
              selected={!!on}
              onClick={() => act('power')}
            >
              {on ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Accent">
            <Dropdown
              options={voices}
              onSelected={(value) => {
                act('look', {
                  look: value,
                });
              }}
              selected={selected}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Verb">
            <Input
              value={say_verb}
              onBlur={(value) =>
                act('verb', {
                  verb: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Volume">
            <Button
              icon={loud ? 'power-off' : 'times'}
              selected={!!loud}
              onClick={() => act('loud')}
            >
              {loud ? 'Loudmode on' : 'Loudmode Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Fake name">
            <Input
              value={name}
              onBlur={(value) =>
                act('name', {
                  name: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
}
