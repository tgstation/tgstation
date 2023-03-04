import { classes } from 'common/react';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, Input, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosEmojipedia = (props, context) => {
  const { data } = useBackend(context);
  const { emoji_list } = data;
  const [filter, updatefilter] = useSharedState(context, 'filter', '');

  let filtered_emoji_list = filter
    ? emoji_list.filter((emoji) => {
      return emoji.name.toLowerCase().includes(filter.toLowerCase());
    })
    : emoji_list;
  if (filtered_emoji_list.length === 0) {
    filtered_emoji_list = emoji_list;
  }

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section
          // required: follow semantic versioning every time you touch this file
          title={'Emojipedia V2.7.9' + (filter ? ` - ${filter}` : '')}
          buttons={
            <>
              <Input
                type="text"
                placeholder="Search by name"
                value={filter}
                onInput={(_, value) => updatefilter(value)}
              />
              <Button
                tooltip={'Click on an emoji to copy its tag!'}
                tooltipPosition="bottom"
                icon="circle-question"
              />
            </>
          }>
          {filtered_emoji_list.map((emoji) => (
            <Box
              key={emoji.name}
              className={classes(['emojipedia16x16', emoji.name])}
              as="img"
              m={0}
              title={emoji.name}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
              onClick={() => {
                new Promise((resolve, _) => {
                  const input = document.createElement('input');
                  input.value = emoji.name;
                  document.body.appendChild(input);
                  input.select();
                  document.execCommand('copy');
                  document.body.removeChild(input);
                  resolve();
                });
              }}>
              {emoji.name}
            </Box>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
