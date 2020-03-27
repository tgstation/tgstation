import { useBackend } from '../backend';
import { Fragment, Component } from 'inferno';
import { Section, Box, LabeledList, ProgressBar, Grid, Button,
  Tabs, Flex, Table, Dropdown, Collapsible, NumberInput } from '../components';
import { act } from '../byond';

import { createLogger } from '../logging';

const logger = createLogger('dna_scannertgui');

const MODE_STORAGE = 1;
const MODE_SEQUENCER = 2;
const MODE_ENZYMES = 3;
const MODE_ADV_INJ = 4;

export class DropdownEx extends Component {
  constructor(props) {
    super(props);
    this.state = {
      defaultcolor: props.color || 'default',
      highlights: props.highlights || [],
      onSelected: props.onSelected,
      options: props.options || [],
      exKey: props.exKey,
    };

    this.state.color = this.getColor(props.selected);

    if (this.state.exKey) {
      this.state.optionsEx = this.createDropdownListFromObjectArray(
        this.state.options, this.state.exKey);
    }
    else {
      this.state.optionsEx = false;
    }
  }

  onSelected(selected) {
    let trueSelected = selected;
    this.state.options.map((value, key) => {
      if (value[this.state.exKey] === selected)
      { trueSelected = value; }
    });
    this.state.onSelected(trueSelected);
    this.setState({ color: this.getColor(selected) });
  }

  getColor(selected)
  {
    for (let pair in this.state.highlights) {
      if (
        Object.prototype.hasOwnProperty.call(
          this.state.highlights[pair],
          selected))
      { return this.state.highlights[pair][selected]; } }

    return this.state.defaultcolor;
  }

  createDropdownListFromObjectArray(srcList, keyEx) {
    let list = [];
    Object.keys(srcList).map((value, key) => {

      list.push(srcList[value][keyEx]);
    });

    return list;
  }

  render() {
    const { props } = this;
    const {
      over,
      noscroll,
      nochevron,
      width,
      onClick,
      selected,
      ...boxProps
    } = props;

    return (
      <Dropdown
        {... props}
        color={this.state.color}
        options={this.state.optionsEx
          ? this.state.optionsEx
          : props.options}
        onSelected={e => { this.onSelected(e); }}
      />

    );
  }
}

export class DnaConsole extends Component {
  constructor() {
    super();
    this.state = {
      mode: MODE_STORAGE,
    };
  }

  createBrefFilteredList(srcObject, bref) {
    let filteredList = [];
    Object.keys(srcObject).map((value, key) => {
      if (!(srcObject[value].ByondRef === bref)) {
        filteredList.push(srcObject[value]);
      }
    });
    return filteredList;
  }

  renderScanner(data) {
    return (
      <LabeledList>
        { data.IsScannerConnected
          ? data.ScannerOpen ? (
            <LabeledList.Item label="Scanner Door">
              Open
            </LabeledList.Item>
          ) : (
            <Fragment>
              <LabeledList.Item label="Scanner Door">
                Closed
              </LabeledList.Item>
              <LabeledList.Item label="Scanner Lock">
                {data.ScannerLocked ? "Engaged" : "Released"}
              </LabeledList.Item>
            </Fragment>
          ) : (
            <LabeledList.Item label="Scanner Door">
              Error: No scanner connected.
            </LabeledList.Item>
          )}
      </LabeledList>
    );
  }

  renderCooldowns(data) {
    return (
      <Grid mb={1}>
        <Grid.Column>
          <Section title="Scramble DNA">
            { data.IsScrambleReady
              ? "READY"
              : Math.floor(data.ScrambleSeconds/60)
                + ":"
                + ((data.ScrambleSeconds % 60) < 10
                  ? "0" + data.ScrambleSeconds % 60
                  : data.ScrambleSeconds % 60)}
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="JOKER Alogrithm">
            { data.IsJokerReady
              ? "READY"
              : Math.floor(data.JokerSeconds/60)
                + ":"
                + ((data.JokerSeconds % 60) < 10
                  ? "0" + data.JokerSeconds % 60
                  : data.JokerSeconds % 60)}
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Injector Cooldown">
            { data.IsInjectorReady
              ? "READY"
              : Math.floor(data.InjectorSeconds/60)
                + ":"
                + ((data.InjectorSeconds % 60) < 10
                  ? "0" + data.InjectorSeconds % 60
                  : data.InjectorSeconds % 60)}
          </Section>
        </Grid.Column>
      </Grid>
    );
  }

