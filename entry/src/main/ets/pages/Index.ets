import { GameStateManager, GameStateType } from '../common/GameState';
import { GameDataManager } from '../common/GameData';
import { GameConfig } from '../common/GameConfig'
import { GameButton, GamePanel, GameStatCard, ButtonStyle, ButtonSize } from '../common/UIComponents'
import { AudioHelper } from '../game/AudioSystem'
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State gameTitle: string = '萝卜跑酷';
  @State playerCoins: number = 0;
  @State highScore: number = 0;
  private gameStateManager: GameStateManager = GameStateManager.getInstance();
  private gameDataManager: GameDataManager = GameDataManager.getInstance();

  aboutToAppear() {
    // 初始化游戏数据
    this.loadPlayerData();
  }

  // 加载玩家数据
  private loadPlayerData(): void {
    const gameData = this.gameDataManager.getGameData();
    this.playerCoins = gameData.totalCoins;
    this.highScore = gameData.highScore;
  }

  // 开始游戏
  private startGame(): void {
    this.gameStateManager.changeState(GameStateType.PLAYING);
    router.pushUrl({
      url: 'pages/GamePage'
    });
  }

  // 角色选择
  private selectCharacter(): void {
    this.gameStateManager.changeState(GameStateType.CHARACTER_SELECT);
    router.pushUrl({
      url: 'pages/CharacterSelectPage'
    });
  }

  // 设置页面
  private openSettings(): void {
    this.gameStateManager.changeState(GameStateType.SETTINGS);
    router.pushUrl({
      url: 'pages/SettingsPage'
    });
  }

  private openShop() {
    // TODO: 实现商店页面
    console.log('打开商店页面')
  }

  private openDailyTasks() {
    // TODO: 实现每日任务页面
    console.log('打开每日任务页面')
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(GameConfig.COLORS.BACKGROUND)
      
      // 主要内容
      Column() {
        // 标题区域
        Column() {
          Text('萝卜跑酷')
            .fontSize(48)
            .fontColor(GameConfig.COLORS.PRIMARY)
            .fontWeight(FontWeight.Bold)
            .textShadow({
              radius: 8,
              color: GameConfig.COLORS.PRIMARY + '40',
              offsetX: 0,
              offsetY: 4
            })
            .margin({ bottom: 10 })
          
          // 萝卜图标
          Text('🥕')
            .fontSize(64)
            .margin({ bottom: 20 })
            .animation({
              duration: 2000,
              curve: Curve.EaseInOut,
              iterations: -1,
              playMode: PlayMode.Alternate
            })
        }
        .margin({ top: 60, bottom: 30 })
        
        // 玩家统计信息
        Row() {
          GameStatCard({
            title: '等级',
            value: this.playerData.level,
            icon: '⭐',
            color: '#FFD700'
          })
          
          GameStatCard({
            title: '金币',
            value: this.playerData.coins,
            icon: '💰',
            color: '#FFA500'
          })
          .margin({ left: 12, right: 12 })
          
          GameStatCard({
            title: '最高分',
            value: this.playerData.highScore,
            icon: '🏆',
            color: '#FF6B6B'
          })
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 40 })
        
        // 按钮组
        Column() {
          GameButton({
            text: '开始游戏',
            icon: '🎮',
            style: ButtonStyle.PRIMARY,
            size: ButtonSize.LARGE,
            width: 220,
            onClick: () => {
              AudioHelper.playButtonClick()
              this.startGame()
            }
          })
          .margin({ bottom: 16 })
          
          GameButton({
            text: '角色选择',
            icon: '🥕',
            style: ButtonStyle.SECONDARY,
            size: ButtonSize.MEDIUM,
            width: 200,
            onClick: () => {
              AudioHelper.playButtonClick()
              this.selectCharacter()
            }
          })
          .margin({ bottom: 16 })
          
          Row() {
            GameButton({
              text: '设置',
              icon: '⚙️',
              style: ButtonStyle.TRANSPARENT,
              size: ButtonSize.MEDIUM,
              width: 95,
              onClick: () => {
                AudioHelper.playButtonClick()
                this.openSettings()
              }
            })
            .margin({ right: 10 })
            
            GameButton({
              text: '商店',
              icon: '🛒',
              style: ButtonStyle.TRANSPARENT,
              size: ButtonSize.MEDIUM,
              width: 95,
              onClick: () => {
                AudioHelper.playButtonClick()
                this.openShop()
              }
            })
          }
          .margin({ bottom: 16 })
        }
        .margin({ bottom: 30 })
        
        // 每日任务提示
        if (this.playerData.dailyTasks.length > 0) {
          GameButton({
            text: '每日任务',
            icon: '📋',
            style: ButtonStyle.WARNING,
            size: ButtonSize.SMALL,
            width: 120,
            onClick: () => {
              AudioHelper.playButtonClick()
              this.openDailyTasks()
            }
          })
          .margin({ bottom: 20 })
        }
        
        // 版本信息
        Text('版本 1.0.0')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.6)')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}