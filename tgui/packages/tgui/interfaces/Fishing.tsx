import { clamp } from 'common/math';
import { KEY_CTRL } from 'common/keycodes';
import { randomInteger, randomNumber, randomPick, randomProb } from 'common/random';
import { useDispatch } from 'common/redux';
import { Component } from 'inferno';
import { resolveAsset } from '../assets';
import { backendSuspendStart, useBackend } from '../backend';
import { Icon, KeyListener } from '../components';
import { globalEvents, KeyEvent } from '../events';
import { Window } from '../layouts';

type Bait = {
  position: number;
  height: number;
  velocity: number;
};

type Fish = {
  position: number;
  height: number;
  velocity: number;
  target: number | null;
};

type FishAI = 'dumb' | 'zippy' | 'slow';

enum ReelingState {
  Idle,
  Reeling,
  ReelingDown,
}

type FishingMinigameProps = {
  difficulty: number;
  fish_ai: FishAI;
  special_rules: SpecialRule[];
  background: string;
  win: () => void;
  lose: () => void;
};

type FishingMinigameState = {
  completion: number;
  bait: Bait;
  fish: Fish;
};

type SpecialRule =
  | 'weighted'
  | 'limit_loss'
  | 'heavy'
  | 'bidirectional'
  | 'no_escape'
  | 'lubed';

class FishingMinigame extends Component<
  FishingMinigameProps,
  FishingMinigameState