  renderSubjectStatus(data) {
    let buffer = [];
    let subjectStatusColor = "";

    switch (data.SubjectStatus) {
      case data.CONSCIOUS:
        subjectStatusColor = "good";
        break;
      case data.UNCONSCIOUS:
      case data.SOFT_CRIT:
        subjectStatusColor = "average";
        break;
      case data.DEAD:
        subjectStatusColor = "bad";
        break;
      default:
        subjectStatusColor = "good";
        break;
    }

    if (data.IsViableSubject) {
      buffer.push(
        <Fragment>
          <LabeledList.Item label="Status">
            {data.SubjectName}
            {" => "}
            <Box
              inline
              color={subjectStatusColor} >
              <b>
                {data.SubjectStatus === data.CONSCIOUS
                  ? "Conscious"
                  : data.SubjectStatus === data.SOFT_CRIT
                    ? "Critical"
                    : data.SubjectStatus === data.UNCONSCIOUS
                      ? "Unconscious"
                      : "Dead"}
              </b>
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Health">
            <ProgressBar
              value={data.SubjectHealth}
              minValue={0}
              maxValue={100}
              ranges={{
                olive: [101, Infinity],
                good: [70, 101],
                average: [30, 70],
                bad: [-Infinity, 30],
              }}>
              {data.SubjectHealth}%
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Radiation">
            <ProgressBar
              value={data.SubjectRads}
              minValue={0}
              maxValue={100}
              ranges={{
                bad: [71, Infinity],
                average: [30, 71],
                good: [0, 30],
                olive: [-Infinity, 0],
              }}>
              {data.SubjectRads}%
            </ProgressBar>
          </LabeledList.Item>
        </Fragment>,
      );
    }
    else {
      buffer.push(
        <LabeledList.Item label="Status">
          No viable subject in DNA Scanner.
        </LabeledList.Item>,
      );
    }

    return (
      <LabeledList>
        {buffer}
      </LabeledList>
    );
  }

  renderScannerCommands(ref, data) {
    let buffer = [];

    // If scanner is not connected, only display the connect button.
    if (!data.IsScannerConnected) {
      buffer.push(
        <Button
          content={"Connect Scanner"}
          onClick={() =>
            act(ref, "connect_scanner")} />,
      );
    }
    // Else display the rest of the buttons
    else {
      // Only display the Cancel Delayed Action button if there's one to cancel.
      if (data.HasDelayedAction) {
        buffer.push(
          <Button
            content={"Cancel Delayed Action"}
            onClick={() =>
              act(ref, "cancel_delay")} />,
        );
      }
      // Only display the Scramble DNA button if there's a viable occupant.
      if (data.IsViableSubject) {
        buffer.push(
          <Button
            disabled={
              !data.IsScrambleReady
              || data.IsPulsingRads
            }
            content={"Scramble DNA"}
            onClick={() =>
              act(ref, "scramble_dna")} />,
        );
      }
      // Display the open and lock scanner buttons
      buffer.push(
        <Fragment>
          <Button
            disabled={data.ScannerOpen}
            content={
              data.ScannerLocked
                ? ("Unlock Scanner")
                : ("Lock Scanner")
            }
            onClick={() =>
              act(ref, "toggle_lock")} />
          <Button
            disabled={data.ScannerLocked}
            content={
              data.ScannerOpen
                ? ("Close Scanner")
                : ("Open Scanner")
            }
            onClick={() =>
              act(ref, "toggle_door")} />
        </Fragment>,
      );
    }

    return (
      buffer
    );
  }

  renderConsoleCommands(ref, data) {
    let buffer = [];
    let modeBuffer = [];

    const seqOnClick = (ref, parent) => {
      parent.setState({ mode: MODE_SEQUENCER });
      act(ref, "all_check_discovery");
    };

    modeBuffer.push(
      <Button
        content={"Storage"}
        selected={this.state.mode === MODE_STORAGE}
        onClick={() => (
          this.setState({ mode: MODE_STORAGE })
        )} />,
    );

    if (data.IsViableSubject) {
      modeBuffer.push(
        <Button
          content={"Sequencer"}
          selected={this.state.mode === MODE_SEQUENCER}
          onClick={() => (
            seqOnClick(ref, this)
          )} />,
      );
    }

    modeBuffer.push(
      <Fragment>
        <Button
          content={"Enzymes"}
          selected={this.state.mode === MODE_ENZYMES}
          onClick={() => (
            this.setState({ mode: MODE_ENZYMES })
          )} />
        <Button
          content={"Advanced Injectors"}
          selected={this.state.mode === MODE_ADV_INJ}
          onClick={() => (
            this.setState({ mode: MODE_ADV_INJ })
          )} />
      </Fragment>,
    );

    buffer.push(
      <LabeledList.Item label="Mode">
        {modeBuffer}
      </LabeledList.Item>,
    );

    if (data.HasDisk) {
      buffer.push(
        <LabeledList.Item label="Disk">
          <Button
            disabled={!data.HasDisk}
            content={"Eject Disk"}
            onClick={() =>
              act(ref, "eject_disk")} />
        </LabeledList.Item>,
      );
    }

    return (
      buffer
    );
  }

