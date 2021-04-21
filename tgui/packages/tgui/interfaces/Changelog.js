import { classes } from 'common/react';
import { Component, Fragment } from 'inferno';
import { Box, Icon, Section, Table } from "../components";
import { Window } from "../layouts";
import { resolveAsset } from '../assets';

// Do not change the order, it is important
const icons = [
  { icon: 'bug', color: 'green' }, // bugfix
  { icon: 'hammer', color: 'orange' }, // wip
  { icon: 'hand-holding-heart', color: 'green' }, // qol
  { icon: 'tg-sound-plus', color: 'green' }, // soundadd
  { icon: 'tg-sound-minus', color: 'red' }, // sounddel
  { icon: 'check-circle', color: 'green' }, // rscadd
  { icon: 'times-circle', color: 'red' }, // rscdel
  { icon: 'tg-image-plus', color: 'green' }, // imageadd
  { icon: 'tg-image-minus', color: 'red' }, // imagedel
  { icon: 'spell-check', color: 'green' }, // spellcheck
  { icon: 'radiation', color: 'orange' }, // experiment
  { icon: 'balance-scale-right', color: 'yellow' }, // balance
  { icon: 'code', color: 'green' }, // code_imp
  { icon: 'tools', color: 'green' }, // refactor
  { icon: 'cogs', color: 'purple' }, // config
  { icon: 'user-shield', color: 'purple' }, // admin
  { icon: 'server', color: 'purple' }, // server
];

const Header = () => (
  <>
    <h1>Traditional Games Space Station 13</h1>
    <p>
      <b>Thanks to: </b>
      Baystation 12, /vg/station, NTstation, CDK Station devs, FacepunchStation,
      GoonStation devs, the original Space Station 13 developers, Invisty for
      the title image and the countless others who have contributed to the game,
      issue tracker or wiki over the years.
    </p>
    <p>
      {'Current project maintainers can be found '}
      <a href="https://github.com/tgstation?tab=members">
        here
      </a>
      {', recent GitHub contributors can be seen '}
      <a href="https://github.com/tgstation/tgstation/pulse/monthly">
        here
      </a>.
    </p>
    <p>
      {'You can also join our discord '}
      <a href="https://tgstation13.org/phpBB/viewforum.php?f=60">
        here
      </a>.
    </p>
  </>
);

const Footer = () => (
  <>
    <h3>GoonStation 13 Development Team</h3>
    <p>
      <b>Coders: </b>
      Stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob,
      Justicefries, 0staf, sniperchance, AngriestIBM, BrianOBlivion
    </p>
    <p>
      <b>Spriters: </b>
      Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No
    </p>
    <p>
      <b>Licence: </b>
      <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
        Creative Commons Attribution-Noncommercial-Share Alike 3.0 License.
      </a>
    </p>
    <p>
      {'Except where otherwise noted, Goon Station 13 is licensed under a '}
      <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
        Creative Commons Attribution-Noncommercial-Share Alike 3.0 License.
      </a>
      {' Rights are currently extended to '}
      <a href="http://forums.somethingawful.com/">SomethingAwful Goons</a>
      {' only.'}
    </p>
    <p>
      {'Some icons by '}
      <a href="https://p.yusukekamiyamane.com/">
        Yusuke Kamiyamane.
      </a>
      {' All rights reserved. Licensed under a '}
      <a href="https://creativecommons.org/licenses/by/3.0/">
        Creative Commons Attribution 3.0 License.
      </a>
    </p>
  </>
);

const ChangelogData = (props) => {
  const { data } = props;

  return (
    Object.entries(data).map(([date, authors]) => (
      <Section key={date} title={date}>
        <Box ml={3}>
          {Object.entries(authors).map(([name, changes]) => (
            <Fragment key={name}>
              <h4>{name} changed:</h4>
              <Box ml={3}>
                <Table>
                  {changes.map(change => {
                    const index = Object.keys(change)[0];
                    return (
                      <Table.Row key={index + change[index]}>
                        <Table.Cell
                          className="Changelog__Cell"
                          style={{ width: '25px' }}
                        >
                          <Icon
                            className={classes([
                              "Changelog__Icon",
                              icons[index].class,
                            ])}
                            color={icons[index].color}
                            name={icons[index].icon}
                          />
                        </Table.Cell>
                        <Table.Cell className="Changelog__Cell">
                          {change[index]}
                        </Table.Cell>
                      </Table.Row>
                    );
                  })}
                </Table>
              </Box>
            </Fragment>
          ))}
        </Box>
      </Section>
    ))
  );
};

export class Changelog extends Component {
  constructor() {
    super();
    this.state = {
      data: null,
    };
  }

  setData(data) {
    this.setState({ data });
  }

  getData = () => {
    const self = this;
    fetch(resolveAsset('changelog.json'))
      .then(async (changelogData) => {
        self.setData(await changelogData.json());
      });
  }

  componentDidMount() {
    this.getData();
  }

  render() {
    const { data } = this.state;

    return (
      <Window title="Changelog" width={675} height={650}>
        <Window.Content scrollable>
          <Header />
          {data && <ChangelogData data={data} />}
          {!data && <p>Loading changelog data...</p>}
          <Footer />
        </Window.Content>
      </Window>
    );
  }
}