> {
  animation_id: number;
  last_frame: number;
  reeling: ReelingState = ReelingState.Idle;
  area_height: number = 1000;
  state: FishingMinigameState;
  currentVelocityLimit: number = 200;
  // Difficulty & special rules dependent variables
  completionLossPerSecond: number;
  baitBounceCoeff: number;
  difficultyActionFreqCoeff: number = 1;
  longJumpVelocityLimit: number = 200;
  shortJumpVelocityLimit: number = 400;
  idleVelocity: number = 0;
  accel_up_coeff: number = 1;
  bidirectional: boolean = false;
  no_escape: boolean = false;

  baseLongJumpChancePerSecond: number = 0.0075;
  baseShortJumpChancePerSecond: number = 0.255;
  interruptMove: boolean = true;

  constructor(props: FishingMinigameProps) {
    super(props);

    const fishHeight = 50;
    const startingCompletion = 30;

    // Set things depending on difficulty
    const baitHeight = 170 + (150 - props.difficulty);

    this.completionLossPerSecond = props.special_rules.includes('limit_loss')
      ? -4
      : -6;
    this.baitBounceCoeff = props.special_rules.includes('weighted') ? 0.1 : 0.6;
    this.idleVelocity = props.special_rules.includes('heavy') ? 10 : 0;
    this.bidirectional = props.special_rules.includes('bidirectional');
    this.no_escape = props.special_rules.includes('no_escape');
    this.accel_up_coeff = props.special_rules.includes('lubed') ? 1.4 : 1;

    switch (props.fish_ai) {
      case 'dumb':
        // This is just using defaults
        break;
      case 'slow':
        // Only does long jump, and doesn't change direction until it gets there
        this.baseShortJumpChancePerSecond = 0;
        this.baseLongJumpChancePerSecond = 0.15;
        this.longJumpVelocityLimit = 150;
        this.interruptMove = false;
        break;
      case 'zippy':
        this.baseShortJumpChancePerSecond *= 3;
        break;
    }

    // Start at the bottom
    this.state = {
      completion: startingCompletion,
      bait: {
        position: this.area_height - baitHeight,
        height: baitHeight,
        velocity: this.idleVelocity,
      },
      fish: {
        position: this.area_height - fishHeight,
        height: fishHeight,
        velocity: this.idleVelocity,
        target: null,
      },
    };

    this.handle_mousedown = this.handle_mousedown.bind(this);
    this.handle_mouseup = this.handle_mouseup.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
    this.handle_ctrldown = this.handle_ctrldown.bind(this);
    this.handle_ctrlup = this.handle_ctrlup.bind(this);
    this.updateAnimation = this.updateAnimation.bind(this);
    this.moveFish = this.moveFish.bind(this);
    this.moveBait = this.moveBait.bind(this);
    this.updateCompletion = this.updateCompletion.bind(this);
  }

  componentDidMount() {
    // add binds blah blah
    document.addEventListener('mousedown', this.handle_mousedown);
    document.addEventListener('mouseup', this.handle_mouseup);
    this.animation_id = window.requestAnimationFrame(this.updateAnimation);
    globalEvents.on('byond/mousedown', this.handle_mousedown);
    globalEvents.on('byond/mouseup', this.handle_mouseup);
    globalEvents.on('byond/ctrldown', this.handle_ctrldown);
    globalEvents.on('byond/ctrlup', this.handle_ctrlup);
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this.handle_mousedown);
    document.removeEventListener('mouseup', this.handle_mouseup);
    window.cancelAnimationFrame(this.animation_id);
    globalEvents.off('byond/mousedown', this.handle_mousedown);
    globalEvents.off('byond/mouseup', this.handle_mouseup);
    globalEvents.off('byond/ctrldown', this.handle_ctrldown);
    globalEvents.off('byond/ctrlup', this.handle_ctrlup);
  }

  updateAnimation(timestamp: DOMHighResTimeStamp) {
    const last = this.last_frame === undefined ? timestamp : this.last_frame;
    const delta = timestamp - last;
    let newState: FishingMinigameState = { ...this.state };
    newState = this.moveFish(newState, delta, timestamp);
    newState = this.moveBait(newState, delta);
    newState = this.updateCompletion(newState, delta);
    this.setState(newState);
    // wait for next frame
    this.last_frame = timestamp;
    this.animation_id = window.requestAnimationFrame(this.updateAnimation);
  }

  moveFish(
    currentState: FishingMinigameState,
    delta: number,
    timestamp: DOMHighResTimeStamp
  ): FishingMinigameState {
    const seconds = delta / 1000;
    const { fish: currentFishState } = this.state;

    const longJumpChance =
      this.baseLongJumpChancePerSecond * this.props.difficulty * seconds * 100;

    const shortJumpChance =
      this.baseShortJumpChancePerSecond * this.props.difficulty * seconds * 100;

    const nextFishState = { ...currentFishState };

    // Switching to new long jump target can interrupt any other
    if (
      (this.interruptMove || currentFishState.target === null) &&
      randomProb(longJumpChance)
    ) {
      /*
       Move at least 0.75 to full of the availible bar in given direction,
       and more likely to move in the direction where there's more space
      */
      const distanceFromTop = 0 - currentFishState.position;
      const distanceFromBottom =
        this.area_height -
        (currentFishState.position + currentFishState.height);

      const absTop = Math.abs(distanceFromTop);
      const absBottom = Math.abs(distanceFromBottom);
      const topChance = (absTop / (absTop + absBottom)) * 100;

      const maxFishPosition = this.area_height - currentFishState.height;
      if (randomProb(topChance)) {
        // Moving to top
        const delta = Math.floor(distanceFromTop * randomNumber(0.75, 1));
      } else {
        // Moving to bottom
        const delta = Math.floor(distanceFromBottom * randomNumber(0.75, 1));
      }
      const newTarget = currentFishState.position + delta;
      nextFishState.target = clamp(newTarget, 0, maxFishPosition);
      this.currentVelocityLimit = this.longJumpVelocityLimit;
    }

    const activeTarget =
      currentFishState.target &&
      Math.abs(currentFishState.target - currentFishState.position) > 5;

    if (activeTarget) {
      // Move towards target
      const distance = currentFishState.target! - currentFishState.position;
      const friction = 0.9;
      // about 5 at diff 15 , 10 at diff 30, 30 at diff 100;
      const diffCoeff = 0.3 * this.props.difficulty + 0.5;
      const targetAcceleration = distance * diffCoeff * seconds;

      nextFishState.velocity =
        currentFishState.velocity * friction + targetAcceleration;
    } else {
      // If we have the target but we're close enough, mark as target reached
      if (
        currentFishState.target &&
        Math.abs(currentFishState.target - currentFishState.position) < 5
      ) {
        nextFishState.target = null;
      }
      // Try to do a short jump - these can't really be interrupted
      if (randomProb(shortJumpChance)) {
        const distanceFromTop = 0 - currentFishState.position;
        const distanceFromBottom =
          this.area_height -
          (currentFishState.position + currentFishState.height);
        let possibleMoves: number[] = [];
        if (Math.abs(distanceFromBottom) > 100) {
          possibleMoves.push(randomInteger(100, 200));
        }
        if (Math.abs(distanceFromTop) > 100) {
          possibleMoves.push(randomInteger(-200, -100));
        }
        const delta = randomPick(possibleMoves);
        const maxFishPosition = this.area_height - currentFishState.height;
        const rawTarget = currentFishState.position + delta;
        nextFishState.target = clamp(rawTarget, 0, maxFishPosition);
        this.currentVelocityLimit = this.shortJumpVelocityLimit;
      }
    }
    nextFishState.velocity = clamp(
      nextFishState.velocity + this.idleVelocity,
      -this.currentVelocityLimit,
      this.currentVelocityLimit
    );

    nextFishState.position =
      currentFishState.position + seconds * currentFishState.velocity;

    // Top bound
    if (nextFishState.position < 0) {
      nextFishState.position = 0;
    }
    // Bottom bound
    if (nextFishState.position + nextFishState.height > this.area_height) {
      nextFishState.position = this.area_height - nextFishState.height;
    }

    const newState: FishingMinigameState = {
      ...currentState,
      fish: nextFishState,
    };
    return newState;
  }

  moveBait(
    currentState: FishingMinigameState,
    delta: number
  ): FishingMinigameState {
    const seconds = delta / 1000;
    const { fish, bait } = this.state;

    // Speedup when reeling
    const acceleration_up = -1500 * this.accel_up_coeff;
    // Gravity
    const acceleration_down = 1000;
    // Velocity is multiplied by this when bouncing off the bottom/top
    const bounce_coeff = this.baitBounceCoeff;
    // Acceleration mod when bait is over fish
    const on_point_coeff = 0.6;

    let newPosition = bait.position + seconds * bait.velocity;
    let newVelocity = bait.velocity;

    // Top bound
    if (newPosition < 0) {
      newPosition = 0;
      if (this.reeling === ReelingState.Reeling) {
        newVelocity = 0;
      } else {
        newVelocity = -bait.velocity * bounce_coeff;
      }
    }
    // Bottom bound
    if (newPosition + bait.height > this.area_height) {
      newPosition = this.area_height - bait.height;
      if (this.reeling === ReelingState.ReelingDown) {
        newVelocity = 0;
      } else {
        newVelocity = -bait.velocity * bounce_coeff;
      }
    }

    const acceleration =
      this.reeling === ReelingState.Reeling
        ? acceleration_up
        : this.reeling === ReelingState.ReelingDown
          ? -acceleration_up
          : acceleration_down;
    // Slowdown both ways when on fish
    const velocity_change =
      acceleration *
      seconds *
      (this.fishOnBait(fish, bait) ? on_point_coeff : 1);

    if (this.bidirectional && this.reeling === ReelingState.Idle) {
      if (newVelocity < 0) {
        newVelocity = Math.min(newVelocity + velocity_change, 0);
      } else {
        newVelocity = Math.max(newVelocity - velocity_change, 0);
      }
    } else {
      newVelocity += velocity_change;
    }

    // Round it off and cap
    if (Math.abs(newVelocity) < 0.01) {
      newVelocity = 0;
    }

    const newState: FishingMinigameState = {
      ...currentState,
      bait: { ...bait, position: newPosition, velocity: newVelocity },
    };
    return newState;
  }

  updateCompletion(
    currentState: FishingMinigameState,
    delta: number
  ): FishingMinigameState {
    const seconds = delta / 1000;
    const completion_gain_per_second = 5;
    const completion_lost_per_second = this.completionLossPerSecond;

    const { fish, bait } = currentState;

    let completion_delta = 0;
    if (this.fishOnBait(fish, bait)) {
      completion_delta = seconds * completion_gain_per_second;
    } else {
      completion_delta = seconds * completion_lost_per_second;
    }
    const rawCompletion = currentState.completion + completion_delta;
    const newCompletion = clamp(rawCompletion, 0, 100);
    const newState: FishingMinigameState = {
      ...currentState,
      completion: newCompletion,
    };

    const dispatch = useDispatch(this.context);

    if (newCompletion <= 0 && !this.no_escape) {
      this.props.lose();
      dispatch(backendSuspendStart());
    } else if (newCompletion >= 100) {
      this.props.win();
      dispatch(backendSuspendStart());
    }

    return newState;
  }

  fishOnBait(fish: Fish, bait: Bait): boolean {
    const upperBoundCheck = fish.position >= bait.position;
    const fishLowerBound = fish.position + fish.height;
    const baitLowerBound = bait.position + bait.height;
    const lowerBoundCheck = fishLowerBound <= baitLowerBound;
    return lowerBoundCheck && upperBoundCheck;
  }

  handle_mousedown(event: MouseEvent) {
    if (this.reeling === ReelingState.Idle) {
      this.reeling = ReelingState.Reeling;
    }
  }

  handle_mouseup(event: MouseEvent) {
    if (this.reeling === ReelingState.Reeling) {
      this.reeling = ReelingState.Idle;
    }
  }

  handleKeyDown(keyEvent: KeyEvent) {
    if (keyEvent.code === KEY_CTRL) {
      this.handle_ctrldown();
    }
  }

  handleKeyUp(keyEvent: KeyEvent) {
    if (keyEvent.code === KEY_CTRL) {
      this.handle_ctrlup();
    }
  }

  handle_ctrldown() {
    if (this.bidirectional && this.reeling === ReelingState.Idle) {
      this.reeling = ReelingState.ReelingDown;
    }
  }

  handle_ctrlup() {
    if (this.bidirectional && this.reeling === ReelingState.ReelingDown) {
      this.reeling = ReelingState.Idle;
    }
  }

  render() {
    const { completion, fish, bait } = this.state;
    const posToStyle = (value: number) => (value / this.area_height) * 100;
    const background_image = resolveAsset(this.props.background);
    return (
      <div class="fishing">
        <KeyListener
          onKeyDown={this.handleKeyDown}
          onKeyUp={this.handleKeyUp}
        />
        <div class="main">
          <div
            class="background"
            style={{ 'background-image': `url("${background_image}")` }}>
            <div
              class="bait"
              style={{
                height: `${posToStyle(bait.height)}%`,
                top: `${posToStyle(bait.position)}%`,
              }}
            />
            <div
              class="fish"
              style={{
                top: `${posToStyle(fish.position)}%`,
                height: `${posToStyle(fish.height)}%`,
              }}>
              <Icon name="fish" />
            </div>
          </div>
        </div>
        <div class="completion">
          <div class="background">
            <div class="bar" style={{ height: `${Math.round(completion)}%` }} />
          </div>
        </div>
      </div>
    );
  }
}

type FishingData = {
  difficulty: number;
  fish_ai: FishAI;
  special_effects: SpecialRule[];
  background_image: string;
};

export const Fishing = (props, context) => {
  const { act, data } = useBackend<FishingData>(context);
  return (
    <Window width={180} height={600}>
      <Window.Content fitted>
        <FishingMinigame
          difficulty={data.difficulty}
          fish_ai={data.fish_ai}
          special_rules={data.special_effects}
          background={data.background_image}
          win={() => act('win')}
          lose={() => act('lose')}
        />
      </Window.Content>
    </Window>
  );
};
