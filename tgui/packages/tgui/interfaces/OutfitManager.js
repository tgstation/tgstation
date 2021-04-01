import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, Stack } from '../components';
import { Window } from '../layouts';

export const OutfitManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { outfits } = data;
  const [selectedOutfit, setCurrentOutfit] = useLocalState(
    context, 'currentOutfit', '');

  return (
    <Window
      width={275}
      height={300}>
      <Window.Content scrollable>

        <Section fill
          title="Custom Outfit Manager"
          buttons={
            <>
              <Button
                icon="file-upload"
                tooltip="Load an outfit from a file"
                tooltipPosition="left" />
              <Button
                icon="plus"
                tooltip="Create a new outfit"
                tooltipPosition="left" />
            </>
          } >
          <Stack vertical>
            {outfits?.map(outfit => (
              <Stack.Item key={outfit.ref}>
                <Stack>
                  <Stack.Item grow={1}>
                    <Button
                      fluid
                      content={outfit.name} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="pencil-alt"
                      tooltip="Edit this outfit"
                      tooltipPosition="left" />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      icon="save"
                      tooltip="Save this outfit to a file"
                      tooltipPosition="left" />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      color="bad"
                      icon="trash-alt"
                      tooltip="Delete this outfit"
                      tooltipPosition="left" />
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

