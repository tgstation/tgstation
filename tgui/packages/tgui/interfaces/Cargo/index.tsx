import { Button, Section, Stack, Tabs } from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { CargoCartButtons } from './CargoButtons';
import { CargoCart } from './CargoCart';
import { CargoCatalog } from './CargoCatalog';
import { CargoHelp } from './CargoHelp';
import { CargoRequests } from './CargoRequests';
import { CargoStatus } from './CargoStatus';
import type { CargoData } from './types';

enum TAB {
  Catalog = 'catalog',
  Requests = 'active requests',
  Cart = 'cart',
  Help = 'help',
}

export function Cargo(props) {
  const { act, data } = useBackend<CargoData>();
  return (
    <Window width={800} height={750}>
      <Window.Content>
        <CargoContent act={act} data={data} />
      </Window.Content>
    </Window>
  );
}

type CargoContentProps = {
  act: any;
  data: CargoData;
};

export function CargoContent(props: CargoContentProps) {
  const { act, data } = props;
  const { cart = [], requests = [], requestonly } = data;
  const [tab, setTab] = useSharedState('cargotab', TAB.Catalog);

  let amount = 0;
  for (let i = 0; i < cart.length; i++) {
    amount += cart[i].amount;
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <CargoStatus act={act} {...data} />
      </Stack.Item>
      <Stack.Item>
        <Section
          title={toTitleCase(tab || '')}
          buttons={
            <>
              {tab === TAB.Requests && !requestonly && (
                <Button
                  icon="times"
                  color="transparent"
                  onClick={() => act('denyall')}
                >
                  Clear
                </Button>
              )}
              {(tab === TAB.Catalog || tab === TAB.Cart) && (
                <CargoCartButtons act={act} {...data} />
              )}
            </>
          }
        >
          <Tabs fluid m={-1}>
            <Tabs.Tab
              icon="list"
              selected={tab === TAB.Catalog}
              onClick={() => setTab(TAB.Catalog)}
            >
              Catalog
            </Tabs.Tab>
            <Tabs.Tab
              icon="envelope"
              textColor={
                tab !== TAB.Requests && requests.length > 0 && 'yellow'
              }
              selected={tab === TAB.Requests}
              onClick={() => setTab(TAB.Requests)}
            >
              Requests ({requests.length})
            </Tabs.Tab>
            {!requestonly && (
              <>
                <Tabs.Tab
                  icon="shopping-cart"
                  textColor={tab !== TAB.Cart && amount > 0 && 'yellow'}
                  selected={tab === TAB.Cart}
                  onClick={() => setTab(TAB.Cart)}
                >
                  Checkout ({amount})
                </Tabs.Tab>
                <Tabs.Tab
                  icon="question"
                  selected={tab === TAB.Help}
                  onClick={() => setTab(TAB.Help)}
                >
                  Help
                </Tabs.Tab>
              </>
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow mt={-1}>
        {tab === TAB.Catalog && <CargoCatalog act={act} data={data} />}
        {tab === TAB.Requests && <CargoRequests act={act} {...data} />}
        {tab === TAB.Cart && <CargoCart act={act} {...data} />}
        {tab === TAB.Help && <CargoHelp act={act} {...data} />}
      </Stack.Item>
    </Stack>
  );
}
