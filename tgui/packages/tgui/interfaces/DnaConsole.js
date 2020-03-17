import { useBackend } from '../backend';
import { Fragment, Component } from 'inferno';
import { Section, Box, LabeledList, ProgressBar, Grid, Button, Tabs, Flex, Table, Dropdown, Collapsible } from '../components';
import { act } from '../byond';

import { createLogger } from '../logging';

const logger = createLogger('dna_scannertgui');

export class DropdownEx extends Component {
  constructor(props) {
    super(props);
    this.state = {
      defaultcolor: props.color || 'default',
      highlights: props.highlights || [],
      onSelected: props.onSelected,
      options: props.options || [],
      exKey: props.exKey
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
      { trueSelected = value }
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
      <LabeledList>
        <LabeledList.Item label="Scramble DNA">
          { data.IsScrambleReady
            ? "READY"
            : Math.floor(data.ScrambleSeconds/60)
              + ":"
              + ((data.ScrambleSeconds % 60) < 10
                ? "0" + data.ScrambleSeconds % 60
                : data.ScrambleSeconds % 60)}
        </LabeledList.Item>
        <LabeledList.Item label="JOKER Alogrithm">
          { data.IsJokerReady
            ? "READY"
            : Math.floor(data.JokerSeconds/60)
              + ":"
              + ((data.JokerSeconds % 60) < 10
                ? "0" + data.JokerSeconds % 60
                : data.JokerSeconds % 60)}
        </LabeledList.Item>
        <LabeledList.Item label="Injector Cooldown">
          { data.IsInjectorReady
            ? "READY"
            : Math.floor(data.InjectorSeconds/60)
              + ":"
              + ((data.InjectorSeconds % 60) < 10
                ? "0" + data.InjectorSeconds % 60
                : data.InjectorSeconds % 60)}
        </LabeledList.Item>
      </LabeledList>
    );
  }

  renderSubjectStatus(data) {
    return (
      <LabeledList>
        { data.IsViableSubject
          ? (
            <Fragment>
              <LabeledList.Item label="Status">
                {data.SubjectName}{" => "}
                {data.SubjectStatus === data.CONSCIOUS
                  ? ("Conscious")
                  : data.SubjectStatus === data.UNCONSCIOUS
                    ? ("Unconscious")
                    : ("Dead")}
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
              <LabeledList.Item label="Unique Enzymes">
                {data.SubjectEnzymes}
              </LabeledList.Item>
            </Fragment>
          ) : (
            <LabeledList.Item label="Subject Status">
              No viable subject in DNA Scanner.
            </LabeledList.Item>
          )}
      </LabeledList>
    );
  }

