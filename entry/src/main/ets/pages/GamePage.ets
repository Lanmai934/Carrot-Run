import { GameStateManager, GameStateType } from '../common/GameState';
import { GameDataManager } from '../common/GameData';
import { GameConfig } from '../common/GameConfig';
import { Character } from '../common/Character';
import { GameWorld } from '../common/GameWorld';
import { physicsEngine } from '../common/PhysicsEngine';
import { levelManager, MapTheme } from '../common/LevelSystem'
import { ItemType } from '../common/ItemSystem';
import { GameButton, GamePanel, GameIcon, ButtonStyle, ButtonSize } from '../common/UIComponents'
import { audioManager, AudioHelper, AudioType } from '../game/AudioSystem'
import router from '@ohos.router';

@Entry
@Component
struct GamePage {
  @State gameScore: number = 0;
  @State gameDistance: number = 0;
  @State gameCoins: number = 0;
  @State isPaused: boolean = false;
  @State gameOver: boolean = false;
  @State health: number = 3;
  
  private gameStateManager: GameStateManager = GameStateManager.getInstance();
  private gameDataManager: GameDataManager = GameDataManager.getInstance();
  private gameLoopTimer: number = -1;
  private canvasContext: CanvasRenderingContext2D | null = null;
  private character: Character | null = null;
  private gameWorld: GameWorld | null = null;
  private lastTime: number = 0;

  aboutToAppear() {
    this.gameStateManager.changeState(GameStateType.PLAYING);
    this.initGame();
    this.startGameLoop();
    // 开始背景音乐
    AudioHelper.startBackgroundMusic()
  }

  aboutToDisappear() {
    this.stopGameLoop();
    // 停止背景音乐
    AudioHelper.stopBackgroundMusic()
  }

  // 初始化游戏
  private initGame(): void {
    // 初始化关卡管理器
    levelManager.initialize()
    levelManager.loadLevel(1) // 加载第一关
    
    // 获取选中的角色
    const playerData = this.gameDataManager.getPlayerData();
    this.character = new Character(playerData.selectedCharacter);
    this.health = this.character.currentHealth;
    
    // 创建游戏世界
    this.gameWorld = new GameWorld(physicsEngine);
    this.gameWorld.setCharacter(this.character);
    
    this.lastTime = Date.now();
  }

  // 开始游戏循环
  private startGameLoop(): void {
    this.gameLoopTimer = setInterval(() => {
      if (!this.isPaused && !this.gameOver) {
        this.updateGame();
        this.renderGame();
      }
    }, 1000 / GameConfig.FPS);
  }

  // 停止游戏循环
  private stopGameLoop(): void {
    if (this.gameLoopTimer !== -1) {
      clearInterval(this.gameLoopTimer);
      this.gameLoopTimer = -1;
    }
  }

  // 更新游戏逻辑
  private updateGame(): void {
    const currentTime = Date.now();
    const deltaTime = (currentTime - this.lastTime) / 1000; // 转换为秒
    this.lastTime = currentTime;
    
    // 更新游戏世界
    if (this.gameWorld) {
      this.gameWorld.update(deltaTime);
      this.gameScore = this.gameWorld.getScore();
      this.gameDistance = this.gameWorld.getDistance();
      this.gameCoins = this.gameWorld.getCoins();
    }
    
    // 更新角色状态
    if (this.character) {
      this.health = this.character.currentHealth;
      
      // 检查游戏结束条件
      if (this.character.state === 'dead') {
        this.endGame();
      }
    }
  }

  // 渲染游戏画面
  private renderGame(): void {
    if (!this.canvasContext || !this.gameWorld) return;

    // 清空画布
    this.canvasContext.clearRect(0, 0, GameConfig.GAME_WIDTH, GameConfig.GAME_HEIGHT);
    
    // 渲染游戏世界
    this.gameWorld.render(this.canvasContext);
  }

  // 绘制背景
  private drawBackground(): void {
    if (!this.canvasContext) return;

    // 绘制天空
    this.canvasContext.fillStyle = GameConfig.COLORS.BACKGROUND;
    this.canvasContext.fillRect(0, 0, GameConfig.GAME_WIDTH, GameConfig.GROUND_LEVEL);
    
    // 绘制地面
    this.canvasContext.fillStyle = GameConfig.COLORS.GROUND;
    this.canvasContext.fillRect(0, GameConfig.GROUND_LEVEL, GameConfig.GAME_WIDTH, GameConfig.GAME_HEIGHT - GameConfig.GROUND_LEVEL);
  }

  // 暂停游戏
  private pauseGame(): void {
    this.isPaused = true;
    this.gameStateManager.changeState(GameStateType.PAUSED);
    // 暂停所有音效
    audioManager.pauseAll();
  }

  // 继续游戏
  private resumeGame(): void {
    this.isPaused = false;
    this.gameStateManager.changeState(GameStateType.PLAYING);
    // 恢复所有音效
    audioManager.resumeAll();
  }

