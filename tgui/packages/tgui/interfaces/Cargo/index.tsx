import { useBackend, useSharedState } from '../../backend';
import { Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CargoCart } from './CargoCart';
import { CargoCatalog } from './CargoCatalog';
import { CargoHelp } from './CargoHelp';
import { CargoRequests } from './CargoRequests';
import { CargoStatus } from './CargoStatus';
import { CargoData } from './types';

enum TAB {
  Catalog = 'catalog',
  Requests = 'requests',
  Cart = 'cart',
  Help = 'help',
}

export function Cargo(props) {
  return (
    <Window width={800} height={750}>
      <Window.Content>
        <CargoContent />
      </Window.Content>
    </Window>
  );
}

export function CargoContent(props) {
  const { data } = useBackend<CargoData>();

  const { cart = [], requests = [], requestonly } = data;

  const [tab, setTab] = useSharedState('cargotab', TAB.Catalog);

  let amount = 0;
  for (let i = 0; i < cart.length; i++) {
    amount += cart[i].amount;
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <CargoStatus />
      </Stack.Item>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            icon="list"
            selected={tab === TAB.Catalog}
            onClick={() => setTab(TAB.Catalog)}
          >
            Catalog
          </Tabs.Tab>
          <Tabs.Tab
            icon="envelope"
            textColor={tab !== TAB.Requests && requests.length > 0 && 'yellow'}
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
      </Stack.Item>
      <Stack.Item grow mt={0}>
        {tab === TAB.Catalog && <CargoCatalog />}
        {tab === TAB.Requests && <CargoRequests />}
        {tab === TAB.Cart && <CargoCart />}
        {tab === TAB.Help && <CargoHelp />}
      </Stack.Item>
    </Stack>
  );
}
