import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Flex,
  Stack,
  Section,
} from '../components';
import { Window } from '../layouts';

const ItemListEntry = (props) => {
  const {
    product: { name, payout, difficulty, path },
    disabled,
    onClick,
    buttonName,
  } = props;

  return (
    <>
      <Flex direction="row" align="center">
        <Flex.Item grow={1}>
          <Box bold>{name}</Box>
        </Flex.Item>
        <Flex.Item>
          {`Payout: ${payout}`} <i class="fa-solid fa-coins" />
        </Flex.Item>
        <Flex.Item>{`Difficulty: ${difficulty}`}</Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            {buttonName}
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

export const ChallengeSelector = (_props) => {
  const { act, data } = useBackend();
  const { challenges, selected_challenges } = data;

  return (
    <Window resizable title="Challenge Selector" width={450} height={700}>
      <Window.Content scrollable>
        <Section>
          <BlockQuote>Select your challenges from here</BlockQuote>
          <Stack vertical fill>
            <Stack.Item>
              {challenges.map((purchase) => {
                const { name, path } = purchase;
                return (
                  <ItemListEntry
                    key={name}
                    buttonName={
                      selected_challenges.includes(path) ? 'Remove' : 'Add'
                    }
                    product={purchase}
                    onClick={() => act('select_challenge', { path })}
                  />
                );
              })}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