  // 游戏结束
  private endGame(): void {
    this.gameOver = true;
    this.stopGameLoop();
    this.gameStateManager.changeState(GameStateType.GAME_OVER);
    // 播放游戏结束音效
    AudioHelper.playGameOver();
    
    // 保存游戏数据
    this.gameDataManager.updateHighScore(this.gameScore);
    this.gameDataManager.addDistance(this.gameDistance);
    this.gameDataManager.addCoins(this.gameCoins);
    this.gameDataManager.incrementGamesPlayed();
  }

  // 返回主菜单
  private backToMenu(): void {
    this.gameStateManager.changeState(GameStateType.MENU);
    router.back();
  }

  // 重新开始游戏
  private restartGame(): void {
    this.gameScore = 0;
    this.gameDistance = 0;
    this.gameCoins = 0;
    this.gameOver = false;
    this.isPaused = false;
    this.health = 3;
    this.gameStateManager.changeState(GameStateType.PLAYING);
    this.initGame();
    this.startGameLoop();
  }

  // 道具效果图标组件
  @Builder EffectIcon(effectType: ItemType) {
    Stack() {
      // 背景圆圈
      Circle({ width: 40, height: 40 })
        .fill(this.getEffectColor(effectType))
        .opacity(0.8)
      
      // 效果图标
      Text(this.getEffectSymbol(effectType))
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
      
      // 剩余时间显示
      if (this.character) {
        const remainingTime = this.character.getEffectRemainingTime(effectType)
        if (remainingTime > 0) {
          Text(`${Math.ceil(remainingTime / 1000)}`)
            .fontSize(10)
            .fontColor(Color.White)
            .position({ x: 25, y: -5 })
            .backgroundColor(Color.Red)
            .borderRadius(8)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        }
      }
    }
    .margin({ right: 8 })
  }
  
  private getEffectColor(effectType: ItemType): string {
    switch (effectType) {
      case ItemType.SPEED_BOOST: return '#FF4500'
      case ItemType.SHIELD: return '#4169E1'
      case ItemType.MAGNET: return '#DC143C'
      case ItemType.JUMP_BOOST: return '#32CD32'
      case ItemType.DOUBLE_SCORE: return '#9932CC'
      case ItemType.INVINCIBLE: return '#FFD700'
      case ItemType.SLOW_TIME: return '#00CED1'
      default: return '#808080'
    }
  }
  
  private getEffectSymbol(effectType: ItemType): string {
    switch (effectType) {
      case ItemType.SPEED_BOOST: return '⚡'
      case ItemType.SHIELD: return '🛡'
      case ItemType.MAGNET: return '🧲'
      case ItemType.JUMP_BOOST: return '↑'
      case ItemType.DOUBLE_SCORE: return '×2'
      case ItemType.INVINCIBLE: return '★'
      case ItemType.SLOW_TIME: return '⏰'
      default: return '?'
    }
  }

