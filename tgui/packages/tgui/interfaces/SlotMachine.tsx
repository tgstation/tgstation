import { useEffect, useState } from 'react';
import { Blink, Box, Button, Icon, Section, Stack } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Reel = {
  icons: string[];
  spinning: number;
};

type BackendData = {
  icons: string[];
  reels: Reel[];
  balance: number;
  working: number;
  money: number;
  cost: number;
  plays: number;
  jackpots: number;
  jackpot: number;
  paymode: number;
};

type IconMeta = { color: string };

const iconMetaByName: Record<string, IconMeta> = {
  'fa-7': { color: '#b22' },
  'fa-star': { color: '#fd6' },
  'fa-lemon': { color: '#ce0' },
  'fa-apple-whole': { color: '#d64' },
  'fa-biohazard': { color: '#2c0' },
  'fa-dollar-sign': { color: '#08b' },
  'fa-bomb': { color: '#876' },
};

const pluralS = (amount: number) => {
  return amount === 1 ? '' : 's';
};

const slotIconToColor = (iconName: string): string => {
  return iconMetaByName[iconName]?.color || '#f0f';
};

export const SlotMachine = (props) => {
  const { act, data } = useBackend<BackendData>();
  // icons: The list of possible icons, including colour and name
  // backendState: the current state of the slots according to the backend
  const { icons, plays, jackpots, money, cost, reels, balance, jackpot } = data;
  const spinning = data.working === 1;

  return (
    <Window width={300} height={396}>
      <Window.Content>
        <Banner />
        <Section>
          <div className={'SlotMachine__Reels'}>
            {reels.map((reel, i) => (
              <div key={i} className={'SlotMachine__Reel'}>
                <IconStrip
                  icons={icons}
                  iconsNeeded={reel.icons}
                  spinning={spinning}
                />
              </div>
            ))}
          </div>
        </Section>
        <Stack align={'stretch'}>
          <Stack.Item grow={1}>
            <Section
              fill
              title="Balance"
              buttons={
                <Button onClick={() => act('payout')} disabled={!(balance > 0)}>
                  Refund
                </Button>
              }
            >
              <Box textAlign={'center'} fontSize={2}>
                {formatMoney(balance)} cr
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill>
              <Button
                fluid
                textAlign={'center'}
                fontSize={3}
                color={'green'}
                onClick={() => act('spin')}
                disabled={spinning || balance < cost}
              >
                Spin!
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getBannerPages = () => [
  BannerTitle,
  BannerOnlyFewCreds,
  BannerPrizeMoney,
  BannerTitle,
  BannerJackpot,
  BannerStats,
];

const WINNING_TEXTS = [null, 'FREE SPIN!', 'BIG PRIZE!', 'JACKPOT!!!'];

const Banner = () => {
  const { data } = useBackend<BackendData>();
  const [page, setPage] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setPage((page) => (page + 1) % getBannerPages().length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const winningText = WINNING_TEXTS[data.winning];
  if (winningText) {
    return (
      <Section className={'SlotMachine__Banner SlotMachine__Banner--winning'}>
        <BannerTitle text={winningText} />
      </Section>
    );
  }

  const Component = getBannerPages()[page];

  return (
    <Section className={'SlotMachine__Banner'}>
      <Component />
    </Section>
  );
};

type BannerTitleProps = {
  text?: string;
  winning?: boolean;
};

const BannerTitle = (props: BannerTitleProps) => {
  const { data } = useBackend<BackendData>();
  const defaultText = data.balance <= 0 ? 'INSERT COIN' : 'SPIN! SPIN!';
  const letters = (props.text || defaultText).split('');
  return (
    <div className={'SlotMachine__BannerTitle'}>
      {letters.map((letter, i) => (
        <span key={i}>{letter}</span>
      ))}
    </div>
  );
};

const BannerOnlyFewCreds = () => {
  const { data } = useBackend<BackendData>();
  return (
    <div>
      Only{' '}
      <Blink interval={200} time={200}>
        <b>{data.cost}</b>
      </Blink>{' '}
      credit{pluralS(data.cost)} for a chance
      <br />
      to win <b>big</b>!
    </div>
  );
};

const BannerPrizeMoney = () => {
  const { data } = useBackend<BackendData>();
  return (
    <div>
      Available prize money:
      <br />
      <b>
        {data.money} credit{pluralS(data.money)}
      </b>
    </div>
  );
};

const BannerJackpot = () => {
  const { data } = useBackend<BackendData>();
  return (
    <div>
      Current jackpot:
      <br />
      <b>
        {data.money + data.jackpot} credit{pluralS(data.money + data.jackpot)}!
      </b>
    </div>
  );
};

const BannerStats = () => {
  const { data } = useBackend<BackendData>();
  return (
    <div>
      <Box inline fontSize={'13px'}>
        So far people have spun{' '}
        <b>
          {data.plays} time{pluralS(data.plays)}
        </b>
      </Box>
      <br />
      and won{' '}
      <b>
        {data.jackpots} jackpot{pluralS(data.jackpots)}!
      </b>
    </div>
  );
};

const ICON_STRIP_LENGTH = 30;

type IconStripProps = {
  icons: string[];
  iconsNeeded: string[];
  spinning?: boolean;
};

const randomizeIcons = (icons: string[], n: number) => {
  const result: string[] = [];
  for (let i = 0; i < n; i += 1) {
    const icon = icons[Math.floor(Math.random() * icons.length)];
    result.push(icon);
  }
  return result;
};

const IconStrip = (props: IconStripProps) => {
  const { icons, iconsNeeded, spinning } = props;

  const [drawnIcons, setDrawnIcons] = useState([
    ...randomizeIcons(icons, ICON_STRIP_LENGTH - 3),
    ...iconsNeeded,
  ]);

  useEffect(() => {
    if (spinning) {
      setDrawnIcons((drawnIcons) => [
        ...drawnIcons.slice(-3),
        ...randomizeIcons(icons, ICON_STRIP_LENGTH - 6),
        ...iconsNeeded,
      ]);
    } else {
      setDrawnIcons([
        ...randomizeIcons(icons, ICON_STRIP_LENGTH - 3),
        ...iconsNeeded,
      ]);
    }
  }, [spinning]);

  return (
    <div
      className={classes([
        'SlotMachine__IconStrip',
        spinning && 'SlotMachine__IconStrip--spinning',
      ])}
    >
      {drawnIcons.map((icon, i) => (
        <Icon
          key={i}
          size={2}
          lineHeight={'60px'}
          name={icon}
          color={slotIconToColor(icon)}
          style={{
            display: 'block',
          }}
        />
      ))}
    </div>
  );
};
