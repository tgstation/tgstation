import { map } from 'common/fp';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, Section, Tabs } from '../components';

export const RPD = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const categories = data.categories || [];
  const paint_colors = data.paint_colors || [];
  return (
    <Fragment>
      <Tabs>
        <Tabs.Tab
          key=""
          label="Atmospherics"
          icon="list"
          lineHeight="28px">
          {() => (
            <Section
              title="Atmospherics"
              >
            </Section>
          )}
        </Tabs.Tab>
        <Tabs.Tab
          key=""
          label="Disposals"
          icon="list"
          lineHeight="28px">
          {() => (
            <Section
              title="Disposals"
              >
            </Section>
          )}
        </Tabs.Tab>
        <Tabs.Tab
          key=""
          label="Transit Tubes"
          icon="list"
          lineHeight="28px">
          {() => (
            <Section
              title="Transit Tubes"
              >
            </Section>
          )}
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  );
};
