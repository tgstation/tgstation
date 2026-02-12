import { useState } from 'react';
import {
  Box,
  DmIcon,
  Flex,
  ImageButton,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type CoreDisplayOption = {
  name: string;
  icon_state: string;
  icon: string;
};

type CurrentIcon = {
  icon: string;
  icon_state: string;
};

type Data = {
  current_display: string;
  current_icon: CurrentIcon | null;
  options: CoreDisplayOption[];
};

export const AiCoreDisplayPicker = () => {
  return (
    <Window width={500} height={600} title="AI Core Display Options">
      <Window.Content scrollable>
        <AiCoreDisplayPickerContent />
      </Window.Content>
    </Window>
  );
};

const AiCoreDisplayPickerContent = () => {
  const { act, data } = useBackend<Data>();
  const { current_display, current_icon, options = [] } = data;

  const [searchTerm, setSearchTerm] = useState('');
  const [tiledView, setTiledView] = useState(false);

  // Filter options based on search term
  const filteredOptions = options.filter((option) =>
    option.name.toLowerCase().includes(searchTerm.toLowerCase()),
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Current AI Core Display">
          <Flex align="center" justify="center" direction="column">
            {current_icon && (
              <Flex.Item mb={2}>
                <Box
                  style={{
                    border: '2px solid #4a9eff',
                    borderRadius: '4px',
                    backgroundColor: '#1a1a1a',
                    padding: '8px',
                  }}
                >
                  <DmIcon
                    icon={current_icon.icon}
                    icon_state={current_icon.icon_state}
                    width="64px"
                    height="64px"
                  />
                </Box>
              </Flex.Item>
            )}
            <Flex.Item>
              <Box fontSize="1.2em" textAlign="center" bold color="good">
                {current_display}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Input
          placeholder="Search display options..."
          value={searchTerm}
          onChange={(value) => setSearchTerm(value)}
          fluid
        />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="AI Core Display Options">
              <OptionsList options={filteredOptions} />
            </Section>
          </Stack.Item>

          {filteredOptions.length === 0 && (
            <Stack.Item>
              <Box textAlign="center" color="average" mt={4}>
                No options found matching "{searchTerm}"
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const OptionsList = ({ options }: { options: CoreDisplayOption[] }) => {
  const { act } = useBackend<Data>();

  return (
    <>
      {options.map((option) => (
        <ImageButton
          key={option.name}
          dmIcon={option.icon}
          dmIconState={option.icon_state}
          onClick={() => act('select_option', { option: option.name })}
          imageSize={64}
          tooltip={option.name}
        >
          {option.name}
        </ImageButton>
      ))}
    </>
  );
};
