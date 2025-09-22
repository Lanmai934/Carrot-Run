import { GameStateManager, GameStateType } from '../common/GameState';
import { GameDataManager } from '../common/GameData';
import { GameConfig } from '../common/GameConfig';
import { CHARACTER_CONFIGS, CharacterAttributes } from '../game/Character';
import { AudioHelper } from '../game/AudioSystem';
import router from '@ohos.router';

@Entry
@Component
struct CharacterSelectPage {
  @State selectedCharacterId: string = 'SPEED_CARROT';
  @State playerCoins: number = 0;
  @State unlockedCharacters: string[] = [];
  @State showUnlockDialog: boolean = false;
  @State unlockingCharacter: CharacterAttributes | null = null;

  private gameStateManager: GameStateManager = GameStateManager.getInstance();
  private gameDataManager: GameDataManager = GameDataManager.getInstance();

  aboutToAppear() {
    this.loadPlayerData();
  }

  // 加载玩家数据
  private loadPlayerData(): void {
    const gameData = this.gameDataManager.getGameData();
    this.playerCoins = gameData.totalCoins;
    this.unlockedCharacters = gameData.unlockedCharacters;
    this.selectedCharacterId = gameData.selectedCharacter;
  }

  // 选择角色
  private selectCharacter(characterId: string): void {
    if (this.unlockedCharacters.includes(characterId)) {
      // 播放按钮点击音效
      AudioHelper.playButtonClick();
      this.selectedCharacterId = characterId;
      this.gameDataManager.selectCharacter(characterId);
    }
  }

  // 尝试解锁角色
  private tryUnlockCharacter(character: CharacterAttributes): void {
    if (this.unlockedCharacters.includes(character.id)) {
      return; // 已解锁
    }

    // 播放按钮点击音效
    AudioHelper.playButtonClick();
    
    if (this.playerCoins >= character.unlockCost) {
      this.unlockingCharacter = character;
      this.showUnlockDialog = true;
    } else {
      // 金币不足提示
      // TODO: 显示金币不足的提示
    }
  }

  // 确认解锁角色
  private confirmUnlock(): void {
    // 播放按钮点击音效
    AudioHelper.playButtonClick();
    
    if (this.unlockingCharacter && this.playerCoins >= this.unlockingCharacter.unlockCost) {
      // 扣除金币
      this.gameDataManager.addCoins(-this.unlockingCharacter.unlockCost);
      
      // 解锁角色
      this.gameDataManager.unlockCharacter(this.unlockingCharacter.id);
      
      // 更新本地状态
      this.unlockedCharacters.push(this.unlockingCharacter.id);
      this.playerCoins -= this.unlockingCharacter.unlockCost;
      
      // 自动选择新解锁的角色
      this.selectCharacter(this.unlockingCharacter.id);
    }
    
    this.showUnlockDialog = false;
    this.unlockingCharacter = null;
  }

  // 取消解锁
  private cancelUnlock(): void {
    // 播放按钮点击音效
    AudioHelper.playButtonClick();
    this.showUnlockDialog = false;
    this.unlockingCharacter = null;
  }

  // 返回主菜单
  private backToMenu(): void {
    // 播放按钮点击音效
    AudioHelper.playButtonClick();
    this.gameStateManager.changeState(GameStateType.MENU);
    router.back();
  }

  // 获取角色状态文本
  private getCharacterStatusText(character: CharacterAttributes): string {
    if (this.unlockedCharacters.includes(character.id)) {
      return character.id === this.selectedCharacterId ? '已选择' : '已解锁';
    } else {
      return `解锁需要 ${character.unlockCost} 金币`;
    }
  }

