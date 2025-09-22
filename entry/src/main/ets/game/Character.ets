import { GameConfig } from '../common/GameConfig';

// 角色状态枚举
export enum CharacterState {
  RUNNING = 'running',
  JUMPING = 'jumping',
  SLIDING = 'sliding',
  FALLING = 'falling',
  DEAD = 'dead'
}

// 角色技能枚举
export enum CharacterSkill {
  SPEED_BOOST = 'speed_boost',
  DOUBLE_JUMP = 'double_jump',
  SHIELD = 'shield',
  COIN_MAGNET = 'coin_magnet'
}

// 角色属性接口
export interface CharacterAttributes {
  id: string;
  name: string;
  emoji: string;
  speedMultiplier: number;
  jumpMultiplier: number;
  specialSkill: CharacterSkill;
  unlockCost: number;
  description: string;
}

// 萝卜角色类
export class CarrotCharacter {
  // 基础属性
  public x: number;
  public y: number;
  public width: number;
  public height: number;
  public velocityX: number;
  public velocityY: number;
  
  // 角色状态
  public state: CharacterState;
  public isOnGround: boolean;
  public canDoubleJump: boolean;
  public hasUsedDoubleJump: boolean;
  
  // 角色属性
  public attributes: CharacterAttributes;
  
  // 技能状态
  public activeSkills: Map<CharacterSkill, number>; // 技能ID -> 剩余时间
  public isInvincible: boolean;
  public invincibilityTime: number;
  
  // 动画相关
  public animationFrame: number;
  public animationTimer: number;
  public animationSpeed: number;

  constructor(attributes: CharacterAttributes) {
    // 初始化位置和大小
    this.x = GameConfig.CARROT_START_X;
    this.y = GameConfig.CARROT_START_Y;
    this.width = GameConfig.CARROT_WIDTH;
    this.height = GameConfig.CARROT_HEIGHT;
    
    // 初始化速度
    this.velocityX = 0;
    this.velocityY = 0;
    
    // 初始化状态
    this.state = CharacterState.RUNNING;
    this.isOnGround = true;
    this.canDoubleJump = false;
    this.hasUsedDoubleJump = false;
    
    // 设置角色属性
    this.attributes = attributes;
    
    // 初始化技能状态
    this.activeSkills = new Map();
    this.isInvincible = false;
    this.invincibilityTime = 0;
    
    // 初始化动画
    this.animationFrame = 0;
    this.animationTimer = 0;
    this.animationSpeed = 100; // 毫秒
  }

  // 更新角色状态
  public update(deltaTime: number): void {
    this.updatePhysics(deltaTime);
    this.updateSkills(deltaTime);
    this.updateAnimation(deltaTime);
    this.updateInvincibility(deltaTime);
  }

  // 更新物理状态
  private updatePhysics(deltaTime: number): void {
    // 应用重力
    if (!this.isOnGround) {
      this.velocityY += GameConfig.GRAVITY;
    }
    
    // 更新位置
    this.x += this.velocityX * deltaTime;
    this.y += this.velocityY * deltaTime;
    
    // 检查地面碰撞
    if (this.y >= GameConfig.GROUND_LEVEL - this.height) {
      this.y = GameConfig.GROUND_LEVEL - this.height;
      this.velocityY = 0;
      this.isOnGround = true;
      this.hasUsedDoubleJump = false;
      
      if (this.state === CharacterState.JUMPING || this.state === CharacterState.FALLING) {
        this.state = CharacterState.RUNNING;
      }
    } else {
      this.isOnGround = false;
      if (this.velocityY > 0 && this.state !== CharacterState.SLIDING) {
        this.state = CharacterState.FALLING;
      }
    }
    
    // 限制角色在屏幕内
    if (this.x < 0) {
      this.x = 0;
    } else if (this.x > GameConfig.GAME_WIDTH - this.width) {
      this.x = GameConfig.GAME_WIDTH - this.width;
    }
  }

