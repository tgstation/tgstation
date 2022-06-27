import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const ColorBlindTester = (props, context) => {
  const { act, data } = useBackend(context);
  const { details } = data;
  return (
    <Window title="Color Blindness Testing" width={600} height={515}>
      <Window.Content>
        <NoticeBox warning>
          <Box>
            HEY FUCKOS, these filters are based off VERY OLD and VERY FLAWED
            matrixes.
          </Box>
          <Box>
            There is NO GOOD WAY to do proper color blind simulation in BYOND,
            because we have no way to extract the gamma of a pixel without
            iterating all pixels on the screen, which we need to do to properly
            correct for the human eye.
          </Box>
          <Box>
            Because of this, this simulation is very imperfect. You will notice
            things are much more bright then they should be. This is a direct
            result of not being able to correct for gamma.
          </Box>
          <Box>
            This tool exists so we have at least some form of baseline for
            accessability, it is nowhere near gospel.
          </Box>
          <Box>
            If I find you being a dick to someone over this I will clobber you
            with a crowbar
          </Box>
        </NoticeBox>
        <Section>
          {Object.keys(details).map((category) => (
            <ColorBlindCategory category={category} key={category} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const ColorBlindCategory = (props, context) => {
  const { act, data } = useBackend(context);
  const { category } = props;
  const { details, selected } = data;
  if (category !== selected) {
    return (
      <Section
        key={category}
        title={category}
        buttons={
          <Button
            icon="eye"
            content="Select"
            onClick={() =>
              act('set_matrix', {
                name: category,
              })
            }
          />
        }>
        {details[category]}
      </Section>
    );
  }
  return (
    <Section
      key={category}
      title={category}
      buttons={
        <Button
          icon="times"
          content="Clear"
          color="bad"
          onClick={() => act('clear_matrix')}
        />
      }>
      {details[category]}
    </Section>
  );
};