  renderMode(ref, data, mutations) {
    let buffer = [];

    switch (this.state.mode) {
      case MODE_STORAGE:
        buffer.push(
          <Section
            title="Storage">
            {this.renderStorage(ref, data)}
          </Section>,
        );
        break;
      case MODE_SEQUENCER:
        buffer.push(
          <Section
            title="Genetic Sequencer">
            <Tabs altSelection>
              {data.SubjectMutations
                ? (
                  Object.keys(mutations).map((value, key) => {
                    return (
                      this.renderGeneticSequencer(
                        ref,
                        data,
                        mutations[value],
                        key)
                    );
                  })
                ) : (
                  false
                )}
            </Tabs>
          </Section>,
        );
        break;
      case MODE_ENZYMES:
        buffer.push(
          <Section
            title="Enzymes">
            {this.renderUniqueIdentifiers(ref, data)}
          </Section>,
        );
        break;
      case MODE_ADV_INJ:
        buffer.push(
          <Section
            title="Advanced Injectors">
            {this.renderAdvInjectors(ref, data)}
          </Section>,
        );
        break;
      default:
        break;
    }

    return (
      buffer
    );
  }

  renderGeneticInfo(ref, data, mut) {
    return (
      mut.Discovered
        ? (
          <Fragment>
            <LabeledList>
              <LabeledList.Item label="Name">
                {mut.Name}
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                {mut.Description}
              </LabeledList.Item>
              <LabeledList.Item label="Instability">
                {mut.Instability}
              </LabeledList.Item>
              <LabeledList.Item label="Add to Adv. Injector">
                <Dropdown
                  textAlign="center"
                  options={Object.keys(data.AdvInjectors)}
                  disabled={(Object.keys(data.AdvInjectors).length === 0)}
                  selected={
                    (Object.keys(data.AdvInjectors).length === 0)
                      ? "No Advanced Injectors"
                      : "Select an injector"
                  }
                  width={"280px"}
                  onSelected={value =>
                    act(ref, "add_adv_mut", {
                      mutref: mut.ByondRef, advinj: value })} />
              </LabeledList.Item>
            </LabeledList>
            {this.renderChromoAdd(
              ref, data, mut)}
            {this.renderSeqButtons(
              ref, data, mut)}
          </Fragment>
        ) : (
          <LabeledList>
            <LabeledList.Item label="Name">
              {mut.Alias}
            </LabeledList.Item>
          </LabeledList>)
    );
  }

  renderGeneticSequencer(ref, data, mut, key) {
    return (
      <Tabs.Tab
        color={(mut.Active)
          ? ("good")
          : ("bad")}
        key={`rgs_${key}_${mut.Alias}`}
        label=<img src={mut.Image}
          width={"65"} />
        onClick={e =>
          act(ref,
            "check_discovery",
            { alias: mut.Alias })}>
        {() => (
          <Fragment>
            <Section
              title={"Genetic Information ("
                + mut.Alias + ")"}
              textAlign="left">
              {this.renderGeneticInfo(
                ref, data, mut,
              )}
            </Section>
            <Section title="Genetic Sequence">
              {this.renderGeneSequence(
                ref, data, mut,
              )}
            </Section>
          </Fragment>
        )}
      </Tabs.Tab>
    );
  }

