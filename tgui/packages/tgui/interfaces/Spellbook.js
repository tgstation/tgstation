import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, NoticeBox, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

const TAB2NAME = [
  {
    title: 'Enscribed Name',
    blurb:
      "This book answers only to its owner, and of course, must have one. The permanence of the pact between a spellbook and its owner ensures such a powerful artifact cannot fall into enemy hands, or be used in ways that break the Federation's rules such as bartering spells.",
    component: () => EnscribedName,
    noScrollable: 2,
  },
  {
    title: 'Table of Contents',
    blurb: null,
    component: () => TableOfContents,
  },
  {
    title: 'Offensive',
    blurb: 'Spells and items geared towards debilitating and destroying.',
  },
  {
    title: 'Defensive',
    blurb:
      "Spells and items geared towards improving your survivability or reducing foes' ability to attack.",
  },
  {
    title: 'Mobility',
    blurb:
      'Spells and items geared towards improving your ability to move. It is a good idea to take at least one.',
  },
  {
    title: 'Assistance',
    blurb:
      'Spells and items geared towards bringing in outside forces to aid you or improving upon your other items and abilities.',
  },
  {
    title: 'Challenges',
    blurb:
      'The Wizard Federation is looking for shows of power. Arming the station against you will increase the danger, but will grant you more charges for your spellbook.',
    locked: true,
    noScrollable: 1,
  },
  {
    title: 'Rituals',
    blurb:
      'These powerful spells change the very fabric of reality. Not always in your favour.',
  },
  {
    title: 'Loadouts',
    blurb:
      'The Wizard Federation accepts that sometimes, choosing is hard. You can choose from some approved wizard loadouts here.',
    component: () => Loadouts,
    noScrollable: 2,
  },
  {
    title: 'Randomize',
    blurb:
      "If you didn't like the loadouts offered, you can embrace chaos. Not recommended for newer wizards.",
    component: () => Randomize,
  },
];

const BUYWORD2ICON = {
  Learn: 'plus',
  Summon: 'hat-wizard',
  Cast: 'meteor',
};

const EnscribedName = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <>
      <Box
        mt={25}
        mb={-3}
        fontSize="50px"
        color="bad"
        textAlign="center"
        fontFamily="Ink Free">
        {owner}
      </Box>
      <Divider />
    </>
  );
};

const lineHeightToc = '34.6px';