  // 获取角色状态颜色
  private getCharacterStatusColor(character: CharacterAttributes): string {
    if (this.unlockedCharacters.includes(character.id)) {
      return character.id === this.selectedCharacterId ? GameConfig.COLORS.PRIMARY : GameConfig.COLORS.SECONDARY;
    } else {
      return this.playerCoins >= character.unlockCost ? '#4CAF50' : '#999999';
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        Row() {
          Button('← 返回')
            .backgroundColor('transparent')
            .fontColor(GameConfig.COLORS.TEXT)
            .onClick(() => this.backToMenu())

          Blank()

          Text('角色选择')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(GameConfig.COLORS.TEXT)

          Blank()

          Text(`💰 ${this.playerCoins}`)
            .fontSize(18)
            .fontColor(GameConfig.COLORS.TEXT)
            .backgroundColor('rgba(0,0,0,0.3)')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(15)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })

        // 角色列表
        Scroll() {
          Column({ space: 16 }) {
            ForEach(Object.values(CHARACTER_CONFIGS), (character: CharacterAttributes) => {
              this.CharacterCard(character)
            })
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)

        // 底部确认按钮
        Button('确认选择')
          .width('80%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(GameConfig.COLORS.PRIMARY)
          .borderRadius(25)
          .margin({ bottom: 30 })
          .onClick(() => this.backToMenu())
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GameConfig.COLORS.BACKGROUND)

      // 解锁确认对话框
      if (this.showUnlockDialog && this.unlockingCharacter) {
        Column() {
          Column() {
            Text('解锁角色')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            Text(`${this.unlockingCharacter.emoji}`)
              .fontSize(60)
              .margin({ bottom: 12 })

            Text(this.unlockingCharacter.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })

            Text(this.unlockingCharacter.description)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })

            Text(`需要 ${this.unlockingCharacter.unlockCost} 金币`)
              .fontSize(16)
              .fontColor(GameConfig.COLORS.PRIMARY)
              .margin({ bottom: 20 })

            Row({ space: 12 }) {
              Button('取消')
                .width(80)
                .height(40)
                .backgroundColor('#999999')
                .onClick(() => this.cancelUnlock())

              Button('确认解锁')
                .width(100)
                .height(40)
                .backgroundColor(GameConfig.COLORS.PRIMARY)
                .onClick(() => this.confirmUnlock())
            }
          }
          .backgroundColor('#FFFFFF')
          .padding(24)
          .borderRadius(12)
          .width('80%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
  }

  // 角色卡片组件
  @Builder CharacterCard(character: CharacterAttributes) {
    Column() {
      Row() {
        // 角色图标
        Column() {
          Text(character.emoji)
            .fontSize(50)
            .margin({ bottom: 8 })
        }
        .width(80)
        .alignItems(HorizontalAlign.Center)

        // 角色信息
        Column({ space: 4 }) {
          Text(character.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(character.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 属性显示
          Row({ space: 12 }) {
            Text(`速度: ${(character.speedMultiplier * 100).toFixed(0)}%`)
              .fontSize(12)
              .fontColor('#888888')

            Text(`跳跃: ${(character.jumpMultiplier * 100).toFixed(0)}%`)
              .fontSize(12)
              .fontColor('#888888')
          }
          .margin({ top: 4 })

          // 特殊技能
          Text(`特技: ${this.getSkillName(character.specialSkill)}`)
            .fontSize(12)
            .fontColor(GameConfig.COLORS.PRIMARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 状态按钮
        Column() {
          if (this.unlockedCharacters.includes(character.id)) {
            if (character.id === this.selectedCharacterId) {
              Text('✓ 已选择')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor(GameConfig.COLORS.PRIMARY)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(12)
            } else {
              Button('选择')
                .width(60)
                .height(32)
                .fontSize(14)
                .backgroundColor(GameConfig.COLORS.SECONDARY)
                .onClick(() => this.selectCharacter(character.id))
            }
          } else {
            Button('解锁')
              .width(60)
              .height(32)
              .fontSize(14)
              .backgroundColor(this.playerCoins >= character.unlockCost ? '#4CAF50' : '#999999')
              .enabled(this.playerCoins >= character.unlockCost)
              .onClick(() => this.tryUnlockCharacter(character))
          }
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
  }

  // 获取技能名称
  private getSkillName(skill: string): string {
    switch (skill) {
      case 'speed_boost': return '速度冲刺';
      case 'double_jump': return '二段跳';
      case 'shield': return '护盾';
      case 'coin_magnet': return '吸铁石';
      default: return '未知技能';
    }
  }
}