  renderCommands(ref, data) {
    return (
      <Fragment>
        <Button
          disabled={data.IsScannerConnected}
          content={"Connect Scanner"}
          onClick={() =>
            act(ref, "connect_scanner")} />
        <Button
          disabled={!data.IsScannerConnected | data.ScannerLocked}
          content={data.IsScannerConnected
            ? (data.ScannerOpen
              ? ("Close Scanner")
              : ("Open Scanner"))
            : ("No Scanner")}
          onClick={() =>
            act(ref, "toggle_door")} />
        <Button
          disabled={!data.IsScannerConnected || data.ScannerOpen}
          content={data.IsScannerConnected
            ? (data.ScannerLocked
              ? ("Unlock Scanner")
              : ("Lock Scanner"))
            : ("No Scanner")}
          onClick={() =>
            act(ref, "toggle_lock")} />
        <Button
          disabled={!data.IsScannerConnected
            || !data.IsViableSubject
            || !data.IsScrambleReady}
          content={"Scramble DNA"}
          onClick={() =>
            act(ref, "scramble_dna")} />
      </Fragment>
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
          ? ("green")
          : ("yellow")}
        key={key+mut.Alias}
        label=<img src={mut.Image}
          width={"65"} />
        onClick={e =>
          act(ref,
            "checkdisc",
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
                          { "A": "olive" },
                          { "T": "olive" },
                          { "G": "blue" },
                          { "C": "blue" },
                        ]}
                        onSelected={e =>
                          act(ref, "pulsegene", {
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
                          { "A": "olive" },
                          { "T": "olive" },
                          { "G": "blue" },
                          { "C": "blue" },
                        ]}
                        onSelected={e =>
                          act(ref, "pulsegene", {
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
                            act(ref, "applychromo", {
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
                    is_activator: 1 })} />
            <Button
              disabled={!data.IsInjectorReady}
              content={"Print Mutator"}
              onClick={() =>
                act(ref, "print_injector",
                  { mutref: mut.ByondRef,
                    is_activator: 0 })} />
            <Button
              disabled={!(data.MutationCapacity > 0)}
              content={"Save to Console"}
              onClick={() =>
                act(ref, "save_console", { mutref: mut.ByondRef })} />
            <Button
              disabled={!data.HasDisk
              || !(data.DiskCapacity > 0)
              || data.DiskReadOnly}
              content={"Save to Disk"}
              onClick={() =>
                act(ref, "save_disk", {
                  mutref: mut.ByondRef })} />
            <Button
              disabled
              content={"Add to Adv. Injector"}
              onClick={() =>
                act(
                  ref,
                  "add_adv_injector",
                  {
                    mutref: mut.ByondRef })} />
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
        key={prefix+key+mut.Name}
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
                disable={ (source === "console")
                  ? ( !(data.MutationCapacity > 0) )
                  : ( (source === "disk")
                    ? ( !data.HasDisk
                      || !(data.DiskCapacity > 0)
                      || data.DiskReadOnly )
                    : ( false ))}
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
                      is_activator: 1 })} />
              <Button
                disabled={!data.IsInjectorReady}
                content={"Print Mutator"}
                onClick={() =>
                  act(ref, "print_injector",
                    { mutref: mut.ByondRef,
                      is_activator: 0 })} />
              { source === "console"
                ? (
                  <Button
                    disabled={!data.HasDisk
                    || !(data.DiskCapacity > 0)
                    || data.DiskReadOnly}
                    content={"Export to Disk"}
                    onClick={() =>
                      act(ref, "save_disk", {
                        mutref: mut.ByondRef })} />)
                : (source === "disk"
                  ? (
                    <Button
                      disabled={!(data.MutationCapacity > 0)}
                      content={"Export to Console"}
                      onClick={() =>
                        act(ref, "save_console", {
                          mutref: mut.ByondRef })} />)
                  : (false)
                )
              }

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
        key={prefix+key+chrom.Name}
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
    logger.log(JSON.stringify(source))
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
                  storageList.ByondRef,),
                source
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

  renderStorage(ref, data)
  {
    return (
      <Tabs vertical>
        <Tabs.Tab label="Console">
          { () => (
            <Fragment>
              {this.renderMutStorage(ref, data, "console", data.MutationStorage)}
              {this.renderChromoStorage(ref, data)}
            </Fragment>
          )}
        </Tabs.Tab>
      </Tabs>
    )
  }

  render()
  {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;
    const {
      IsScannerConnected,
      ScannerOpen,
      ScannerLocked,
      IsViableSubject,
      SubjectName,
      SubjectStatus,
      SubjectHealth,
      SubjectRads,
      SubjectEnzymes,
      IsScrambleReady,
      IsJokerReady,
      IsInjectorReady,
      ScrambleSeconds,
      JokerSeconds,
      InjectorSeconds,
      HasDisk,
      DiskCapacity,
      DiskReadOnly,
      MutationCapacity,
      MutationStorage,
      ChromoCapacity,
      ChromoStore,
      CONSCIOUS,
      UNCONSCIOUS,
      GENES,
      REVERSEGENES,
      CHROMOSOME_NEVER,
      CHROMOSOME_NONE,
      CHROMOSOME_USED,
    } = data;
    const mutations = data.SubjectMutations || {};

    return (
      <Section
        title="DNA Console"
        textAlign="left">
        <Section
          title="Subject Status"
          textAlign="left">
          {this.renderSubjectStatus(data)}
        </Section>
        <Flex>
          <Section
            title="DNA Scanner Status"
            textAlign="left">
            {this.renderScanner(data)}
          </Section>
          <Section
            title="DNA Console Status"
            textAlign="left">
            {this.renderCooldowns(data)}
          </Section>
        </Flex>
        <Section
          title="Commands"
          textAlign="left">
          {this.renderCommands(ref, data)}
        </Section>
        <Tabs>
          <Tabs.Tab
            label="Storage">
            {() => {
              return (
                <Fragment>
                  {this.renderStorage(ref, data)}
                </Fragment>
              );
            }}
          </Tabs.Tab>
          <Tabs.Tab
            label="Genetic Sequencer"
            disabled={!IsViableSubject}>
            {() => (
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
            )}
          </Tabs.Tab>
          <Tabs.Tab
            label="Unique Identifiers">
            {() => (
              "List of UIs"
            )}
          </Tabs.Tab>
          <Tabs.Tab
            label="Advanced Injectors">
            {() => (
              "List of advanced injectors."
            )}
          </Tabs.Tab>
        </Tabs>
      </Section>
    );
  }
}
