import { decodeHtmlEntities } from 'common/string';

import { useBackend } from '../backend';
import {
  Button,
  Image,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const LTSRBT = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={300} height={380} theme="hackerman">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Input
              width="80%"
              value={data.name}
              placeholder="Insert a name"
              onChange={(e, value) =>
                act('change_name', {
                  value: value,
                })
              }
            />
            <NumberInput
              width="20%"
              value={data.price}
              minValue={data.min_price}
              maxValue={data.max_price}
              unit="cr"
              onChange={(e, value) =>
                act('change_price', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Divider />
          {!!data.loaded_icon && (
            <Stack.Item>
              <Section align="center">
                <Image
                  m={1}
                  src={`data:image/jpeg;base64,${data.loaded_icon}`}
                  height="96px"
                  width="96px"
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Divider />
          <Stack.Item grow>
            <TextArea
              height="40%"
              value={data.desc}
              placeholder="Insert a description (or don't)"
              onChange={(e, value) =>
                act('change_desc', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item>
            <Button.Confirm
              fluid
              icon="truck-arrow-right"
              content="Place on Market"
              onClick={() => act('place_on_market')}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
