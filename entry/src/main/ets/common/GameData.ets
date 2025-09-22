import { preferences } from '@kit.ArkData';

// 游戏数据接口
export interface GameData {
  // 玩家基础信息
  playerName: string;
  totalCoins: number;
  highScore: number;
  totalDistance: number;
  gamesPlayed: number;

  // 角色解锁状态
  unlockedCharacters: string[];
  selectedCharacter: string;

  // 关卡进度
  unlockedLevels: string[];
  levelProgress: Map<string, number>;

  // 成就系统
  achievements: string[];
  dailyTasks: DailyTask[];
  lastLoginDate: string;

  // 设置
  musicEnabled: boolean;
  sfxEnabled: boolean;
  vibrationEnabled: boolean;
}

// 每日任务接口
export interface DailyTask {
  id: string;
  name: string;
  description: string;
  target: number;
  current: number;
  reward: number;
  completed: boolean;
}

// 游戏数据管理器
export class GameDataManager {
  private static instance: GameDataManager;
  private gameData: GameData;
  private preferencesHelper: preferences.Preferences | null = null;

  private constructor() {
    this.gameData = this.getDefaultGameData();
    this.initPreferences();
  }

  public static getInstance(): GameDataManager {
    if (!GameDataManager.instance) {
      GameDataManager.instance = new GameDataManager();
    }
    return GameDataManager.instance;
  }

  // 初始化偏好设置
  private async initPreferences(): Promise<void> {
    try {
      this.preferencesHelper = await preferences.getPreferences(globalThis.abilityContext, 'carrot_run_data');
      await this.loadGameData();
    } catch (error) {
      console.error('初始化偏好设置失败:', error);
    }
  }

  // 获取默认游戏数据
  private getDefaultGameData(): GameData {
    return {
      playerName: '萝卜玩家',
      totalCoins: 0,
      highScore: 0,
      totalDistance: 0,
      gamesPlayed: 0,
      unlockedCharacters: ['SPEED_CARROT'], // 默认解锁速度萝卜
      selectedCharacter: 'SPEED_CARROT',
      unlockedLevels: ['FOREST'], // 默认解锁森林关卡
      levelProgress: new Map(),
      achievements: [],
      dailyTasks: this.generateDailyTasks(),
      lastLoginDate: new Date().toDateString(),
      musicEnabled: true,
      sfxEnabled: true,
      vibrationEnabled: true
    };
  }

  // 生成每日任务
  private generateDailyTasks(): DailyTask[] {
    return [
      {
        id: 'daily_run',
        name: '每日跑步',
        description: '完成3次游戏',
        target: 3,
        current: 0,
        reward: 50,
        completed: false
      },
      {
        id: 'collect_coins',
        name: '收集金币',
        description: '收集100个金币',
        target: 100,
        current: 0,
        reward: 30,
        completed: false
      },
      {
        id: 'distance_challenge',
        name: '距离挑战',
        description: '单次跑步达到1000米',
        target: 1000,
        current: 0,
        reward: 80,
        completed: false
      }
    ];
  }

  // 加载游戏数据
  public async loadGameData(): Promise<void> {
    if (!this.preferencesHelper) return;

    try {
      const savedData = await this.preferencesHelper.get('gameData', '');
      if (savedData) {
        const parsedData = JSON.parse(savedData as string);
        this.gameData = { ...this.gameData, ...parsedData };
        
        // 检查是否需要重置每日任务
        this.checkDailyTasksReset();
      }
    } catch (error) {
      console.error('加载游戏数据失败:', error);
    }
  }

  // 保存游戏数据
  public async saveGameData(): Promise<void> {
    if (!this.preferencesHelper) return;

    try {
      await this.preferencesHelper.put('gameData', JSON.stringify(this.gameData));
      await this.preferencesHelper.flush();
    } catch (error) {
      console.error('保存游戏数据失败:', error);
    }
  }

  // 检查每日任务重置
  private checkDailyTasksReset(): void {
    const today = new Date().toDateString();
    if (this.gameData.lastLoginDate !== today) {
      this.gameData.dailyTasks = this.generateDailyTasks();
      this.gameData.lastLoginDate = today;
    }
  }

  // 获取游戏数据
  public getGameData(): GameData {
    return this.gameData;
  }

  // 更新金币
  public addCoins(amount: number): void {
    this.gameData.totalCoins += amount;
    this.updateDailyTask('collect_coins', amount);
    this.saveGameData();
  }

  // 更新最高分
  public updateHighScore(score: number): void {
    if (score > this.gameData.highScore) {
      this.gameData.highScore = score;
      this.saveGameData();
    }
  }

  // 更新总距离
  public addDistance(distance: number): void {
    this.gameData.totalDistance += distance;
    this.updateDailyTask('distance_challenge', distance);
    this.saveGameData();
  }

  // 增加游戏次数
  public incrementGamesPlayed(): void {
    this.gameData.gamesPlayed++;
    this.updateDailyTask('daily_run', 1);
    this.saveGameData();
  }

  // 解锁角色
  public unlockCharacter(characterId: string): void {
    if (!this.gameData.unlockedCharacters.includes(characterId)) {
      this.gameData.unlockedCharacters.push(characterId);
      this.saveGameData();
    }
  }

  // 选择角色
  public selectCharacter(characterId: string): void {
    if (this.gameData.unlockedCharacters.includes(characterId)) {
      this.gameData.selectedCharacter = characterId;
      this.saveGameData();
    }
  }

  // 解锁关卡
  public unlockLevel(levelId: string): void {
    if (!this.gameData.unlockedLevels.includes(levelId)) {
      this.gameData.unlockedLevels.push(levelId);
      this.saveGameData();
    }
  }

  // 更新每日任务进度
  private updateDailyTask(taskId: string, progress: number): void {
    const task = this.gameData.dailyTasks.find(t => t.id === taskId);
    if (task && !task.completed) {
      task.current = Math.min(task.current + progress, task.target);
      if (task.current >= task.target) {
        task.completed = true;
        this.addCoins(task.reward);
      }
    }
  }

  // 解锁成就
  public unlockAchievement(achievementId: string): void {
    if (!this.gameData.achievements.includes(achievementId)) {
      this.gameData.achievements.push(achievementId);
      this.saveGameData();
    }
  }

  // 更新设置
  public updateSettings(settings: Partial<Pick<GameData, 'musicEnabled' | 'sfxEnabled' | 'vibrationEnabled'>>): void {
    Object.assign(this.gameData, settings);
    this.saveGameData();
  }
}