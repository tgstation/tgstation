import { useState } from 'react';
import { Button, Input, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const RuNamesSuggestPanel = (props) => {
  const { act, data } = useBackend();
  const visible_name = data.visible_name;
  const [nominative, setNominative] = useState('');
  const [genitive, setGenitive] = useState('');
  const [dative, setDative] = useState('');
  const [accusative, setAccusative] = useState('');
  const [instrumental, setInstrumental] = useState('');
  const [prepositional, setPrepositional] = useState('');
  return (
    <Window theme="admin" title="Предложение перевода" width={450} height={250}>
      <Window.Content />
      <Section title={'Оригинал: ' + visible_name}>
        <LabeledList>
          <LabeledList.Item label="Именительный (Кто? Что?)">
            <Input
              width="100%"
              value={nominative}
              placeholder="Клоун/Ассистуха..."
              onChange={(e, value) => setNominative(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Родительный (Кого? Чего?)">
            <Input
              width="100%"
              value={genitive}
              placeholder="Клоуна/Ассистухи..."
              onChange={(e, value) => setGenitive(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Дательный (Кому? Чему?)">
            <Input
              width="100%"
              value={dative}
              placeholder="Клоуну/Ассистухе..."
              onChange={(e, value) => setDative(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Винительный (Кого? Что?)">
            <Input
              width="100%"
              value={accusative}
              placeholder="Клоуна/Ассистуху..."
              onChange={(e, value) => setAccusative(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Творительный (Кем? Чем?)">
            <Input
              width="100%"
              value={instrumental}
              placeholder="Клоуном/Ассистухой..."
              onChange={(e, value) => setInstrumental(value)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Предложный (О/В ком/чём?)">
            <Input
              width="100%"
              value={prepositional}
              placeholder="Клоуне/Ассистухе..."
              onChange={(e, value) => setPrepositional(value)}
            />
          </LabeledList.Item>
        </LabeledList>
        <Button.Confirm
          fluid
          textAlign="center"
          mt={1.5}
          confirmColor="green"
          confirmContent="Вы уверены?"
          disabled={
            !nominative ||
            !genitive ||
            !dative ||
            !accusative ||
            !instrumental ||
            !prepositional
          }
          onClick={() =>
            act('send', {
              entries: [
                nominative,
                genitive,
                dative,
                accusative,
                instrumental,
                prepositional,
              ],
            })
          }
        >
          Отправить
        </Button.Confirm>
      </Section>
    </Window>
  );
};
