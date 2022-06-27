import { Component } from 'inferno';
import { Window } from '../layouts';
import { Section, Stack, Tabs } from '../components';
import { logger } from '../logging';

type Data = {
  active: boolean;
};

type Observable = {
  ref: string;
  name: string;
};

type StaticData = {
  alive: Observable[];
  antagonists: Observable[];
  dead: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
};

enum TAB {
  Alive,
  Dead,
  Misc,
}

type State = {
  autoObserve: boolean;
  currentTab: number;
};

export class Orbit extends Component<{}, State> {
  protected data: Data;
  protected static_data: StaticData;
  public setState: (newState) => void;
  public state: State = {
    autoObserve: false,
    currentTab: 0,
  };

  constructor(props, context) {
    super();
    this.context = context;
  }

  setTab(tab: TAB) {
    this.setState({ currentTab: tab });
  }

  componentDidMount() {
    logger.log('Orbit');
  }
  compenentDidUpdate() {}

  render() {
    return (
      <Window title="Orbit" width={350} height={700}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <Tabs fluid>
                <Tabs.Tab onClick={this.setTab(TAB.Alive)}>Alive</Tabs.Tab>
                <Tabs.Tab onClick={this.setTab(TAB.Dead)}>Dead</Tabs.Tab>
                <Tabs.Tab onClick={this.setTab(TAB.Misc)}>Misc</Tabs.Tab>
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Section title="Observables">
                <ObservableDisplay list={this.state.currentTab} />
                {this.state.autoObserve}
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

const ObservableDisplay = (props, context) => {
  const { list } = props;
  const { data } = context;

  return (
    <>Hello</>
    // <Stack fill vertical>
    //   {data.static_data[list].map((observable, index) => {
    //     return <Stack.Item key={index} />;
    //   })}
    // </Stack>
  );
};
