import { Fragment, Component } from 'inferno';
import { Section, Tabs, Box, Button } from '../components';

export class KitchenSink extends Component {
  constructor() {
    super();
    this.state = {
      vertical: true,
    };
  }

  render() {
    const { state, props } = this;
    const { vertical } = state;
    const tabKeys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      .map(x => 'tab_' + x);
    return (
      <Fragment>
        <Section title="Testing">
          <Button
            content={vertical ? 'Vertical' : 'Horizontal'}
            onClick={() => this.setState(prevState => ({
              vertical: !prevState.vertical,
            }))} />
          <Box mb={2} />
          <Tabs vertical={vertical}>
            {tabKeys.map(key => (
              <Tabs.Tab
                key={key}
                label={'Label ' + key}>
                {key => (
                  <Fragment>
                    <h1>Eat some more of these soft French rolls and
                      drink some tea.</h1>
                    <Box color="green" my={2}>
                      Tab content key: {key}
                    </Box>
                    <Box my={1}>
                      <em>Jackdaws loves my big sphinx of quartz.</em>
                    </Box>
                    <Box my={1}>
                      <strong>The wide electrification of the southern
                        provinces will give a powerful impetus to the
                        growth of soviet agriculture.</strong>
                    </Box>
                  </Fragment>
                )}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Fragment>
    );
  }
}
