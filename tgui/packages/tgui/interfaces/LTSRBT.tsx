import {
  Button,
  Image,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  name: string;
  price: number;
  min_price: number;
  max_price: number;
  loaded_icon: string;
  desc: string;
};

export const LTSRBT = (props) => {
  const { act, data } = useBackend<Data>();
  const { name, price, min_price, max_price, loaded_icon, desc } = data;

  return (
    <Window width={300} height={380} theme="hackerman">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Input
              width="80%"
              value={name}
              placeholder="Insert a name"
              expensive
              onChange={(value) =>
                act('change_name', {
                  value: value,
                })
              }
            />
            <NumberInput
              step={1}
              width="20%"
              value={price}
              minValue={min_price}
              maxValue={max_price}
              unit="cr"
              onChange={(value) =>
                act('change_price', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Divider />
          {!!loaded_icon && (
            <Stack.Item>
              <Section align="center">
                <Image
                  m={1}
                  src={`data:image/jpeg;base64,${loaded_icon}`}
                  height="96px"
                  width="96px"
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Divider />
          <Stack.Item grow>
            <TextArea
              height="100%"
              fluid
              value={desc}
              placeholder="Insert a description (or don't)"
              expensive
              onChange={(value) =>
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
