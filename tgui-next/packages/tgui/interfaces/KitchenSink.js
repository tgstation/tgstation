import { Fragment, Component } from 'inferno';
import { Section, Tabs, Box, Button, Flex, ProgressBar, Tooltip } from '../components';

const COLORS_ARBITRARY = [
  'black',
  'black-gray',
  'dark-gray',
  'gray',
  'light-gray',
  'white',
  'dark-red',
  'red',
  'pale-red',
  'yellow-orange',
  'yellow',
  'grass-green',
  'dark-green',
  'green',
  'pale-green',
  'royal-blue',
  'pale-blue',
];

const COLORS_STATES = [
  'good',
  'average',
  'bad',
];

export class KitchenSink extends Component {
  constructor() {
    super();
    this.state = {
      vertical: true,
      progress: 0.5,
    };
  }

  render() {
    const { state, props } = this;
    const { vertical, progress } = state;
    const tabKeys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      .map(x => 'tab_' + x);
    return (
      <Fragment>
        <Flex mb={1}>
          <Flex.Item mr={1} grow={1}>
            <Section
              title="Buttons"
              height="100%">
              <Box mb={1}>
                <Button content="Simple" />
                <Button selected content="Selected" />
                <Button disabled content="Disabled" />
                <Button color="transparent" content="Transparent" />
                <Button icon="cog" content="Icon" />
                <Button icon="power-off" />
                <Button fluid content="Fluid" />
                <Button
                  my={1}
                  lineHeight={4}
                  minWidth={30}
                  textAlign="center"
                  content="With Box props" />
              </Box>
              <Box mb={1}>
                {COLORS_STATES.map(color => (
                  <Button color={color} content={color} />
                ))}
                {COLORS_ARBITRARY.map(color => (
                  <Button color={color} content={color} />
                ))}
              </Box>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section
              title="Box"
              width={25}
              height="100%">
              <Box bold content="bold" />
              <Box italic content="italic" />
              <Box opacity={0.5} content="opacity 0.5" />
              <Box opacity={0.25} content="opacity 0.25" />
              <Box m={2} content="m: 2" />
              <Box textAlign="left" content="left" />
              <Box textAlign="center" content="center" />
              <Box textAlign="right" content="right" />
            </Section>
          </Flex.Item>
        </Flex>
        <Section title="Progress">
          <ProgressBar value={progress} />
          <Button
            content="-0.1"
            onClick={() => this.setState(prevState => ({
              progress: prevState.progress - 0.1,
            }))} />
          <Button
            content="+0.1"
            onClick={() => this.setState(prevState => ({
              progress: prevState.progress + 0.1,
            }))} />
        </Section>
        <Section title="Tabs">
          Vertical:
          {' '}
          <Button inline
            content={String(vertical)}
            onClick={() => this.setState(prevState => ({
              vertical: !prevState.vertical,
            }))} />
          <Box mb={2} />
          <Tabs vertical={vertical}>
            {tabKeys.map(key => (
              <Tabs.Tab
                key={key}
                label={'Label ' + key}>
                {() => (
                  <Box>
                    <h1>Eat some more of these soft French rolls and
                      drink some tea.</h1>
                    <Box my={2}>
                      Active tab: <Box inline color="green">{key}</Box>
                    </Box>
                    <Box my={1}>
                      <em>Jackdaws loves my big sphinx of quartz.</em>
                    </Box>
                    <Box my={1}>
                      <strong>The wide electrification of the southern
                        provinces will give a powerful impetus to the
                        growth of soviet agriculture.</strong>
                    </Box>
                    <Box inline mt={3} position="relative">
                      Tooltip example.
                      <Tooltip
                        content="Tooltip text."
                        position="right" />
                    </Box>
                  </Box>
                )}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Fragment>
    );
  }
}
