import {
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { BUYWORD2ICON } from './constants';
import {
  Buywords,
  type SpellbookData,
  SpellCategory,
  type SpellEntry,
} from './types';

type Props = {
  tabSpells: SpellEntry[];
  cooldownOffset?: number;
  pointOffset?: number;
};

function getTimeOrCat(entry: SpellEntry) {
  if (entry.cat === SpellCategory.Rituals) {
    if (entry.times) {
      return `Cast ${entry.times} times.`;
    } else {
      return 'Not cast yet.';
    }
  } else {
    if (entry.cooldown) {
      return `${entry.cooldown}s Cooldown`;
    } else {
      return '';
    }
  }
}

export function SpellTabDisplay(props: Props) {
  const { act, data } = useBackend<SpellbookData>();
  const { points } = data;
  const { tabSpells, cooldownOffset, pointOffset } = props;

  return (
    <Stack vertical>
      {tabSpells
        .sort((a, b) => {
          return a.name.toLowerCase() < b.name.toLowerCase() ? -1 : 1;
        })
        .map((entry) => (
          <Stack.Item key={entry.name}>
            <Divider />
            <Stack mt={1.3} width="100%" position="absolute" textAlign="left">
              <Stack.Item width="120px" ml={cooldownOffset}>
                {getTimeOrCat(entry)}
              </Stack.Item>
              <Stack.Item width="60px" ml={pointOffset}>
                {entry.cost} points
              </Stack.Item>
              {entry.buyword === Buywords.Learn && (
                <Stack.Item>
                  <Button
                    mt={-0.8}
                    icon="tshirt"
                    color={entry.requires_wizard_garb ? 'bad' : 'green'}
                    tooltipPosition="bottom-start"
                    tooltip={
                      entry.requires_wizard_garb
                        ? 'Requires wizard garb.'
                        : 'Can be cast without wizard garb.'
                    }
                  />
                </Stack.Item>
              )}
            </Stack>
            <Section title={entry.name}>
              <Stack>
                <Stack.Item grow>{entry.desc}</Stack.Item>
                <Stack.Item>
                  <Divider vertical />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    textAlign="center"
                    color={points >= entry.cost ? 'green' : 'bad'}
                    disabled={points < entry.cost}
                    width={7}
                    icon={BUYWORD2ICON[entry.buyword]}
                    onClick={() =>
                      act('purchase', {
                        spellref: entry.ref,
                      })
                    }
                  >
                    {entry.buyword}
                  </Button>
                  <br />
                  {!entry.refundable ? (
                    <NoticeBox>No refunds.</NoticeBox>
                  ) : (
                    <Button
                      textAlign="center"
                      width={7}
                      icon="arrow-left"
                      onClick={() =>
                        act('refund', {
                          spellref: entry.ref,
                        })
                      }
                    >
                      Refund
                    </Button>
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        ))}
    </Stack>
  );
}
