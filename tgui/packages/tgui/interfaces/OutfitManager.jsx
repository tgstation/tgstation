import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const OutfitManager = (props) => {
  const { act, data } = useBackend();
  const { outfits } = data;
  return (
    <Window title="Outfit Manager" width={300} height={300} theme="admin">
      <Window.Content>
        <Section
          fill
          scrollable
          title="Custom Outfit Manager"
          buttons={
            <>
              <Button
                icon="file-upload"
                tooltip="Load an outfit from a file"
                tooltipPosition="left"
                onClick={() => act('load')}
              />
              <Button
                icon="copy"
                tooltip="Copy an already existing outfit"
                tooltipPosition="left"
                onClick={() => act('copy')}
              />
              <Button
                icon="plus"
                tooltip="Create a new outfit"
                tooltipPosition="left"
                onClick={() => act('new')}
              />
            </>
          }
        >
          <Stack vertical>
            {outfits?.map((outfit) => (
              <Stack.Item key={outfit.ref}>
                <Stack>
                  <Stack.Item
                    grow={1}
                    shrink={1}
                    style={{
                      overflow: 'hidden',
                      whiteSpace: 'nowrap',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    <Button
                      fluid
                      style={{
                        overflow: 'hidden',
                        whiteSpace: 'nowrap',
                        textOverflow: 'ellipsis',
                      }}
                      content={outfit.name}
                      onClick={() => act('edit', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      icon="save"
                      tooltip="Save this outfit to a file"
                      tooltipPosition="left"
                      onClick={() => act('save', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      color="bad"
                      icon="trash-alt"
                      tooltip="Delete this outfit"
                      tooltipPosition="left"
                      onClick={() => act('delete', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
