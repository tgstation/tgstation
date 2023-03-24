import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Icon, Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Divider, Grid, ProgressBar, Collapsible } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { TableRow } from '../components/Table';
import { GridColumn } from '../components/Grid';

export const convertPower = power_in => {
  const units = ["W", "kW", "MW", "GW"];
  let power = 0;
  let value = power_in;
  while (value >= 1000 && power < units.length)
  {
    power ++;
    value /= 1000;
  }
  return ((Math.round((value + Number.EPSILON) * 100)/100) + units[power]);
};

export const ClockworkSlab = (props, context) => {
  const { data } = useBackend(context);
  const { power } = data;
  const { recollection } = data;
  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', "Servitude");
  return (
    <Window
      theme="clockwork"
      resizable
      width={860}
      height={700}>
      <Window.Content>
        <Section
          title={(
            <Box
              inline
              color={'good'}>
              <Icon name={"cog"} rotation={0} spin={1} />
              {" Clockwork Slab "}
              <Icon name={"cog"} rotation={35} spin={1} />
            </Box>
          )}>
          <ClockworkButtonSelection />
        </Section>
        <div className="ClockSlab__left">
          <Section
            height="100%"
            overflowY="scroll">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Section>
        </div>
        <div className="ClockSlab__right">
          <div className="ClockSlab__stats">
            <Section
              height="100%"
              scrollable
              overflowY="scroll">
              <ClockworkOverview />
            </Section>
          </div>
          <div className="ClockSlab__current">
            <Section
              height="100%"
              scrollable
              overflowY="scroll"
              title="Servants of the Cog vol.1">
              <ClockworkHelp />
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

export const ClockworkHelp = (props, context) => {
  return (
    <Fragment>
      <Collapsible title="Where To Start" color="average" open={1}>
        <Section>
          After a long and destructive
          war, Rat&#39;Var has been imprisoned
          inside a dimension of suffering.
          <br />
          You are a group of his last remaining,
          most loyal servants. <br />
          You are very weak and have little power,
          with most of your scriptures unable to
          function.
          <br />
          <b>
            Use the&nbsp;
            <font color="#BD78C4">
              Ratvarian Observation Consoles&nbsp;
            </font>
            to warp to the station!
          </b>
          <br />
          <b>
            Install&nbsp;
            <font color="#DFC69C">
              Integration Cogs&nbsp;
            </font>
            to unlock more scriptures and siphon power!
          </b>
          <br />
          <b>
            Unlock&nbsp;
            <font color="#D8D98D">
              Kindle&nbsp;
            </font>
            ,&nbsp;
            <font color="#F19096">
              Hateful Manacles&nbsp;
            </font>
            and summon a&nbsp;
            <font color="#9EA7E5">
              Sigil of Submission&nbsp;
            </font>
            to convert any non-believers!
          </b>
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Unlocking Scriptures" color="average">
        <Section>
          Most scriptures require <b>cogs</b> to unlock.
          <br />
          Invoke&nbsp;
          <font color="#DFC69C">
            <b>
              Integration Cog&nbsp;
            </b>
          </font>
          to summon an Integration Cog,
          which can be placed into any&nbsp;
          <b>
            APC&nbsp;
          </b>
          on the station.
          <br />
          Slice open the&nbsp;
          <b>
            APC&nbsp;
          </b>
          with the&nbsp;
          <b>
            Integration Cog&nbsp;
          </b>
          , then insert it in to
          begin siphoning power.
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Conversion" color="average">
        <Section>
          Invoke
          <b>
            <font color="#D8D98D">
              Kindle&nbsp;
            </font>
          </b>
          (After you unlock it), to&nbsp;
          <b>
            stun&nbsp;
          </b>
          and&nbsp;
          <b>
            mute&nbsp;
          </b>
          any target long enough for you to restrain
          <br />
          Using&nbsp;
          <b>
            zipties&nbsp;
          </b> obtained from the station, or
          by invoking&nbsp;
          <b>
            <font color="#F19096">
              Hateful Manacles&nbsp;
            </font>
          </b>
          , you can restrain targets
          to keep them from escaping the light.
          <br />
          Invoke&nbsp;
          <b>
            <font color="#D5B8DC">
              Abscond&nbsp;
            </font>
          </b>
          to warp back to Reebe, where the being you are
          dragging will be pulled with you.
          <br />
          From there, summon a&nbsp;
          <b>
            <font color="#9EA7E5">
              Sigil of Submission&nbsp;
            </font>
          </b>
          and hold them over
          it for 8 seconds. <br />
          You cannot enlighten those who have&nbsp;
          <b>
            mindshields.
          </b>
          <br />
          Make sure to take their&nbsp;
          <b>
            headset&nbsp;
          </b>
          so they don&#39;t spread misinformation!
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Defending Reebe" color="average">
        <Section>
          <b>
            You have a wide range of structures and powers
            that will be vital in defending the Celestial
            Gateway.
          </b>
          <br />
          <b>
            <font color="#B5FD9D">
              Replicant Fabricator:&nbsp;
            </font>
          </b>
          A powerful tool that can rapidly construct
          Brass structures, or convert most materials
          to Brass.
          <br />
          <b>
            <font color="#DED09F">
              Cogscarab:&nbsp;
            </font>
          </b>
          A small drone possessed by the spirits
          of the fallen soldiers which will protect
          Reebe while you go out and spread the
          truth!<br />
          <b>
            <font color="#FF9D9D">
              Clockwork Marauder:&nbsp;
            </font>
          </b>
          A powerful shell that can deflect ranged
          attacks and delivers a strong blow in close
          quarter combat.<br />
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Celestial Gateway" color="average">
        <Section>
          To summon Rat&#39;Var the&nbsp;
          <b>
            <font color="#E9E094">
              Celestial Gateway&nbsp;
            </font>
          </b> must be opened.
          <br />
          This can be done by having enough servants invoke&nbsp;
          <b>
            <font color="#B5FD9D">
              Celestial Gateway.&nbsp;
            </font>
          </b>
          <br />
          After you enlighten enough of the crew,
          the&nbsp;
          <b>
            <font color="#E9E094">
              Celestial Gateway&nbsp;
            </font>
          </b>
          will be forced open.
          <br />
          <b>
            Make sure you are prepared for when the
            Gateway opens, since the entire crew
            will swarm to destroy it!
          </b>
          <br />
        </Section>
      </Collapsible>
    </Fragment>
  );
};

export const ClockworkSpellList = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedTab } = props;
  const {
    scriptures = [],
  } = data;
  return (
    <Table>
      {scriptures.map(script => (
        script.type === selectedTab
          ? (
            <Fragment
              key={script}>
              <TableRow>
                <Table.Cell bold>
                  {script.name}
                </Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  <Button
                    fluid
                    color={script.purchased
                      ? "default"
                      : "average"}
                    content={script.purchased
                      ? "Invoke " + (convertPower(script.cost))
                      : script.cog_cost + " Cogs"}
                    disabled={false}
                    onClick={() => act("invoke", {
                      scriptureName: script.name,
                    })} />
                </Table.Cell>
              </TableRow>
              <TableRow>
                <Table.Cell>
                  {script.desc}
                </Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  <Button
                    fluid
                    content={"Quickbind"}
                    disabled={!script.purchased}
                    onClick={() => act("quickbind", {
                      scriptureName: script.name,
                    })} />
                </Table.Cell>
              </TableRow>
              <Table.Cell>
                <Divider />
              </Table.Cell>
            </Fragment>
          )
          : <Box key={script} />
      ))}
    </Table>
  );
};

