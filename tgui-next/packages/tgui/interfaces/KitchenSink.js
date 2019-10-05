import { Fragment } from 'inferno';
import { Section, Tabs } from '../components';

export const KitchenSink = props => {
  const { state, dispatch } = props;
  const { config, data } = state;
  const { ref } = config;
  const tabKeys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(x => 'tab_' + x);
  return (
    <Fragment>
      <Section title="Testing">
        <Tabs vertical>
          {tabKeys.map(key => (
            <Tabs.Tab
              key={key}
              label={'Label ' + key}>
              {key => (
                <Fragment>
                  Tab content ({key})
                </Fragment>
              )}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Section>
    </Fragment>
  );
};