const TableOfContents = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  return (
    <Box textAlign="center">
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="pen"
        disabled
        content="Name Enscription"
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="clipboard"
        disabled
        content="Table of Contents"
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="fire"
        content="Deadly Evocations"
        onClick={() => setTabIndex(3)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        content="Defensive Evocations"
        onClick={() => setTabIndex(3)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        content="Magical Transportation"
        onClick={() => setTabIndex(5)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="users"
        content="Assistance and Summoning"
        onClick={() => setTabIndex(5)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="crown"
        content="Challenges"
        onClick={() => setTabIndex(7)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="magic"
        content="Rituals"
        onClick={() => setTabIndex(7)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="thumbs-up"
        content="Wizard Approved Loadouts"
        onClick={() => setTabIndex(9)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="dice"
        content="Arcane Randomizer"
        onClick={() => setTabIndex(9)}
      />
    </Box>
  );
};

const LockedPage = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="lock" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          The Wizard Federation has locked this page.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const PointLocked = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="dollar-sign" size={10} />
          <div
            style={{
              background: 'purple',
              bottom: '60%',
              left: '33%',
              height: '10px',
              position: 'relative',
              transform: 'rotate(45deg)',
              width: '150px',
            }}
          />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          You do not have enough points to use this page.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const SingleLoadout = (props, context) => {
  const { act } = useBackend(context);
  const { author, name, blurb, icon, loadoutId, loadoutColor } = props;
  return (
    <Stack.Item grow>
      <Section width={LoadoutWidth} title={name}>
        {blurb}
        <Divider />
        <Button.Confirm
          confirmContent="Confirm Purchase?"
          confirmIcon="dollar-sign"
          confirmColor="good"
          fluid
          icon={icon}
          content="Purchase Loadout"
          onClick={() =>
            act('purchase_loadout', {
              id: loadoutId,
            })
          }
        />
        <Divider />
        <Box color={loadoutColor}>Added by {author}.</Box>
      </Section>
    </Stack.Item>
  );
};

const LoadoutWidth = 19.17;

const Loadouts = (props, context) => {
  const { act, data } = useBackend(context);
  const { points } = data;
  return (
    <Stack ml={0.5} mt={-0.5} vertical fill>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            loadoutId="loadout_classic"
            loadoutColor="purple"
            name="The Classic Wizard"
            icon="fire"
            author="Archchancellor Gray"
            blurb={multiline`
                This is the classic wizard, crazy popular in
                the 2550's. Comes with Fireball, Magic Missile,
                Ei Nath, and Ethereal Jaunt. The key here is that
                every part of this kit is very easy to pick up and use.
              `}
          />
          <SingleLoadout
            name="Mjolnir's Power"
            icon="hammer"
            loadoutId="loadout_hammer"
            loadoutColor="green"
            author="Jegudiel Worldshaker"
            blurb={multiline`
                The power of the mighty Mjolnir! Best not to lose it.
                This loadout has Summon Item, Mutate, Blink, Force Wall,
                Tesla Blast, and Mjolnir. Mutate is your utility in this case:
                Use it for limited ranged fire and getting out of bad blinks.
              `}
          />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            name="Fantastical Army"
            icon="pastafarianism"
            loadoutId="loadout_army"
            loadoutColor="yellow"
            author="Prospero Spellstone"
            blurb={multiline`
                Why kill when others will gladly do it for you?
                Embrace chaos with your kit: Soulshards, Staff of Change,
                Necro Stone, Teleport, and Jaunt! Remember, no offense spells!
              `}
          />
          <SingleLoadout
            name="Soul Tapper"
            icon="skull"
            loadoutId="loadout_tap"
            loadoutColor="white"
            author="Tom the Empty"
            blurb={multiline`
                Embrace the dark, and tap into your soul.
                You can recharge very long recharge spells
                like Ei Nath by jumping into new bodies with
                Mind Swap and starting Soul Tap anew.
              `}
          />
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const lineHeightRandomize = 6;

const Randomize = (props, context) => {
  const { act, data } = useBackend(context);
  const { points, semi_random_bonus, full_random_bonus } = data;
  return (
    <Stack fill vertical>
      {points < 10 && <PointLocked />}
      <Stack.Item grow mt={10}>
        Semi-Randomize will ensure you at least get some mobility and lethality.
        Guaranteed to have {semi_random_bonus} points worth of spells.
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          confirmContent="Cowabunga it is?"
          confirmIcon="dice-three"
          lineHeight={lineHeightRandomize}
          fluid
          icon="dice-three"
          content="Semi-Randomize!"
          onClick={() => act('semirandomize')}
        />
        <Divider />
      </Stack.Item>
      <Stack.Item>
        Full Random will give you anything. There&apos;s no going back, either!
        Guaranteed to have {full_random_bonus} points worth of spells.
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger>
          <Button.Confirm
            confirmContent="Cowabunga it is?"
            confirmIcon="dice"
            lineHeight={lineHeightRandomize}
            fluid
            color="black"
            icon="dice"
            content="Full Random!"
            onClick={() => act('randomize')}
          />
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const widthSection = '466px';
const heightSection = '456px';

export const Spellbook = (props, context) => {
  const { act, data } = useBackend(context);
  const { entries, points } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  const ScrollableCheck = TAB2NAME[tabIndex - 1].noScrollable ? false : true;
  const ScrollableNextCheck = TAB2NAME[tabIndex - 1].noScrollable !== 2;
  const TabComponent = TAB2NAME[tabIndex - 1].component
    ? TAB2NAME[tabIndex - 1].component()
    : null;
  const TabNextComponent = TAB2NAME[tabIndex].component
    ? TAB2NAME[tabIndex].component()
    : null;
  const TabSpells = entries
    ? entries.filter((entry) => entry.cat === TAB2NAME[tabIndex - 1].title)
    : null;
  const TabNextSpells = entries
    ? entries.filter((entry) => entry.cat === TAB2NAME[tabIndex].title)
    : null;
  return (
    <Window title="Spellbook" theme="wizard" width={950} height={540}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <Section
                  scrollable={ScrollableCheck}
                  textAlign="center"
                  width={widthSection}
                  height={heightSection}
                  fill
                  title={TAB2NAME[tabIndex - 1].title}
                  buttons={
                    <>
                      <Button
                        mr={57}
                        disabled={tabIndex === 1}
                        icon="arrow-left"
                        content="Previous Page"
                        onClick={() => setTabIndex(tabIndex - 2)}
                      />
                      <Box textAlign="right" bold mt={-3.3} mr={1}>
                        {tabIndex}
                      </Box>
                    </>
                  }>
                  {!!TAB2NAME[tabIndex - 1].locked && <LockedPage />}
                  <Stack vertical>
                    {TAB2NAME[tabIndex - 1].blurb !== null && (
                      <Stack.Item>
                        <Box textAlign="center" bold height="30px">
                          {TAB2NAME[tabIndex - 1].blurb}
                        </Box>
                      </Stack.Item>
                    )}
                    {(!!TAB2NAME[tabIndex - 1].component && (
                      <Stack.Item>
                        <TabComponent />
                      </Stack.Item>
                    )) || (
                      <Stack.Item>
                        <Stack vertical>
                          {TabSpells?.map((entry) => (
                            <Stack.Item key={entry}>
                              <Divider />
                              <Section
                                title={entry.name}
                                buttons={
                                  <>
                                    <Box
                                      mr={entry.buyword === 'Learn' ? 6.5 : 2}>
                                      {entry.cost} Points
                                    </Box>
                                    {(entry.cat === 'Rituals' &&
                                      ((!!entry.times && (
                                        <Box ml={-104} mt={-2.2}>
                                          Cast {entry.times} Times.
                                        </Box>
                                      )) || (
                                        <Box ml={-110} mt={-2.2}>
                                          Not Casted Yet.
                                        </Box>
                                      ))) ||
                                      (entry.cooldown && (
                                        <Box ml={-115} mt={-2.2}>
                                          {entry.cooldown}s Cooldown
                                        </Box>
                                      )) || (
                                        <Box ml={-120} mt={-2.2}>
                                          No Cooldown!
                                        </Box>
                                      )}
                                    {entry.buyword === 'Learn' && (
                                      <Box mr={-9.5} mt={-3}>
                                        <Button
                                          icon="tshirt"
                                          color={
                                            entry.requires_wizard_garb
                                              ? 'bad'
                                              : 'green'
                                          }
                                          tooltipPosition="bottom-start"
                                          tooltip={
                                            entry.requires_wizard_garb
                                              ? 'Requires wizard garb.'
                                              : 'Can be cast without wizard garb.'
                                          }
                                        />
                                      </Box>
                                    )}
                                  </>
                                }>
                                <Stack>
                                  <Stack.Item grow>{entry.desc}</Stack.Item>
                                  <Stack.Item>
                                    <Divider vertical />
                                  </Stack.Item>
                                  <Stack.Item>
                                    <Button
                                      fluid
                                      textAlign="center"
                                      color={
                                        points >= entry.cost ? 'green' : 'bad'
                                      }
                                      disabled={points < entry.cost}
                                      width={7}
                                      icon={BUYWORD2ICON[entry.buyword]}
                                      content={entry.buyword}
                                      onClick={() =>
                                        act('purchase', {
                                          spellref: entry.ref,
                                        })
                                      }
                                    />
                                    <br />
                                    {(!entry.refundable && (
                                      <NoticeBox>No refunds.</NoticeBox>
                                    )) || (
                                      <Button
                                        textAlign="center"
                                        width={7}
                                        icon="arrow-left"
                                        content="Refund"
                                        onClick={() =>
                                          act('refund', {
                                            spellref: entry.ref,
                                          })
                                        }
                                      />
                                    )}
                                  </Stack.Item>
                                </Stack>
                              </Section>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  scrollable={ScrollableNextCheck}
                  textAlign="center"
                  width={widthSection}
                  height={heightSection}
                  fill
                  title={TAB2NAME[tabIndex].title}
                  buttons={
                    <>
                      <Button
                        mr={0}
                        icon="arrow-right"
                        disabled={tabIndex === 9}
                        content="Next Page"
                        onClick={() => setTabIndex(tabIndex + 2)}
                      />
                      <Box textAlign="left" bold mt={-3.3} ml={-59.8}>
                        {tabIndex + 1}
                      </Box>
                    </>
                  }>
                  {!!TAB2NAME[tabIndex].locked && <LockedPage />}
                  <Stack vertical>
                    {TAB2NAME[tabIndex].blurb !== null && (
                      <Stack.Item>
                        <Box textAlign="center" bold height="30px">
                          {TAB2NAME[tabIndex].blurb}
                        </Box>
                      </Stack.Item>
                    )}
                    {(!!TAB2NAME[tabIndex].component && (
                      <Stack.Item>
                        <TabNextComponent />
                      </Stack.Item>
                    )) || (
                      <Stack.Item>
                        <Stack vertical>
                          {TabNextSpells?.map((entry) => (
                            <Stack.Item key={entry}>
                              <Divider />
                              <Section
                                title={entry.name}
                                buttons={
                                  <>
                                    <Box
                                      mr={entry.buyword === 'Learn' ? 6.5 : 2}>
                                      {entry.cost} Points
                                    </Box>
                                    {(entry.cat === 'Rituals' &&
                                      ((!!entry.times && (
                                        <Box ml={-118} mt={-2.2}>
                                          Cast {entry.times} Time(s).
                                        </Box>
                                      )) || (
                                        <Box ml={-118} mt={-2.2}>
                                          Not Casted Yet.
                                        </Box>
                                      ))) ||
                                      (entry.cooldown && (
                                        <Box ml={-115} mt={-2.2}>
                                          {entry.cooldown}s Cooldown
                                        </Box>
                                      )) || (
                                        <Box ml={-120} mt={-2.2}>
                                          No Cooldown!
                                        </Box>
                                      )}
                                    {entry.buyword === 'Learn' && (
                                      <Box mr={-9.5} mt={-3}>
                                        <Button
                                          icon="tshirt"
                                          color={
                                            entry.requires_wizard_garb
                                              ? 'bad'
                                              : 'green'
                                          }
                                          tooltipPosition="bottom-start"
                                          tooltip={
                                            entry.requires_wizard_garb
                                              ? 'Requires wizard garb.'
                                              : 'Can be cast without wizard garb.'
                                          }
                                        />
                                      </Box>
                                    )}
                                  </>
                                }>
                                <Stack>
                                  <Stack.Item grow>{entry.desc}</Stack.Item>
                                  <Stack.Item>
                                    <Divider vertical />
                                  </Stack.Item>
                                  <Stack.Item>
                                    <Button
                                      fluid
                                      textAlign="center"
                                      color={
                                        points >= entry.cost ? 'green' : 'bad'
                                      }
                                      disabled={points < entry.cost}
                                      width={7}
                                      icon={BUYWORD2ICON[entry.buyword]}
                                      content={entry.buyword}
                                      onClick={() =>
                                        act('purchase', {
                                          spellref: entry.ref,
                                        })
                                      }
                                    />
                                    <br />
                                    {(!entry.refundable && (
                                      <NoticeBox>No refunds.</NoticeBox>
                                    )) || (
                                      <Button
                                        textAlign="center"
                                        width={7}
                                        icon="arrow-left"
                                        content="Refund"
                                        onClick={() =>
                                          act('refund', {
                                            spellref: entry.ref,
                                          })
                                        }
                                      />
                                    )}
                                  </Stack.Item>
                                </Stack>
                              </Section>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <ProgressBar value={points / 10}>
                {points + ' points left to spend.'}
              </ProgressBar>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
