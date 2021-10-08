import { useBackend, useLocalState } from '../backend';
import { Button, Dimmer, Icon, NoticeBox, Section, Stack, Tabs } from '../components';
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
  name: string;
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
                <Stack fill vertical>
                  <Stack.Item>
                    <Section fill>
                      <NoticeBox info>
                        As employees of Nanotrasen, the selection of orders
                        here are completely free of charge, only incurring
                        a cooldown on the service. Cheaper items will make
                        you wait for less time before Nanotrasen allows
                        another purchase, to encourage tasteful spending.
                      </NoticeBox>
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow>
                    <DepartmentCatalog />
                  </Stack.Item>
                </Stack>
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
  const [
    tabName,
    setTabName,
  ] = useLocalState(context, 'tabName', supplies[0]);
  return (
    <Section fill>
      <Stack vertical>
        <Stack.Item>
          <Tabs textAlign="center" fluid>
            {Object.keys(supplies).map(cat => (
              <Tabs.Tab
                key={cat}
                selected={cat === tabName}
                onClick={() => (setTabName(cat))}>
                {cat}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          {tabName}
        </Stack.Item>
        <Stack.Item>
          {Object.keys(supplies)[tabIndex]}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