  // 更新技能状态
  private updateSkills(deltaTime: number): void {
    // 更新激活技能的剩余时间
    for (const [skill, remainingTime] of this.activeSkills) {
      const newTime = remainingTime - deltaTime;
      if (newTime <= 0) {
        this.activeSkills.delete(skill);
        this.onSkillExpired(skill);
      } else {
        this.activeSkills.set(skill, newTime);
      }
    }
    
    // 检查二段跳技能
    this.canDoubleJump = this.hasSkill(CharacterSkill.DOUBLE_JUMP) || 
                        this.attributes.specialSkill === CharacterSkill.DOUBLE_JUMP;
  }

  // 更新动画
  private updateAnimation(deltaTime: number): void {
    this.animationTimer += deltaTime;
    if (this.animationTimer >= this.animationSpeed) {
      this.animationFrame = (this.animationFrame + 1) % 4; // 4帧动画
      this.animationTimer = 0;
    }
  }

  // 更新无敌状态
  private updateInvincibility(deltaTime: number): void {
    if (this.isInvincible) {
      this.invincibilityTime -= deltaTime;
      if (this.invincibilityTime <= 0) {
        this.isInvincible = false;
        this.invincibilityTime = 0;
      }
    }
  }

  // 跳跃
  public jump(): boolean {
    if (this.isOnGround) {
      this.velocityY = GameConfig.JUMP_FORCE * this.attributes.jumpMultiplier;
      this.state = CharacterState.JUMPING;
      this.isOnGround = false;
      return true;
    } else if (this.canDoubleJump && !this.hasUsedDoubleJump) {
      this.velocityY = GameConfig.JUMP_FORCE * this.attributes.jumpMultiplier * 0.8;
      this.state = CharacterState.JUMPING;
      this.hasUsedDoubleJump = true;
      return true;
    }
    return false;
  }

  // 滑行
  public slide(): boolean {
    if (this.isOnGround && this.state !== CharacterState.SLIDING) {
      this.state = CharacterState.SLIDING;
      this.height = GameConfig.CARROT_HEIGHT * 0.6; // 降低高度
      this.y = GameConfig.GROUND_LEVEL - this.height;
      
      // 滑行持续时间
      setTimeout(() => {
        if (this.state === CharacterState.SLIDING) {
          this.state = CharacterState.RUNNING;
          this.height = GameConfig.CARROT_HEIGHT;
          this.y = GameConfig.GROUND_LEVEL - this.height;
        }
      }, 800);
      
      return true;
    }
    return false;
  }

  // 激活技能
  public activateSkill(skill: CharacterSkill, duration: number): void {
    this.activeSkills.set(skill, duration);
    this.onSkillActivated(skill);
  }

  // 检查是否拥有技能
  public hasSkill(skill: CharacterSkill): boolean {
    return this.activeSkills.has(skill);
  }

  // 技能激活回调
  private onSkillActivated(skill: CharacterSkill): void {
    switch (skill) {
      case CharacterSkill.SHIELD:
        this.isInvincible = true;
        this.invincibilityTime = this.activeSkills.get(skill) || 0;
        break;
      case CharacterSkill.SPEED_BOOST:
        // 速度提升在渲染时处理
        break;
      case CharacterSkill.COIN_MAGNET:
        // 磁铁效果在道具收集时处理
        break;
      case CharacterSkill.DOUBLE_JUMP:
        this.canDoubleJump = true;
        break;
    }
  }

  // 技能过期回调
  private onSkillExpired(skill: CharacterSkill): void {
    switch (skill) {
      case CharacterSkill.SHIELD:
        if (!this.hasSkill(CharacterSkill.SHIELD)) {
          this.isInvincible = false;
          this.invincibilityTime = 0;
        }
        break;
      case CharacterSkill.DOUBLE_JUMP:
        this.canDoubleJump = this.attributes.specialSkill === CharacterSkill.DOUBLE_JUMP;
        break;
    }
  }

  // 受到伤害
  public takeDamage(): boolean {
    if (this.isInvincible) {
      return false; // 无敌状态，不受伤害
    }
    
    this.state = CharacterState.DEAD;
    return true; // 受到伤害
  }

  // 获取当前速度倍数
  public getSpeedMultiplier(): number {
    let multiplier = this.attributes.speedMultiplier;
    
    if (this.hasSkill(CharacterSkill.SPEED_BOOST)) {
      multiplier *= 1.5; // 速度提升50%
    }
    
    return multiplier;
  }

  // 获取碰撞盒
  public getBounds(): { x: number, y: number, width: number, height: number } {
    return {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    };
  }

