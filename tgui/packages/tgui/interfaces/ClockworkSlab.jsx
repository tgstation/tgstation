import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Icon,
  Box,
  Button,
  Section,
  Table,
  Divider,
  Grid,
  ProgressBar,
  Collapsible,
} from '../components';
import { Window } from '../layouts';
import { TableRow } from '../components/Table';

const brassColor = '#DFC69C';
const tinkerCache = '#B5FD9D';
const replicaFab = '#DED09F';
const clockMarauder = '#FF9D9D';

const convertPower = (power_in) => {
  const units = ['W', 'kW', 'MW', 'GW'];
  let power = 0;
  let value = power_in;
  while (value >= 1000 && power < units.length) {
    power++;
    value /= 1000;
  }
  return Math.round((value + Number.EPSILON) * 100) / 100 + units[power];
};

export const ClockworkSlab = (props) => {
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    'Servitude',
  );
  return (
    <Window theme="clockwork" width={860} height={700}>
      <Window.Content>
        <Section
          title={
            <Box inline color={'good'}>
              <Icon name={'cog'} rotation={0} spin={1} />
              {' Clockwork Slab '}
              <Icon name={'cog'} rotation={35} spin={1} />
            </Box>
          }
        >
          <ClockworkButtonSelection />
        </Section>
        <div className="ClockSlab__left">
          <Section height="100%" overflowY="auto">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Section>
        </div>
        <div className="ClockSlab__right">
          <div className="ClockSlab__stats">
            <Section height="100%">
              <ClockworkOverview />
            </Section>
          </div>
          <div className="ClockSlab__current">
            <Section
              height="100%"
              overflowY="auto"
              title="Servants of the Cog vol.1"
            >
              <ClockworkHelp />
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const ClockworkHelp = (props) => {
  return (
    <Fragment>
      <Collapsible title="Where To Start" color="average" open={1}>
        <Section>
          After a long and destructive war, Rat&#39;Var has been imprisoned
          inside a dimension of suffering.
          <br />
          You are one of his last remaining, most loyal servants. <br />
          You are very weak and have little power, with most of your scriptures
          unable to function.
          <br />
          <b>
            Install&nbsp;
            <font color={brassColor}>Integration Cogs&nbsp;</font>
            to unlock more scriptures and siphon power!
          </b>
          <br />
          Hover over the button for a scripture to get additonal information for
          it.
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Unlocking Scriptures" color="average">
        <Section>
          Most scriptures require <b>cogs</b> to unlock.
          <br />
          Invoke&nbsp;
          <font color={brassColor}>
            <b>Integration Cog&nbsp;</b>
          </font>
          to summon an Integration Cog, which can be placed into any&nbsp;
          <b>APC&nbsp;</b>
          on the station.
          <br />
          Open the cover of, or slice open the&nbsp;
          <b>APC&nbsp;</b>
          with the&nbsp;
          <b>Integration Cog&nbsp;</b>
          and then insert it in to begin siphoning power.
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Defense" color="average">
        <Section>
          <b>
            You have a wide range of structures and powers that will be vital in
            defending your grounds.
          </b>
          <br />
          <b>
            <font color={brassColor}>Structures:&nbsp;</font>
          </b>
          A variety of invaluable structures are available to you, allowing
          effective defense of Reebe. Use your Slab on a structure to gain extra
          information.
          <br />
          <b>
            <font color={brassColor}>Traps:&nbsp;</font>
          </b>
          Traps are useful contraptions, able to be created at a{' '}
          <font color={tinkerCache}>Tinkerer&#39;s Cache</font>. Use your Slab
          to link traps and triggers together.
          <br />
          <b>
            <font color={replicaFab}>Replica Fabricator:&nbsp;</font>
          </b>
          The Replica Fabricator is one of the strongest tools available to you,
          via the <font color={tinkerCache}>Tinkerer&#39;s Cache</font>. It
          allows the conversion of all materials into power, which can be used
          to create floors, walls, and airlocks. The airlocks will shock all
          non-servants.
          <br />
          <b>
            <font color={clockMarauder}>Clockwork Marauder:&nbsp;</font>
          </b>
          A powerful shell that can deflect attacks and delivers a strong blow
          in close quarter combat.
          <br />
          <b>
            <font color={clockMarauder}>Cogscarab:&nbsp;</font>
          </b>
          A small construct able to construct defenses on Reebe.
          <br />
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Tips" color="average">
        <Section>
          <b>
            <font color={brassColor}>Vitality:&nbsp;</font>
          </b>
          You need vitality to create{' '}
          <font color={clockMarauder}>Clockwork Marauders and Cogscarabs</font>,
          which is gotten from sacrificing living beings to a{' '}
          <font color={brassColor}>Vitality Sigil</font>.
          <br />
          <b>
            <font color={brassColor}>Power:&nbsp;</font>
          </b>
          Watch your power upkeep! You&#39;re dependent on your cogged APCs to
          stay powered, and a lot of structures can drain it quickly.
          <br />
          <b>
            <font color={brassColor}>Your Base:&nbsp;</font>
          </b>
          Defending The Ark is your highest priority! You&#39;re significantly
          stronger while on brass tiles, so make sure to protect your home.
          <br />
          <b>
            <font color={brassColor}>Nar&#39;sie:&nbsp;</font>
          </b>
          Nar&#39;sian cultists are your greatest foe! Some of your spells are
          less effective on them, and vice-versa.
          <br />
          <b>
            <font color={brassColor}>Linking structures:&nbsp;</font>
          </b>
          Your powered structures can also be linked to triggers to toggle them.
          But dont forget, they use power while active.
          <br />
          <br />
        </Section>
      </Collapsible>
    </Fragment>
  );
};

const ClockworkSpellList = (props) => {
  const { act, data } = useBackend();
  const { selectedTab } = props;
  const { scriptures = [] } = data;
  return (
    <Table>
      {scriptures.map((script) =>
        script.type === selectedTab ? (
          <Fragment key={script}>
            <TableRow>
              <Table.Cell bold>{script.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  color={script.purchased ? 'default' : 'average'}
                  content={
                    script.purchased
                      ? 'Invoke ' + convertPower(script.cost)
                      : script.cog_cost + ' Cogs'
                  }
                  tooltip={script.tip}
                  disabled={false}
                  onClick={() =>
                    act('invoke', {
                      scriptureType: script.typepath,
                    })
                  }
                />
              </Table.Cell>
            </TableRow>
            <TableRow>
              <Table.Cell>{script.desc}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  content={'Quickbind'}
                  disabled={!script.purchased}
                  onClick={() =>
                    act('quickbind', {
                      scriptureType: script.typepath,
                    })
                  }
                />
              </Table.Cell>
            </TableRow>
            <Table.Cell>
              <Divider />
            </Table.Cell>
          </Fragment>
        ) : (
          <Box key={script} />
        ),
      )}
    </Table>
  );
};

const ClockworkOverview = (props) => {
  const { data } = useBackend();
  const { power, cogs, vitality, max_power, max_vitality } = data;
  return (
    <Box>
      <Box color="good" bold fontSize="16px">
        {'Celestial Gateway Report'}
      </Box>
      <Divider />
      <ClockworkOverviewStat
        title="Cogs"
        amount={cogs}
        maxAmount={10}
        iconName="cog"
        unit=""
      />
      <ClockworkOverviewStat
        title="Power"
        amount={power}
        maxAmount={max_power}
        iconName="battery-half "
        overrideText={convertPower(power)}
      />
      <ClockworkOverviewStat
        title="Vitality"
        amount={vitality}
        maxAmount={max_vitality}
        iconName="tint"
        unit="u"
      />
    </Box>
  );
};

const ClockworkOverviewStat = (props) => {
  const { title, iconName, amount, maxAmount, unit, overrideText } = props;
  return (
    <Box height="22px" fontSize="16px">
      <Grid>
        <Grid.Column>
          <Icon name={iconName} rotation={0} spin={0} />
        </Grid.Column>
        <Grid.Column size="2">{title}</Grid.Column>
        <Grid.Column size="8">
          <ProgressBar
            value={amount}
            minValue={0}
            maxValue={maxAmount}
            ranges={{
              good: [maxAmount / 2, Infinity],
              average: [maxAmount / 4, maxAmount / 2],
              bad: [-Infinity, maxAmount / 4],
            }}
          >
            {overrideText ? overrideText : amount + ' ' + unit}
          </ProgressBar>
        </Grid.Column>
      </Grid>
    </Box>
  );
};

const ClockworkButtonSelection = (props) => {
  const [selectedTab, setSelectedTab] = useLocalState('selectedTab', {});
  const tabs = ['Servitude', 'Preservation', 'Structures'];
  return (
    <Table>
      <Table.Row>
        {tabs.map((tab) => (
          <Table.Cell key={tab} collapsing>
            <Button
              key={tab}
              fluid
              content={tab}
              onClick={() => setSelectedTab(tab)}
            />
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};
