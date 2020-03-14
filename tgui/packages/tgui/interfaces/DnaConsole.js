import { useBackend } from '../backend';
import { Fragment, Component } from 'inferno';
import { Section, Box, LabeledList, ProgressBar, Grid, Button, Tabs, Flex, Table, Dropdown } from '../components';
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
    };

    this.state.color = this.getColor(props.selected);
  }

  onSelected(selected) {
    this.state.onSelected(selected);
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
        color={this.state.color}
        {... props}
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

  renderGeneSeq(ref, data, mutations, value) {
    return (
      <Box m={1}>
        <Table>
          <Table.Row>
            {mutations[value].SeqList.map((v, k) => {
              return (
                (k % 2 === 0)
                  ? (
                    <Table.Cell>
                      <DropdownEx
                        key={k+v+mutations[value].Alias}
                        textAlign="center"
                        options={data.GENES}
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
                            alias: mutations[value].Alias })} />
                    </Table.Cell>
                  ) : (
                    false
                  )
              );
            })}
          </Table.Row>
          <Table.Row>
            {mutations[value].SeqList.map((v, k) => {
              return (
                (k % 2 !== 0)
                  ? (
                    <Table.Cell>
                      <DropdownEx
                        key={k+v+mutations[value].Alias}
                        textAlign="center"
                        options={data.REVERSEGENES}
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
                            alias: mutations[value].Alias })} />
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
      SubjectMutations,
    } = data;
    const mutations = data.SubjectMutations || {};

    let t = "";

    return (
      <Section
        title="DNA Console"
        textAlign="left">
        <Section
          title="Subject Status"
          textAlign="left">
            {this.renderSubjectStatus(data)}
        </Section>
        <Section
          title="Scanner Status"
          textAlign="left">
            {this.renderScanner(data)}
        </Section>
        <Section
          title="Commands"
          textAlign="left">
          {this.renderCommands(ref, data)}
        </Section>
        <Tabs>
          <Tabs.Tab
            label="Mutations">
            {() => (
              "List of muts"
            )}
          </Tabs.Tab>
          <Tabs.Tab
            label="Genetic Sequencer">
            {() => (
              <Tabs altSelection>
                {data.SubjectMutations
                  ? (
                    Object.keys(mutations).map((value, key) => {
                      return (
                        <Tabs.Tab
                          key={key+mutations[value].Alias}
                          label=<img src={mutations[value].Image}
                            width={"65"} />
                          onClick={e =>
                            act(ref,
                              "checkdisc",
                              { alias: mutations[value].Alias })}>
                          {() => (
                            <Section
                              title={"Genetic Sequence ("
                                + mutations[value].Alias + ")"}
                              textAlign="left">
                              <LabeledList>
                                {mutations[value].Discovered
                                  ? (
                                    <Fragment>
                                      <LabeledList.Item label="Name">
                                        {mutations[value].Name
                                      + " (" + mutations[value].Alias + ")"}
                                      </LabeledList.Item>
                                      <LabeledList.Item label="Description">
                                        {mutations[value].Description}
                                      </LabeledList.Item>
                                      <LabeledList.Item label="Instability">
                                        {mutations[value].Instability}
                                      </LabeledList.Item>
                                      <LabeledList.Item label="Chromosome">
                                        ##TODO: Implement chromosome code.
                                      </LabeledList.Item>
                                    </Fragment>
                                  ) : (
                                    <LabeledList.Item label="Name">
                                      {mutations[value].Alias}
                                    </LabeledList.Item>)}
                              </LabeledList>
                              {this.renderGeneSeq(
                                ref, data, mutations, value,
                              )}
                            </Section>
                          )}
                        </Tabs.Tab>
                      );
                    })
                  ) : (
                    <Tabs.Tab
                      label="Words">
                      {() => (
                        "OH DEAR IT ALL WENT WRONG"
                      )}
                    </Tabs.Tab>
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
          <Tabs.Tab
            label="Disk">
            {() => (
              "Disk interface"
            )}
          </Tabs.Tab>
        </Tabs>
      </Section>
    );
  }
}
