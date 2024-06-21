import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Box, Button, Flex } from '../components';

export const CassetteReview = (props) => {
  const { act, data } = useBackend();
  const { ckey, submitters_name, side1, side2 } = data;
  return (
    <Window width={600} height={313}>
      <Window.Content>
        <Flex>
          <Flex.Item>
            <Section key="urls">
              {side1.song_url.map((song) => (
                <Box key={song}>
                  <a href={song}>{song}</a>
                </Box>
              ))}
              {side2.song_url.map((song) => (
                <Box key={song}>
                  <a href={song}>{song}</a>
                </Box>
              ))}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section key="names">
              {side1.song_name.map((song) => (
                <Box key={song}>{song}</Box>
              ))}
              {side2.song_name.map((song) => (
                <Box key={song}>{song}</Box>
              ))}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Button onClick={() => act('approve')}>Approve</Button>
            <Button onClick={() => act('deny')}>Deny</Button>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