  build() {
    Stack() {
      // 游戏画布
      Canvas(this.canvasContext)
        .width(GameConfig.GAME_WIDTH)
        .height(GameConfig.GAME_HEIGHT)
        .backgroundColor(GameConfig.COLORS.BACKGROUND)
        .onReady(() => {
          // Canvas准备就绪后获取绘图上下文
          // this.canvasContext = context; // 需要在实际使用时获取正确的context
        })
        .gesture(
          // 添加手势识别用于跳跃和滑行
          TapGesture()
            .onAction(() => {
              if (!this.isPaused && !this.gameOver && this.character) {
                this.character.jump();
                // 播放跳跃音效
                AudioHelper.playJump()
              }
            })
        )

      // 游戏UI覆盖层
      Column() {
        // 顶部信息栏
        GamePanel({
          backgroundColor: 'rgba(0,0,0,0.3)',
          borderRadius: 20,
          padding: 12
        }) {
          Row() {
            // 关卡显示
            Row() {
              GameIcon({ icon: '🎯', size: 18 })
              Text(`${levelManager.getCurrentLevelId()}`)
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ left: 4 })
            }
            
            Blank()
            
            // 分数显示
            Row() {
              GameIcon({ icon: '🏆', size: 20 })
              Text(`${this.gameScore}`)
                .fontSize(18)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ left: 6 })
            }
            
            Blank()
            
            // 金币显示
            Row() {
              GameIcon({ icon: '💰', size: 18 })
              Text(`${this.gameCoins}`)
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ left: 4 })
            }
            
            Blank()
            
            // 生命值显示
            Row() {
              GameIcon({ icon: '❤️', size: 18 })
              Text(`${this.health}`)
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ left: 4 })
            }
            
            Blank()
            
            // 暂停按钮
            GameButton({
              text: '',
              icon: '⏸️',
              style: ButtonStyle.TRANSPARENT,
              size: ButtonSize.SMALL,
              width: 40,
              height: 40,
              backgroundColor: 'rgba(0,0,0,0.5)',
              onClick: () => {
                AudioHelper.playButtonClick()
                this.pauseGame()
              }
            })
          }
          .width('100%')
        }
        .width('90%')
        .margin({ top: 10 })
        .alignSelf(ItemAlign.Center)

        Blank()

        // 距离显示
        Text(`${Math.floor(this.gameDistance)}m`)
          .fontSize(20)
          .fontColor(GameConfig.COLORS.TEXT)
          .backgroundColor('rgba(0,0,0,0.5)')
          .padding(12)
          .borderRadius(12)
          .margin({ bottom: 20 })
          
        // 道具效果显示区域
        Row() {
          ForEach(this.character?.getActiveEffects() || [], (effectType: ItemType) => {
            this.EffectIcon(effectType)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 20, top: 5 })
      }
      .width('100%')
      .height('100%')

      // 暂停菜单
      if (this.isPaused && !this.gameOver) {
        Stack() {
          // 半透明背景
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.7)')
          
          // 暂停菜单面板
          GamePanel({
            backgroundColor: 'rgba(255,255,255,0.95)',
            borderRadius: 20,
            padding: 30
          }) {
            Column() {
              // 标题
              Text('游戏暂停')
                .fontSize(32)
                .fontColor(GameConfig.COLORS.PRIMARY)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 30 })
              
              // 当前游戏状态
              Row() {
                Column() {
                  Text('分数')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(`${this.gameScore}`)
                    .fontSize(20)
                    .fontColor(GameConfig.COLORS.PRIMARY)
                    .fontWeight(FontWeight.Bold)
                }
                .margin({ right: 30 })
                
                Column() {
                  Text('金币')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(`${this.gameCoins}`)
                    .fontSize(20)
                    .fontColor('#FFA500')
                    .fontWeight(FontWeight.Bold)
                }
                .margin({ right: 30 })
                
                Column() {
                  Text('关卡')
                    .fontSize(14)
                    .fontColor('#666')
                  Text(`${levelManager.getCurrentLevelId()}`)
                    .fontSize(20)
                    .fontColor('#FF6B6B')
                    .fontWeight(FontWeight.Bold)
                }
              }
              .margin({ bottom: 30 })
              
              // 按钮组
              Column({ space: 16 }) {
                GameButton({
                  text: '继续游戏',
                  icon: '▶️',
                  style: ButtonStyle.PRIMARY,
                  size: ButtonSize.LARGE,
                  width: 220,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.resumeGame()
                  }
                })
                
                GameButton({
                  text: '重新开始',
                  icon: '🔄',
                  style: ButtonStyle.SECONDARY,
                  size: ButtonSize.MEDIUM,
                  width: 200,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.restartGame()
                  }
                })
                
                GameButton({
                  text: '返回主菜单',
                  icon: '🏠',
                  style: ButtonStyle.TRANSPARENT,
                  size: ButtonSize.MEDIUM,
                  width: 200,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.backToMenu()
                  }
                })
              }
            }
          }
          .width(300)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 游戏结束菜单
      if (this.gameOver) {
        Stack() {
          // 半透明背景
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.8)')
          
          // 游戏结束面板
          GamePanel({
            backgroundColor: 'rgba(255,255,255,0.95)',
            borderRadius: 20,
            padding: 30
          }) {
            Column() {
              // 标题
              Text('游戏结束')
                .fontSize(32)
                .fontColor('#FF6B6B')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 20 })
              
              // 游戏结果统计
              Column({ space: 12 }) {
                Row() {
                  GameIcon({ icon: '🏆', size: 24 })
                  Text('最终分数')
                    .fontSize(16)
                    .fontColor('#666')
                    .margin({ left: 8, right: 20 })
                  Text(`${this.gameScore}`)
                    .fontSize(20)
                    .fontColor(GameConfig.COLORS.PRIMARY)
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                
                Row() {
                  GameIcon({ icon: '💰', size: 24 })
                  Text('收集金币')
                    .fontSize(16)
                    .fontColor('#666')
                    .margin({ left: 8, right: 20 })
                  Text(`${this.gameCoins}`)
                    .fontSize(20)
                    .fontColor('#FFA500')
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                
                Row() {
                  GameIcon({ icon: '🎯', size: 24 })
                  Text('到达关卡')
                    .fontSize(16)
                    .fontColor('#666')
                    .margin({ left: 8, right: 20 })
                  Text(`${levelManager.getCurrentLevelId()}`)
                    .fontSize(20)
                    .fontColor('#FF6B6B')
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(20)
              .backgroundColor('rgba(0,0,0,0.05)')
              .borderRadius(12)
              .margin({ bottom: 30 })
              
              // 按钮组
              Column({ space: 16 }) {
                GameButton({
                  text: '重新开始',
                  icon: '🔄',
                  style: ButtonStyle.PRIMARY,
                  size: ButtonSize.LARGE,
                  width: 220,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.restartGame()
                  }
                })
                
                GameButton({
                  text: '返回主菜单',
                  icon: '🏠',
                  style: ButtonStyle.SECONDARY,
                  size: ButtonSize.MEDIUM,
                  width: 200,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.backToMenu()
                  }
                })
              }
            }
          }
          .width(320)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}