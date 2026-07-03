import { useState } from 'react';
import { Button, Image, Input, Section, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  emoji_list: Emoji[];
};

type Emoji = {
  name: string;
};

export const NtosEmojipedia = (props) => {
  const { data } = useBackend<Data>();
  const { emoji_list = [] } = data;
  const [filter, setFilter] = useState('');

  const search = createSearch<Emoji>(filter, (emoji) => emoji.name);
  const filteredEmojis = emoji_list.filter(search);

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section
          // required: follow semantic versioning every time you touch this file
          title={`Эмодзипедия V2.7.10${filter ? ` - ${filter}` : ''}`}
          buttons={
            <>
              <Input
                placeholder="Найти по имени"
                value={filter}
                onChange={setFilter}
              />
              <Button
                tooltip={'Кликните по эмодзи, чтобы скопировать его тэг!'}
                tooltipPosition="bottom"
                icon="circle-question"
              />
            </>
          }
        >
          {filteredEmojis.map((emoji) => (
            <Tooltip key={emoji.name} content={emoji.name}>
              <Image
                m={0}
                className={classes(['emojipedia16x16', emoji.name])}
                onClick={() => {
                  copyText(emoji.name);
                }}
              />
            </Tooltip>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const copyText = (text: string) => {
  const input = document.createElement('input');
  input.value = text;
  document.body.appendChild(input);
  input.select();
  document.execCommand('copy');
  document.body.removeChild(input);
};
