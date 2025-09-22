// 游戏状态枚举
export enum GameStateType {
  MENU = 'menu',
  PLAYING = 'playing',
  PAUSED = 'paused',
  GAME_OVER = 'game_over',
  LEVEL_COMPLETE = 'level_complete',
  SETTINGS = 'settings',
  CHARACTER_SELECT = 'character_select'
}

// 游戏状态管理器
export class GameStateManager {
  private static instance: GameStateManager;
  private currentState: GameStateType = GameStateType.MENU;
  private previousState: GameStateType = GameStateType.MENU;
  private stateChangeCallbacks: Map<GameStateType, Function[]> = new Map();

  private constructor() {
    // 初始化状态回调映射
    Object.values(GameStateType).forEach(state => {
      this.stateChangeCallbacks.set(state, []);
    });
  }

  public static getInstance(): GameStateManager {
    if (!GameStateManager.instance) {
      GameStateManager.instance = new GameStateManager();
    }
    return GameStateManager.instance;
  }

  // 切换游戏状态
  public changeState(newState: GameStateType): void {
    if (this.currentState === newState) {
      return;
    }

    this.previousState = this.currentState;
    this.currentState = newState;

    // 触发状态变化回调
    const callbacks = this.stateChangeCallbacks.get(newState) || [];
    callbacks.forEach(callback => callback());
  }

  // 获取当前状态
  public getCurrentState(): GameStateType {
    return this.currentState;
  }

  // 获取上一个状态
  public getPreviousState(): GameStateType {
    return this.previousState;
  }

  // 注册状态变化回调
  public onStateChange(state: GameStateType, callback: Function): void {
    const callbacks = this.stateChangeCallbacks.get(state) || [];
    callbacks.push(callback);
    this.stateChangeCallbacks.set(state, callbacks);
  }

  // 移除状态变化回调
  public removeStateChangeCallback(state: GameStateType, callback: Function): void {
    const callbacks = this.stateChangeCallbacks.get(state) || [];
    const index = callbacks.indexOf(callback);
    if (index > -1) {
      callbacks.splice(index, 1);
    }
  }

  // 返回上一个状态
  public goToPreviousState(): void {
    this.changeState(this.previousState);
  }
}