  // 重置角色状态
  public reset(): void {
    this.x = GameConfig.CARROT_START_X;
    this.y = GameConfig.CARROT_START_Y;
    this.velocityX = 0;
    this.velocityY = 0;
    this.state = CharacterState.RUNNING;
    this.isOnGround = true;
    this.canDoubleJump = false;
    this.hasUsedDoubleJump = false;
    this.activeSkills.clear();
    this.isInvincible = false;
    this.invincibilityTime = 0;
    this.height = GameConfig.CARROT_HEIGHT;
  }

  // 绘制角色
  public draw(context: CanvasRenderingContext2D): void {
    if (!context) return;

    // 保存画布状态
    context.save();

    // 如果无敌状态，添加闪烁效果
    if (this.isInvincible && Math.floor(Date.now() / 100) % 2) {
      context.globalAlpha = 0.5;
    }

    // 绘制角色（使用emoji作为简单的视觉表示）
    context.font = `${this.height}px Arial`;
    context.textAlign = 'center';
    context.textBaseline = 'bottom';
    
    // 根据状态调整角色显示
    let displayEmoji = this.attributes.emoji;
    if (this.state === CharacterState.JUMPING) {
      displayEmoji = '🥕'; // 跳跃状态
    } else if (this.state === CharacterState.SLIDING) {
      displayEmoji = '🥕'; // 滑行状态
    }
    
    context.fillText(
      displayEmoji,
      this.x + this.width / 2,
      this.y + this.height
    );

    // 绘制技能效果
    this.drawSkillEffects(context);

    // 恢复画布状态
    context.restore();
  }

  // 绘制技能效果
  private drawSkillEffects(context: CanvasRenderingContext2D): void {
    const centerX = this.x + this.width / 2;
    const centerY = this.y + this.height / 2;

    // 绘制护盾效果
    if (this.hasSkill(CharacterSkill.SHIELD)) {
      context.strokeStyle = '#00FFFF';
      context.lineWidth = 3;
      context.beginPath();
      context.arc(centerX, centerY, this.width / 2 + 5, 0, Math.PI * 2);
      context.stroke();
    }

    // 绘制速度提升效果
    if (this.hasSkill(CharacterSkill.SPEED_BOOST)) {
      context.fillStyle = '#FFFF00';
      context.fillText('💨', centerX + this.width / 2, centerY);
    }

    // 绘制磁铁效果
    if (this.hasSkill(CharacterSkill.COIN_MAGNET)) {
      context.fillStyle = '#FF00FF';
      context.fillText('🧲', centerX, centerY - this.height / 2);
    }
  }
}

// 预定义的角色配置
export const CHARACTER_CONFIGS: { [key: string]: CharacterAttributes } = {
  SPEED_CARROT: {
    id: 'SPEED_CARROT',
    name: '速度萝卜',
    emoji: '🥕',
    speedMultiplier: 1.2,
    jumpMultiplier: 1.0,
    specialSkill: CharacterSkill.SPEED_BOOST,
    unlockCost: 0,
    description: '跑得更快的萝卜，适合追求速度的玩家'
  },
  JUMP_CARROT: {
    id: 'JUMP_CARROT',
    name: '跳跃萝卜',
    emoji: '🥕',
    speedMultiplier: 1.0,
    jumpMultiplier: 1.3,
    specialSkill: CharacterSkill.DOUBLE_JUMP,
    unlockCost: 100,
    description: '跳得更高的萝卜，可以进行二段跳'
  },
  TANK_CARROT: {
    id: 'TANK_CARROT',
    name: '坦克萝卜',
    emoji: '🥕',
    speedMultiplier: 0.8,
    jumpMultiplier: 0.9,
    specialSkill: CharacterSkill.SHIELD,
    unlockCost: 200,
    description: '防御力强的萝卜，开局自带护盾'
  },
  LUCKY_CARROT: {
    id: 'LUCKY_CARROT',
    name: '幸运萝卜',
    emoji: '🥕',
    speedMultiplier: 1.0,
    jumpMultiplier: 1.0,
    specialSkill: CharacterSkill.COIN_MAGNET,
    unlockCost: 150,
    description: '幸运的萝卜，开局自带吸铁石效果'
  }
};