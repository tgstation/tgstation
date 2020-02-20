import { Tabs, Section, Button, Grid } from "../../components";
import { Fragment } from "inferno";
import { sortBy } from "common/collections";

export const AccessList = props => {
  const {
    accesses = [],
    selectedList = [],
    accessMod,
    grantAll,
    denyAll,
    grantDep,
    denyDep,
  } = props;

  const diffMap = {
    0: {
      icon: 'times-circle',
      color: 'bad',
    },
    1: {
      icon: 'stop-circle',
      color: null,
    },
    2: {
      icon: 'check-circle',
      color: 'good',
    },
  };

  const checkAccessIcon = accesses => {
    let oneAccess = false;
    let oneInaccess = false;

    accesses.forEach(element => {
      if (selectedList.includes(element.ref)) {
        oneAccess = true;
      }
      else {
        oneInaccess = true;
      }
    });

    if (!oneAccess && oneInaccess) {
      return 0;
    }
    else if (oneAccess && oneInaccess) {
      return 1;
    }
    else {
      return 2;
    }
  };

  return (
    <Section
      title="Access"
      buttons={(
        <Fragment>
          <Button
            icon="check-double"
            content="Grant All"
            color="good"
            onClick={() => grantAll()} />
          <Button
            icon="undo"
            content="Deny All"
            color="bad"
            onClick={() => denyAll()} />
        </Fragment>
      )}>
      <Tabs vertical altSelection>
        {accesses.map(access => {
          const accessEntries = sortBy(
            entry => entry.desc,
          )(access.accesses || []);
          const icon = diffMap[checkAccessIcon(accessEntries)].icon;
          const color = diffMap[checkAccessIcon(accessEntries)].color;
          return (
            <Tabs.Tab
              key={access.name}
              label={access.name}
              color={color}
              icon={icon}>
              <Grid>
                <Grid.Column mr={0}>
                  <Button
                    fluid
                    icon="check"
                    content="Grant Region"
                    color="good"
                    onClick={() => grantDep(access.regid)} />
                </Grid.Column>
                <Grid.Column ml={0}>
                  <Button
                    fluid
                    icon="times"
                    content="Deny Region"
                    color="bad"
                    onClick={() => denyDep(access.regid)} />
                </Grid.Column>
              </Grid>
              {accessEntries.map(entry => (
                <Button.Checkbox
                  fluid
                  key={entry.desc}
                  content={entry.desc}
                  checked={selectedList.includes(entry.ref)}
                  onClick={() => accessMod(entry.ref)} />
              ))}
            </Tabs.Tab>
          );
        })}
      </Tabs>
    </Section>
  );
};