  renderGeneSequence(ref, data, mut) {
    return (
      <Box m={1}>
        {(data.SubjectStatus === data.DEAD)
          ? `GENETIC SEQUENCE CORRUPTED: SUBJECT DIAGNOSTIC REPORT - DECEASED`
          : (data.IsMonkey && (mut.Name !== "Monkified"))
            ? `GENETIC SEQUENCE CORRUPTED: SUBJECT DIAGNOSTIC REPORT - MONKEY`
            : (
              <Table>
                <Table.Row>
                  {mut.SeqList.map((v, k) => {
                    return (
                      (k % 2 === 0)
                        ? (
                          <Table.Cell>
                            <DropdownEx
                              disabled={(mut.Class !== data.MUT_NORMAL)}
                              key={k+v+mut.Alias}
                              textAlign="center"
                              options={
                                data.IsJokerReady
                                  ? ["J"].concat(data.REVERSEGENES)
                                  : data.REVERSEGENES
                              }
                              width="20px"
                              selected={v}
                              over
                              nochevron
                              noscroll
                              highlights={[
                                { "X": "red" },
                                { "A": "green" },
                                { "T": "green" },
                                { "G": "blue" },
                                { "C": "blue" },
                              ]}
                              onSelected={e =>
                                act(ref, "pulse_gene", {
                                  pos: k+1,
                                  gene: e,
                                  alias: mut.Alias })} />
                          </Table.Cell>
                        ) : (
                          false
                        )
                    );
                  })}
                </Table.Row>
                <Table.Row>
                  {mut.SeqList.map((v, k) => {
                    return (
                      (k % 2 !== 0)
                        ? (
                          <Table.Cell>
                            <DropdownEx
                              disabled={(mut.Class !== data.MUT_NORMAL)}
                              key={k+v+mut.Alias}
                              textAlign="center"
                              options={
                                data.IsJokerReady
                                  ? data.GENES.concat(["J"])
                                  : data.GENES
                              }
                              width="20px"
                              selected={v}
                              nochevron
                              noscroll
                              highlights={[
                                { "X": "red" },
                                { "A": "green" },
                                { "T": "green" },
                                { "G": "blue" },
                                { "C": "blue" },
                              ]}
                              onSelected={e =>
                                act(ref, "pulse_gene", {
                                  pos: k+1,
                                  gene: e,
                                  alias: mut.Alias })} />
                          </Table.Cell>
                        ) : (
                          false
                        )
                    );
                  })}
                </Table.Row>
              </Table>
            )}
      </Box>
    );
  }

  renderChromoAdd(ref, data, mut) {
    return (
      <LabeledList>
        {(mut.CanChromo !== null)
          ? (
            mut.CanChromo === data.CHROMOSOME_NEVER
              ? (
                <LabeledList.Item label="Compatible Chromosomes">
                  No compatible chromosomes
                </LabeledList.Item>
              ) : (
                (mut.CanChromo === data.CHROMOSOME_NONE)
                  ? (
                    <Fragment>
                      <LabeledList.Item label="Compatible Chromosomes">
                        {mut.ValidChromos}
                      </LabeledList.Item>
                      <LabeledList.Item label="Select Chromosome">
                        <Dropdown
                          textAlign="center"
                          options={mut.ValidStoredChromos}
                          disabled={(mut.ValidStoredChromos.length === 0)}
                          selected={
                            (mut.ValidStoredChromos.length === 0)
                              ? "No Suitable Chromosomes"
                              : "Select a chromosome"
                          }
                          width={"280px"}
                          onSelected={e =>
                            act(ref, "apply_chromo", {
                              chromo: e, mutref: mut.ByondRef })} />
                      </LabeledList.Item>
                    </Fragment>
                  ) : (
                    <LabeledList.Item label="Applied Chromosome">
                      {mut.AppliedChromo}
                    </LabeledList.Item>
                  )
              )
          ) : (
            false
          )}
      </LabeledList>
    );
  }

  renderSeqButtons(ref, data, mut) {
    return (
      mut.Active
        ? (
          <Box m={1}>
            <Button
              disabled={!data.IsInjectorReady}
              content={"Print Activator"}
              onClick={() =>
                act(ref, "print_injector",
                  { mutref: mut.ByondRef,
                    is_activator: 1,
                    source: "sequencer" })} />
            <Button
              disabled={!data.IsInjectorReady}
              content={"Print Mutator"}
              onClick={() =>
                act(ref, "print_injector",
                  { mutref: mut.ByondRef,
                    is_activator: 0,
                    source: "sequencer" })} />
            <Button
              disabled={!(data.MutationCapacity > 0)}
              content={"Save to Console"}
              onClick={() =>
                act(ref, "save_console",
                  { mutref: mut.ByondRef,
                    source: "sequencer" })} />
            <Button
              disabled={!data.HasDisk
              || !(data.DiskCapacity > 0)
              || data.DiskReadOnly}
              content={"Save to Disk"}
              onClick={() =>
                act(ref, "save_disk", {
                  mutref: mut.ByondRef,
                  source: "sequencer" })} />
            { ((mut.Class === data.MUT_EXTRA) || mut.Scrambled)
              ? <Button
                content={"Nullify"}
                onClick={() =>
                  act(
                    ref,
                    "nullify",
                    {
                      mutref: mut.ByondRef })} />
              : (false)}
          </Box>
        ) : (
          false
        )
    );
  }

