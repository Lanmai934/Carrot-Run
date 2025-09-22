import { GameStateManager, GameStateType } from '../common/GameState';
import { GameDataManager } from '../common/GameData';
import { GameConfig } from '../common/GameConfig'
import { GameButton, GamePanel, GameIcon, ButtonStyle, ButtonSize } from '../common/UIComponents'
import { audioManager, AudioHelper } from '../game/AudioSystem';
import router from '@ohos.router';

@Entry
@Component
struct SettingsPage {
  @State musicEnabled: boolean = true;
  @State sfxEnabled: boolean = true;
  @State vibrationEnabled: boolean = true;
  @State showResetDialog: boolean = false;

  private gameStateManager: GameStateManager = GameStateManager.getInstance();
  private gameDataManager: GameDataManager = GameDataManager.getInstance();

  aboutToAppear() {
    this.loadSettings();
  }

  // 加载设置
  private loadSettings(): void {
    const gameData = this.gameDataManager.getGameData();
    this.musicEnabled = gameData.musicEnabled;
    this.sfxEnabled = gameData.sfxEnabled;
    this.vibrationEnabled = gameData.vibrationEnabled;
    
    // 同步到音效系统
    audioManager.setMusicEnabled(this.musicEnabled);
    audioManager.setSfxEnabled(this.sfxEnabled);
  }

  // 保存设置
  private saveSettings(): void {
    this.gameDataManager.updateSettings({
      musicEnabled: this.musicEnabled,
      sfxEnabled: this.sfxEnabled,
      vibrationEnabled: this.vibrationEnabled
    });
  }

  // 切换音乐设置
  private toggleMusic(): void {
    this.musicEnabled = !this.musicEnabled;
    this.saveSettings();
    // 同步到音效系统
    audioManager.setMusicEnabled(this.musicEnabled);
    // 播放按钮音效
    AudioHelper.playButtonClick();
  }

  // 切换音效设置
  private toggleSfx(): void {
    this.sfxEnabled = !this.sfxEnabled;
    this.saveSettings();
    // 同步到音效系统
    audioManager.setSfxEnabled(this.sfxEnabled);
    // 播放按钮音效（如果音效开启）
    if (this.sfxEnabled) {
      AudioHelper.playButtonClick();
    }
  }

  // 切换震动设置
  private toggleVibration(): void {
    this.vibrationEnabled = !this.vibrationEnabled;
    this.saveSettings();
    // 播放按钮音效
    AudioHelper.playButtonClick();
  }

  // 显示重置确认对话框
  private showResetConfirmation(): void {
    this.showResetDialog = true;
  }

  // 重置游戏数据
  private resetGameData(): void {
    // TODO: 实现重置游戏数据的逻辑
    // 这里需要清除所有保存的数据并重新初始化
    this.showResetDialog = false;
    
    // 显示重置成功提示
    // TODO: 添加提示组件
  }

  // 取消重置
  private cancelReset(): void {
    this.showResetDialog = false;
  }

  // 返回主菜单
  private backToMenu(): void {
    this.gameStateManager.changeState(GameStateType.MENU);
    router.back();
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          GameButton({
            text: '',
            icon: '←',
            style: ButtonStyle.TRANSPARENT,
            size: ButtonSize.SMALL,
            width: 50,
            height: 50,
            onClick: () => {
              AudioHelper.playButtonClick()
              this.backToMenu()
            }
          })

          Blank()

          Text('设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Blank()

          // 占位，保持标题居中
          Column()
            .width(50)
            .height(50)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })

        // 设置列表
        Scroll() {
          Column({ space: 0 }) {
            // 音频设置
            GamePanel({
              backgroundColor: 'rgba(255,255,255,0.1)',
              borderRadius: 15,
              padding: 20
            }) {
              Column({ space: 16 }) {
                Row() {
                  GameIcon({ icon: '🔊', size: 24 })
                  Text('音频设置')
                    .fontSize(18)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 12 })
                }
                .width('100%')
                
                // 背景音乐开关
                Row() {
                  Text('背景音乐')
                    .fontSize(16)
                    .fontColor(Color.White)
                  
                  Blank()
                  
                  Toggle({ type: ToggleType.Switch, isOn: this.musicEnabled })
                    .selectedColor(GameConfig.COLORS.PRIMARY)
                    .onChange((isOn: boolean) => {
                      this.toggleMusic()
                    })
                }
                .width('100%')
                
                // 音效开关
                Row() {
                  Text('音效')
                    .fontSize(16)
                    .fontColor(Color.White)
                  
                  Blank()
                  
                  Toggle({ type: ToggleType.Switch, isOn: this.sfxEnabled })
                    .selectedColor(GameConfig.COLORS.PRIMARY)
                    .onChange((isOn: boolean) => {
                      this.toggleSfx()
                    })
                }
                .width('100%')
              }
            }

            // 游戏设置
            GamePanel({
              backgroundColor: 'rgba(255,255,255,0.1)',
              borderRadius: 15,
              padding: 20
            }) {
              Column({ space: 16 }) {
                Row() {
                  GameIcon({ icon: '🎮', size: 24 })
                  Text('游戏设置')
                    .fontSize(18)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 12 })
                }
                .width('100%')
                