export const ClockworkOverview = (props, context) => {
  const { data } = useBackend(context);
  const {
    power,
    cogs,
    vitality,
  } = data;
  return (
    <Box>
      <Box
        color="good"
        bold
        fontSize="16px">
        {"Celestial Gateway Report"}
      </Box>
      <Divider />
      <ClockworkOverviewStat
        title="Cogs"
        amount={cogs}
        maxAmount={cogs + (50 / cogs)}
        iconName="cog"
        unit="" />
      <ClockworkOverviewStat
        title="Power"
        amount={power}
        maxAmount={power + (500000 / power)}
        iconName="battery-half "
        overrideText={convertPower(power)} />
      <ClockworkOverviewStat
        title="Vitality"
        amount={vitality}
        maxAmount={vitality + (50 / vitality)}
        iconName="tint"
        unit="u" />
    </Box>
  );
};

export const ClockworkOverviewStat = (props, context) => {
  const {
    title,
    iconName,
    amount,
    maxAmount,
    unit,
    overrideText,
  } = props;
  return (
    <Box height="22px" fontSize="16px">
      <Grid>
        <Grid.Column>
          <Icon name={iconName} rotation={0} spin={0} />
        </Grid.Column>
        <Grid.Column size="2">
          {title}
        </Grid.Column>
        <Grid.Column size="8">
          <ProgressBar
            value={amount}
            minValue={0}
            maxValue={maxAmount}
            ranges={{
              good: [maxAmount/2, Infinity],
              average: [maxAmount/4, maxAmount/2],
              bad: [-Infinity, maxAmount/4],
            }}>
            {overrideText
              ? overrideText
              : amount + " " + unit}
          </ProgressBar>
        </Grid.Column>
      </Grid>
    </Box>
  );
};

export const ClockworkButtonSelection = (props, context) => {
  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', {});
  const tabs = ["Servitude", "Preservation", "Structures"];
  return (
    <Table>
      <Table.Row>
        {tabs.map(tab => (
          <Table.Cell
            key={tab}
            collapsing>
            <Button
              key={tab}
              fluid
              content={tab}
              onClick={() => setSelectedTab(tab)} />
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};