  renderMutInfo(ref, data, mut, prefix, key, filteredList, source) {
    return (
      <Tabs.Tab
        key={`rmi_${prefix}_${key}_${mut.Name}`}
        label={mut.Name}>
        {() => (
          <Fragment>
            <Collapsible
              title="Information">
              <LabeledList>
                <LabeledList.Item label="Name">
                  {mut.Name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {mut.Description}
                </LabeledList.Item>
                <LabeledList.Item label="Instability">
                  {mut.Instability}
                </LabeledList.Item>
                { mut.CanChromo
                  ? (
                    <Fragment>
                      <LabeledList.Item label="Compatible Chromosomes">
                        {mut.ValidChromos}
                      </LabeledList.Item>
                      { mut.AppliedChromo
                        ? (
                          <LabeledList.Item label="Applied Chromosome">
                            {mut.AppliedChromo}
                          </LabeledList.Item>
                        ) : (
                          <LabeledList.Item label="Applied Chromosome">
                            None
                          </LabeledList.Item>
                        )}
                    </Fragment>
                  ) : (
                    <LabeledList.Item label="Compatible Chromosomes">
                      None
                    </LabeledList.Item>
                  ) }
              </LabeledList>
            </Collapsible>
            <Collapsible
              title="Combine">
              <DropdownEx
                key={prefix+source+"_dd_"+key}
                disable={(source === "console")
                  ? (!(data.MutationCapacity > 0))
                  : ((source === "disk")
                    ? (!data.HasDisk
                      || !(data.DiskCapacity > 0)
                      || data.DiskReadOnly)
                    : (false))}
                options={filteredList}
                exKey={"Name"}
                width={"150px"}
                selected={"Available Mutations"}
                onSelected={e =>
                  act(ref, "combine_" + source, {
                    srctype: mut.Type,
                    desttype: e.Type })} />
            </Collapsible>
            <Box m={1}>
              <Button
                disabled={!data.IsInjectorReady}
                content={"Print Activator"}
                onClick={() =>
                  act(ref, "print_injector",
                    { mutref: mut.ByondRef,
                      is_activator: 1,
                      source: source })} />
              <Button
                disabled={!data.IsInjectorReady}
                content={"Print Mutator"}
                onClick={() =>
                  act(ref, "print_injector",
                    { mutref: mut.ByondRef,
                      is_activator: 0,
                      source: source })} />
              { source === "console"
                ? (
                  <Button
                    disabled={!data.HasDisk
                    || !(data.DiskCapacity > 0)
                    || data.DiskReadOnly}
                    content={"Export to Disk"}
                    onClick={() =>
                      act(ref, "save_disk", {
                        mutref: mut.ByondRef,
                        source: source })} />)
                : (source === "disk"
                  ? (
                    <Button
                      disabled={!(data.MutationCapacity > 0)}
                      content={"Export to Console"}
                      onClick={() =>
                        act(ref, "save_console", {
                          mutref: mut.ByondRef,
                          source: source })} />)
                  : (false)
                )}

              <Button
                disabled
                content={"Add to Adv. Injector"}
                onClick={() =>
                  act(
                    ref,
                    "add_adv_injector",
                    {
                      mutref: mut.ByondRef,
                      source: source })} />
              <Button
                content={"Delete"}
                onClick={() =>
                  act(
                    ref,
                    "delete_" + source + "_mut",
                    {
                      mutref: mut.ByondRef })} />
            </Box>
          </Fragment>
        )}
      </Tabs.Tab>
    );
  }

  renderChromInfo(ref, data, chrom, prefix, key) {
    return (
      <Tabs.Tab
        key={`rci_${prefix}_${key}_${chrom.Name}`}
        label={chrom.Name}>
        {() => (
          <Fragment>
            <LabeledList>
              <LabeledList.Item label="Name">
                {chrom.Name}
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                {chrom.Description}
              </LabeledList.Item>
            </LabeledList>
            <Box m={1}>
              <Button
                content={"Eject Chromosome"}
                onClick={() =>
                  act(ref, "eject_chromo",
                    { chromo: chrom.Name })} />
            </Box>
          </Fragment>
        )}
      </Tabs.Tab>
    );
  }

  renderMutStorage(ref, data, source, storageList) {
    return (
      <Section
        title="Mutation Storage"
        textAlign="left">
        <Tabs vertical>
          { Object.keys(storageList).map((value, key) => {
            return (
              this.renderMutInfo(
                ref,
                data,
                storageList[value],
                "mut_stor",
                key,
                this.createBrefFilteredList(
                  storageList,
                  storageList.ByondRef),
                source,
              )
            ); }) }
        </Tabs>
      </Section>
    );
  }

  renderChromoStorage(ref, data) {
    return (
      <Section
        title="Chromosome Storage"
        textAlign="left">
        <Tabs vertical>
          { Object.keys(data.ChromoStorage).map((value, key) => {
            return (
              this.renderChromInfo(
                ref,
                data,
                data.ChromoStorage[value],
                "chrom_stor",
                key,
              )); }) }
        </Tabs>
      </Section>
    );
  }

  renderStorage(ref, data) {
    return (
      <Tabs vertical>
        <Tabs.Tab
          key={`rs_console`}
          label="Console">
          { () => (
            <Fragment>
              {this.renderMutStorage(
                ref,
                data,
                "console",
                data.MutationStorage)}
              {this.renderChromoStorage(ref, data)}
            </Fragment>
          )}
        </Tabs.Tab>
        { data.HasDisk
          ? (
            <Tabs.Tab
              key={`rs_disk`}
              label="Disk">
              {() => (
                <Fragment>
                  {this.renderMutStorage(
                    ref,
                    data,
                    "disk",
                    data.DiskMutations)}
                  {data.DiskHasMakeup
                    ? (
                      <Section
                        title="Genetic Makeup Storage"
                        textAlign="left">
                        <LabeledList>
                          <LabeledList.Item label="Subject">
                            {data.DiskMakeupBuffer.name
                              ? data.DiskMakeupBuffer.name
                              : "None"}
                          </LabeledList.Item>
                          <LabeledList.Item label="Blood Type">
                            {data.DiskMakeupBuffer.blood_type
                              ? data.DiskMakeupBuffer.blood_type
                              : "None"}
                          </LabeledList.Item>
                          <LabeledList.Item label="Unique Enzyme">
                            {data.DiskMakeupBuffer.UE
                              ? data.DiskMakeupBuffer.UE
                              : "None"}
                          </LabeledList.Item>
                          <LabeledList.Item label="Unique Identifier">
                            {data.DiskMakeupBuffer.UI
                              ? data.DiskMakeupBuffer.UI
                              : "None"}
                          </LabeledList.Item>
                          {(data.DiskMakeupBuffer.UI
                            && data.DiskMakeupBuffer.UE)
                            ? (
                              <LabeledList.Item label="UE/UI Combination">
                                {data.DiskMakeupBuffer.UI
                                  + "/"
                                  + data.DiskMakeupBuffer.UE}
                              </LabeledList.Item>
                            ) : false }
                        </LabeledList>
                        <Button
                          disabled={data.DiskReadOnly}
                          content={"Delete"}
                          onClick={(e, value) => (
                            act(ref, "del_makeup_disk")
                          )} />
                      </Section>)
                    : (false)}
                </Fragment>)}
            </Tabs.Tab>
          ) : (
            false)}
      </Tabs>
    );
  }

  renderUniqueIdentifiers(ref, data) {
    return (
      <Fragment>
        <Section
          title="Radiation Emitter Status"
          textAlign="left">
          <LabeledList>
            <LabeledList.Item label="Output Level">
              <NumberInput
                value={data.RadStrength}
                step={1}
                stepPixelSize={10}
                minValue={1}
                maxValue={data.RADIATION_STRENGTH_MAX}
                animated
                onDrag={(e, value) => (
                  act(ref, "set_pulse_strength", { val: value })
                )} />
            </LabeledList.Item>
            <LabeledList.Item label=" > Mutation">
              {`(-${data.StdDevStr} to +${data.StdDevStr} = 68 %)`
              + `(-${2*(data.StdDevStr)} to +${2*(data.StdDevStr)} = 95 %)`}
            </LabeledList.Item>
            <LabeledList.Item label="Pulse Duration">
              <NumberInput
                value={data.RadDuration}
                step={1}
                stepPixelSize={10}
                minValue={1}
                maxValue={data.RADIATION_DURATION_MAX}
                animated
                onDrag={(e, value) => (
                  act(ref, "set_pulse_duration", { val: value })
                )} />
            </LabeledList.Item>
            <LabeledList.Item label=" > Accuracy">
              {data.StdDevAcc}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {data.IsViableSubject
          ? (
            <Section
              title="Unique Identifiers"
              textAlign="left">
              {this.renderUniqueIdentifierButtons(ref, data)}
            </Section>
          ) : (
            false
          )}
        <Section
          title="Genetic Makeup Buffers"
          textAlign="left">
          {this.renderMakeupBuffers(ref, data)}
        </Section>
      </Fragment>
    );
  }

  renderUniqueIdentifierButtons(ref, data) {
    let buffer = [];
    let current_block = 0;
    let uni_list = data.SubjectUNIList;

    for (let i = 0; i < uni_list.length; ++i) {
      if ((i % data.DNA_BLOCK_SIZE) === 0) {
        buffer.push(
          <Button
            content={++current_block}
            disabled />,
        );
      }

      buffer.push(
        <Button
          content={uni_list[i]}
          onClick={e => (
            act(ref, "makeup_pulse", { index: i+1 })
          )} />,
      );
    }
    return (
      buffer
    );
  }

  renderMakeupButtons(ref, data, index) {
    return (
      <Collapsible
        title="Commands">
        <Box m={1}>
          {data.IsViableSubject
            ? (
              <Fragment>
                <Button
                  content={"Transfer Enzyme"}
                  onClick={e => (
                    act(ref, "makeup_apply", { index: index, type: "ue" })
                  )} />
                <Button
                  content={"Transfer Identity"}
                  onClick={e => (
                    act(ref, "makeup_apply", { index: index, type: "ui" })
                  )} />
                <Button
                  content={"Transfer Full Makeup"}
                  onClick={e => (
                    act(ref, "makeup_apply", { index: index, type: "mixed" })
                  )} />
              </Fragment>
            ) : (
              <Fragment>
                <Button
                  content={"Transfer Enzyme (Delayed)"}
                  onClick={e => (
                    act(ref, "makeup_delay", { index: index, type: "ue" })
                  )} />
                <Button
                  content={"Transfer Identity (Delayed)"}
                  onClick={e => (
                    act(ref, "makeup_delay", { index: index, type: "ui" })
                  )} />
                <Button
                  content={"Transfer Full Makeup (Delayed)"}
                  onClick={e => (
                    act(ref, "makeup_delay", { index: index, type: "mixed" })
                  )} />
              </Fragment>
            )}
        </Box>
        <Box m={1}>
          <Button
            content={"Print Enzyme Injector"}
            onClick={e => (
              act(ref, "makeup_injector", { index: index, type: "ue" })
            )} />
          <Button
            content={"Print Identity Injector"}
            onClick={e => (
              act(ref, "makeup_injector", { index: index, type: "ui" })
            )} />
          <Button
            content={"Print Full Makeup Injector"}
            onClick={e => (
              act(ref, "makeup_injector", { index: index, type: "mixed" })
            )} />
        </Box>
      </Collapsible>
    );
  }

  renderMakeupBuffers(ref, data) {
    let buffer = [];
    let currentMakeup;

    for (let i = 1; i <= data.MakeupCapcity; ++i) {
      currentMakeup = data.MakeupStorage[i.toString()];
      buffer.push(
        currentMakeup
          ? (
            <Collapsible
              title={
                currentMakeup.label
                  ? currentMakeup.label
                  : currentMakeup.name
              }
              buttons={
                <Fragment>
                  <Button
                    disabled={!(data.IsViableSubject)}
                    content={"Save To Slot"}
                    onClick={(e, value) => (
                      act(ref, "save_makeup_console", { index: i })
                    )} />
                  <Button
                    content={"Clear Slot"}
                    onClick={(e, value) => (
                      act(ref, "del_makeup_console", { index: i })
                    )} />
                  <Button
                    disabled={!(data.HasDisk) || !(data.DiskHasMakeup)}
                    content={"Import From Disk"}
                    onClick={(e, value) => (
                      act(ref, "load_makeup_disk", { index: i })
                    )} />
                  <Button
                    disabled={!(data.HasDisk)
                    || (data.DiskReadOnly)}
                    content={"Export To Disk"}
                    onClick={(e, value) => (
                      act(ref, "save_makeup_disk", { index: i })
                    )} />
                </Fragment>
              } >
              <LabeledList>
                <LabeledList.Item label="Subject">
                  {currentMakeup.name
                    ? currentMakeup.name
                    : "None"}
                </LabeledList.Item>
                <LabeledList.Item label="Blood Type">
                  {currentMakeup.blood_type
                    ? currentMakeup.blood_type
                    : "None"}
                </LabeledList.Item>
                <LabeledList.Item label="Unique Enzyme">
                  {currentMakeup.UE
                    ? currentMakeup.UE
                    : "None"}
                </LabeledList.Item>
                <LabeledList.Item label="Unique Identifier">
                  {currentMakeup.UI
                    ? currentMakeup.UI
                    : "None"}
                </LabeledList.Item>
              </LabeledList>
              {this.renderMakeupButtons(ref, data, i)}
            </Collapsible>)
          : (
            <Collapsible
              title={"Slot " + i}
              buttons={(
                <Fragment>
                  <Button
                    content={"Save To Slot"}
                    onClick={(e, value) => (
                      act(ref, "save_makeup_console", { index: i })
                    )} />
                  <Button
                    disabled={!(data.HasDisk) || !(data.DiskHasMakeup)}
                    content={"Import From Disk"}
                    onClick={(e, value) => (
                      act(ref, "load_makeup_disk", { index: i })
                    )} />
                </Fragment>
              )}>
              No stored subject data.
            </Collapsible>
          ),
      );
    }

    return (
      buffer
    );
  }

  renderAdvInjectors(ref, data) {
    let buffer = [];

    if (data.AdvInjectors) {
      if (Object.keys(data.AdvInjectors).length < data.MaxAdvInjectors) {
        buffer.push(
          <Button.Input
            m={1}
            content={"Create New Injector"}
            onCommit={(e, v) => (
              act(ref, "new_adv_inj", { name: v })
            )} />,
        );
      }

      Object.keys(data.AdvInjectors).map((value, key) => {
        return (
          buffer.push(
            <Collapsible
              title={value}
              buttons={(
                <Fragment>
                  <Button
                    content={"Delete"}
                    onClick={() => (
                      act(ref, "del_adv_inj", { name: value })
                    )} />
                  <Button
                    content={"Print"}
                    onClick={() => (
                      act(ref, "print_adv_inj", { name: value })
                    )} />
                </Fragment>
              )} >
              <Section
                title="Mutations"
                textAlign="left">
                {this.renderAdvInjMutations(
                  ref, data, data.AdvInjectors[value], value)}
              </Section>
            </Collapsible>,
          )
        );
      });
    }

    return (
      <Section
        title="Advanced Injectors"
        textAlign="left">
        {buffer}
      </Section>
    );
  }

  renderAdvInjMutations(ref, data, inj, injname) {
    let buffer = [];

    Object.keys(inj).map((value, key) => (
      buffer.push(
        <Tabs.Tab
          key={`raim_${value}_${key}_${injname}`}
          label={inj[value].Name}>
          {() => (
            <Fragment>
              <LabeledList>
                <LabeledList.Item label="Name">
                  {inj[value].Name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {inj[value].Description}
                </LabeledList.Item>
                <LabeledList.Item label="Instability">
                  {inj[value].Instability}
                </LabeledList.Item>
                {
                  inj[value].AppliedChromo
                    ? (
                      <LabeledList.Item label="Chromosome">
                        {inj[value].AppliedChromo}
                      </LabeledList.Item>
                    ) : (
                      false
                    )
                }
              </LabeledList>
              <Button
                content={"Delete"}
                onClick={e => (
                  act(
                    ref,
                    "del_adv_mut",
                    { advinj: injname, mutref: inj[value].ByondRef },
                  )
                )} />
            </Fragment>
          )}
        </Tabs.Tab>,
      )
    ));

    return (
      <Tabs vertical>
        {buffer}
      </Tabs>
    );
  }


  render() {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;

    const mutations = data.SubjectMutations || {};

    return (
      <Fragment>
        <Section
          title="DNA Scanner"
          textAlign="left"
          buttons={this.renderScannerCommands(ref, data)}>
          {this.renderSubjectStatus(data)}
        </Section>
        {this.renderCooldowns(data)}
        <Section
          title="DNA Console"
          textAlign="left">
          <LabeledList>
            {this.renderConsoleCommands(ref, data)}
          </LabeledList>
        </Section>
        {data.IsPulsingRads
          ? (
            <Table>
              <Table.Row>
                {"Radiation pulse underway..."}
              </Table.Row>
              <Table.Row>
                {"Process complete in "
                + Math.floor(data.RadPulseSeconds/60)
                  + ":"
                  + ((data.RadPulseSeconds % 60) < 10
                    ? "0" + data.RadPulseSeconds % 60
                    : data.RadPulseSeconds % 60)}
              </Table.Row>
            </Table>
          ) : (
            data.HasDelayedAction
              ? (false)
              : (
                this.renderMode(ref, data, mutations)
              )
          )}
      </Fragment>
    );
  }
}