                // 震动反馈开关
                Row() {
                  Text('震动反馈')
                    .fontSize(16)
                    .fontColor(Color.White)
                  
                  Blank()
                  
                  Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
                    .selectedColor(GameConfig.COLORS.PRIMARY)
                    .onChange((isOn: boolean) => {
                      this.toggleVibration()
                    })
                }
                .width('100%')
              }
            }

            // 数据管理
            GamePanel({
              backgroundColor: 'rgba(255,255,255,0.1)',
              borderRadius: 15,
              padding: 20
            }) {
              Column({ space: 16 }) {
                Row() {
                  GameIcon({ icon: '🗂️', size: 24 })
                  Text('数据管理')
                    .fontSize(18)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 12 })
                }
                .width('100%')
                
                // 重置游戏数据按钮
                GameButton({
                  text: '重置游戏数据',
                  icon: '⚠️',
                  style: ButtonStyle.WARNING,
                  size: ButtonSize.MEDIUM,
                  width: '100%',
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.showResetConfirmation()
                  }
                })
              }
            }

            // 关于信息
            GamePanel({
              backgroundColor: 'rgba(255,255,255,0.1)',
              borderRadius: 15,
              padding: 20
            }) {
              Column({ space: 16 }) {
                Row() {
                  GameIcon({ icon: 'ℹ️', size: 24 })
                  Text('关于游戏')
                    .fontSize(18)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 12 })
                }
                .width('100%')
                
                // 游戏版本
                Row() {
                  Text('游戏版本')
                    .fontSize(16)
                    .fontColor(Color.White)
                  
                  Blank()
                  
                  Text('1.0.0')
                    .fontSize(16)
                    .fontColor('#CCCCCC')
                }
                .width('100%')
                
                // 游戏介绍
                Row() {
                  Column({ space: 4 }) {
                    Text('萝卜跑酷')
                      .fontSize(16)
                      .fontColor(Color.White)
                      .alignSelf(ItemAlign.Start)
                    
                    Text('一款可爱的休闲跑酷游戏')
                      .fontSize(14)
                      .fontColor('#CCCCCC')
                      .alignSelf(ItemAlign.Start)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  Text('🥕')
                    .fontSize(32)
                }
                .width('100%')
              }
            }
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GameConfig.COLORS.BACKGROUND)

      // 重置确认对话框
      if (this.showResetDialog) {
        Stack() {
          // 半透明背景
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.7)')
          
          // 对话框面板
          GamePanel({
            backgroundColor: 'rgba(255,255,255,0.95)',
            borderRadius: 20,
            padding: 30
          }) {
            Column() {
              // 警告图标
              GameIcon({ icon: '⚠️', size: 48 })
                .margin({ bottom: 20 })

              Text('重置游戏数据')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B6B')
                .margin({ bottom: 16 })

              Text('此操作将清除所有游戏进度、解锁的角色、金币和成就。此操作不可撤销！')
                .fontSize(16)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
                .lineHeight(24)
                .margin({ bottom: 30 })

              Row({ space: 16 }) {
                GameButton({
                  text: '取消',
                  style: ButtonStyle.SECONDARY,
                  size: ButtonSize.MEDIUM,
                  width: 100,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.cancelReset()
                  }
                })

                GameButton({
                  text: '确认重置',
                  style: ButtonStyle.WARNING,
                  size: ButtonSize.MEDIUM,
                  width: 120,
                  onClick: () => {
                    AudioHelper.playButtonClick()
                    this.resetGameData()
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
    }
  }

  // 设置分组组件
  @Builder SettingGroup(title: string, items: Array<{
    title: string,
    subtitle?: string,
    value?: boolean,
    isDestructive?: boolean,
    action: () => void
  }>) {
    Column() {
      // 分组标题
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 4, bottom: 8, top: 16 })

      // 设置项列表
      Column() {
        ForEach(items, (item, index) => {
          Column() {
            Row() {
              Column({ space: 2 }) {
                Text(item.title)
                  .fontSize(16)
                  .fontColor(item.isDestructive ? '#FF4444' : '#333333')
                  .alignSelf(ItemAlign.Start)

                if (item.subtitle) {
                  Text(item.subtitle)
                    .fontSize(12)
                    .fontColor('#888888')
                    .alignSelf(ItemAlign.Start)
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // 控件区域
              if (item.value !== undefined) {
                // 开关控件
                Toggle({ type: ToggleType.Switch, isOn: item.value })
                  .selectedColor(GameConfig.COLORS.PRIMARY)
                  .onChange((isOn: boolean) => {
                    item.action();
                  })
              } else if (!item.isDestructive) {
                // 箭头指示器
                Text('>')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              if (item.value === undefined) {
                item.action();
              }
            })

            // 分隔线
            if (index < items.length - 1) {
              Divider()
                .color('#EEEEEE')
                .margin({ left: 16, right: 16 })
            }
          }
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 1 })
    }
  }

  // 信息区域组件
  @Builder InfoSection() {
    Column() {
      Text('关于游戏')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 4, bottom: 8, top: 16 })

      Column() {
        Row() {
          Text('游戏版本')
            .fontSize(16)
            .fontColor('#333333')

          Blank()

          Text('1.0.0')
            .fontSize(16)
            .fontColor('#888888')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        Divider()
          .color('#EEEEEE')
          .margin({ left: 16, right: 16 })

        Row() {
          Column({ space: 2 }) {
            Text('萝卜跑酷')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Text('一款可爱的休闲跑酷游戏')
              .fontSize(12)
              .fontColor('#888888')
              .alignSelf(ItemAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text('🥕')
            .fontSize(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 1 })
    }
  }
}