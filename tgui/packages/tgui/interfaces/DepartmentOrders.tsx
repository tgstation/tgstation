import { useBackend } from '../backend';
import { Button, Dimmer, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type Pack = {
  name: string;
  cost: number;
  id: string;
  desc: string;
  goody: string;
  access: string;
}

type Category = {
  packs: Pack[];
}

type Info = {
  time_left: number;
  supplies: Category[];
};

export const DepartmentOrders = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    time_left,
  } = data;
  return (
    <Window
      width={620}
      height={580} >
      <Window.Content>
        {time_left
          && <CooldownDimmer />
          || (
            <Stack vertical fill>
              <Stack.Item grow>
                <Section scrollable fill>
                  <Stack vertical>
                    <Stack.Item >
                      Order ready!
                    </Stack.Item>
                    <Stack.Item>
                      <DepartmentCatalog />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          )}
      </Window.Content>
    </Window>
  );
};

const CooldownDimmer = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    time_left,
  } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon
            color="orange"
            name="route"
            size={10}
          />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="orange">
          Ready for another order in {time_left} seconds...
        </Stack.Item>
        <Stack.Item fontSize="18px" color="orange">
          <Button
            tooltip="This action requires Head of Staff access!"
            fontSize="14px"
            color="red">
            Override
          </Button>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const DepartmentCatalog = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    supplies,
  } = data;
  return (
    <Stack>
      <Stack.Item>
        {typeof supplies}
      </Stack.Item>
    </Stack>
  );
};
