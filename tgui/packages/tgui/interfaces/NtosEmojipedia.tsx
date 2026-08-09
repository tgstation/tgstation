import { useState } from 'react';
import { Button, Input, Section } from 'tgui-core/components';
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
    <NtosWindow width={600} height={640}>
      <NtosWindow.Content scrollable>
        <Section
          // required: follow semantic versioning every time you touch this file
          title={`Emojipedia V3.7.10${filter ? ` - ${filter}` : ''}`}
          buttons={
            <>
              <Input
                placeholder="Search by name"
                value={filter}
                onChange={setFilter}
              />
              <Button
                tooltip={'Click on an emoji to copy its tag!'}
                tooltipPosition="bottom"
                icon="circle-question"
              />
            </>
          }
        >
          {filteredEmojis.map((emoji) => (
            <Button
              verticalAlign
              key={emoji.name}
              tooltip={emoji.name}
              width="16px"
              height="16px"
              className={classes(['emojipedia16x16', emoji.name])}
              m={1.5}
              onClick={() => {
                copyText(`:${emoji.name}:`);
              }}
              style={{
                imageRendering: 'pixelated',
                transform: 'scale(2)',
                verticalAlign: 'middle',
              }}
            />
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
