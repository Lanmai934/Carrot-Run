// 萝卜角色系统
import { GameConfig } from './GameConfig'
import { PhysicsBody, Vector2 } from './PhysicsEngine'
import { ItemEffect, EffectManager, ItemType, effectManager } from './ItemSystem'
import { AudioHelper } from '../game/AudioSystem'

// 角色状态枚举
export enum CharacterState {
  IDLE = 'idle',
  RUNNING = 'running',
  JUMPING = 'jumping',
  SLIDING = 'sliding',
  FALLING = 'falling',
  HURT = 'hurt',
  DEAD = 'dead'
}

// 角色技能枚举
export enum CharacterSkill {
  DOUBLE_JUMP = 'double_jump',
  DASH = 'dash',
  SHIELD = 'shield',
  MAGNET = 'magnet',
  SPEED_BOOST = 'speed_boost'
}

// 角色属性接口
export interface CharacterAttributes {
  speed: number
  jumpHeight: number
  health: number
  skillCooldown: number
  specialAbility: CharacterSkill
}

// 萝卜角色类
export class Character {
  // 基础属性
  id: string
  name: string
  type: string
  position: Vector2
  size: Vector2
  
  // 物理体
  physicsBody: PhysicsBody | null = null
  
  // 角色属性
  attributes: CharacterAttributes
  currentHealth: number
  state: CharacterState
  
  // 动画相关
  currentFrame: number = 0
  animationTimer: number = 0
  animationSpeed: number = 100 // 毫秒
  
  // 技能相关
  activeSkills: Map<CharacterSkill, number> = new Map() // 技能ID -> 剩余时间
  skillCooldowns: Map<CharacterSkill, number> = new Map() // 技能ID -> 冷却时间
  
  // 物理相关
  canDoubleJump: boolean = false
  isInvincible: boolean = false
  invincibilityTimer: number = 0
  
  // 道具效果
  private effectManager: EffectManager = effectManager

  constructor(characterType: string) {
    this.id = Math.random().toString(36).substr(2, 9)
    this.type = characterType
    this.name = GameConfig.CHARACTER_TYPES[characterType]?.name || '萝卜'
    
    // 初始化位置和大小
    this.position = new Vector2(100, 400)
    this.size = new Vector2(40, 40)
    
    // 创建物理体
    this.physicsBody = new PhysicsBody(this.position.x, this.position.y, this.size.x, this.size.y)
    this.physicsBody.mass = 1
    this.physicsBody.friction = 0.8
    this.physicsBody.restitution = 0.1
    
    // 根据角色类型设置属性
    this.attributes = this.getCharacterAttributes(characterType)
    this.currentHealth = this.attributes.health
    this.state = CharacterState.IDLE
  }

  // 根据角色类型获取属性
  private getCharacterAttributes(type: string): CharacterAttributes {
    const config = GameConfig.CHARACTER_TYPES[type]
    if (config) {
      return {
        speed: config.speed,
        jumpHeight: config.jumpHeight,
        health: config.health,
        skillCooldown: config.skillCooldown,
        specialAbility: config.specialAbility as CharacterSkill
      }
    }
    
    // 默认属性
    return {
      speed: GameConfig.CHARACTER.MOVE_SPEED,
      jumpHeight: GameConfig.CHARACTER.JUMP_FORCE,
      health: 3,
      skillCooldown: 5000,
      specialAbility: CharacterSkill.DOUBLE_JUMP
    }
  }

  // 更新角色状态
  update(deltaTime: number): void {
    // 更新效果管理器
    this.effectManager.update(deltaTime)
    
    // 应用时间缩放
    const scaledDeltaTime = deltaTime * this.effectManager.getTimeScale()
    
    // 更新物理状态
    this.updatePhysics(scaledDeltaTime)
    
    // 更新技能状态
    this.updateSkills(scaledDeltaTime)
    
    // 更新动画
    this.updateAnimation(scaledDeltaTime)
    
    // 更新无敌状态
    this.updateInvincibility(scaledDeltaTime)
    
    this.updateState()
  }

  // 更新物理状态
  private updatePhysics(deltaTime: number): void {
    if (!this.physicsBody) return
    
    // 同步位置
    this.position = this.physicsBody.position.copy()
    
    // 计算基础移动速度
    let moveSpeed = this.attributes.speed
    
    // 应用速度增强效果
    if (this.effectManager.hasEffect(ItemType.SPEED_BOOST)) {
      moveSpeed *= this.effectManager.getEffectValue(ItemType.SPEED_BOOST)
    }
    
    // 自动向前移动
    if (this.state !== CharacterState.DEAD) {
      this.physicsBody.velocity.x = moveSpeed
    }
  }

  // 更新技能状态
  private updateSkills(deltaTime: number): void {
    // 更新激活技能的持续时间
    for (const [skill, remainingTime] of this.activeSkills) {
      const newTime = remainingTime - deltaTime
      if (newTime <= 0) {
        this.activeSkills.delete(skill)
        this.onSkillEnd(skill)
      } else {
        this.activeSkills.set(skill, newTime)
      }
    }
    
    // 更新技能冷却时间
    for (const [skill, remainingTime] of this.skillCooldowns) {
      const newTime = remainingTime - deltaTime
      if (newTime <= 0) {
        this.skillCooldowns.delete(skill)
      } else {
        this.skillCooldowns.set(skill, newTime)
      }
    }
  }

  // 更新动画
  private updateAnimation(deltaTime: number): void {
    this.animationTimer += deltaTime
    if (this.animationTimer >= this.animationSpeed) {
      this.currentFrame = (this.currentFrame + 1) % 4 // 假设每个动画有4帧
      this.animationTimer = 0
    }
  }

  // 更新无敌状态
  private updateInvincibility(deltaTime: number): void {
    if (this.isInvincible) {
      this.invincibilityTimer -= deltaTime
      if (this.invincibilityTimer <= 0) {
        this.isInvincible = false
      }
    }
  }

  // 更新角色状态
  private updateState(): void {
    if (!this.physicsBody) return
    
    if (this.currentHealth <= 0) {
      this.state = CharacterState.DEAD
      return
    }
    
    if (this.physicsBody.velocity.y < -10) {
      this.state = CharacterState.JUMPING
    } else if (this.physicsBody.velocity.y > 10) {
      this.state = CharacterState.FALLING
    } else if (Math.abs(this.physicsBody.velocity.x) > 10) {
      this.state = CharacterState.RUNNING
    } else {
      this.state = CharacterState.IDLE
    }
  }

  // 跳跃
  jump(): void {
    if (!this.physicsBody) return
    
    if (this.physicsBody.isGrounded) {
      let jumpHeight = this.attributes.jumpHeight
      
      // 应用跳跃增强效果
      if (this.effectManager.hasEffect(ItemType.JUMP_BOOST)) {
        jumpHeight *= this.effectManager.getEffectValue(ItemType.JUMP_BOOST)
      }
      
      this.physicsBody.jump(jumpHeight)
      this.canDoubleJump = this.hasSkill(CharacterSkill.DOUBLE_JUMP)
    } else if (this.canDoubleJump) {
      let jumpHeight = this.attributes.jumpHeight * 0.8
      
      // 应用跳跃增强效果
      if (this.effectManager.hasEffect(ItemType.JUMP_BOOST)) {
        jumpHeight *= this.effectManager.getEffectValue(ItemType.JUMP_BOOST)
      }
      
      this.physicsBody.jump(jumpHeight)
      this.canDoubleJump = false
    }
  }

  // 滑行
  slide(): void {
    if (!this.physicsBody || !this.physicsBody.isGrounded) return
    
    this.state = CharacterState.SLIDING
    // 降低碰撞盒高度
    this.physicsBody.collisionBox.height = this.size.y * 0.5
    
    // 设置滑行持续时间
    setTimeout(() => {
      if (this.physicsBody) {
        this.physicsBody.collisionBox.height = this.size.y
      }
      if (this.state === CharacterState.SLIDING) {
        this.state = CharacterState.RUNNING
      }
    }, 1000)
  }

  // 激活技能
  activateSkill(skill: CharacterSkill): boolean {
    if (this.skillCooldowns.has(skill) || this.activeSkills.has(skill)) {
      return false
    }
    
    switch (skill) {
      case CharacterSkill.DASH:
        this.dash()
        break
      case CharacterSkill.SHIELD:
        this.activateShield()
        break
      case CharacterSkill.SPEED_BOOST:
        this.activateSpeedBoost()
        break
      case CharacterSkill.MAGNET:
        this.activateMagnet()
        break
    }
    
    // 设置冷却时间
    this.skillCooldowns.set(skill, this.attributes.skillCooldown)
    return true
  }

  // 冲刺技能
  private dash(): void {
    if (!this.physicsBody) return
    
    this.physicsBody.velocity.x += 200
    this.activeSkills.set(CharacterSkill.DASH, 500) // 0.5秒
  }

  // 护盾技能
  private activateShield(): void {
    this.activeSkills.set(CharacterSkill.SHIELD, 5000) // 5秒
    this.isInvincible = true
    this.invincibilityTimer = 5000
  }

  // 加速技能
  private activateSpeedBoost(): void {
    this.activeSkills.set(CharacterSkill.SPEED_BOOST, 3000) // 3秒
    this.attributes.speed *= 1.5
  }

  // 磁铁技能
  private activateMagnet(): void {
    this.activeSkills.set(CharacterSkill.MAGNET, 8000) // 8秒
  }

  // 技能结束处理
  private onSkillEnd(skill: CharacterSkill): void {
    switch (skill) {
      case CharacterSkill.SPEED_BOOST:
        this.attributes.speed /= 1.5
        break
      case CharacterSkill.SHIELD:
        this.isInvincible = false
        this.invincibilityTimer = 0
        break
    }
  }

  // 检查是否拥有技能
  hasSkill(skill: CharacterSkill): boolean {
    return this.attributes.specialAbility === skill || 
           GameConfig.CHARACTER_TYPES[this.type]?.skills?.includes(skill) || false
  }

  // 受到伤害
  takeDamage(damage: number): void {
    if (this.isInvincible || this.state === CharacterState.DEAD) return
    
    this.currentHealth -= damage
    this.state = CharacterState.HURT
    
    // 播放受伤音效
    AudioHelper.playHurt()
    
    // 设置短暂无敌时间
    this.isInvincible = true
    this.invincibilityTimer = 1000 // 1秒无敌
    
    if (this.currentHealth <= 0) {
      this.die()
    }
  }

  // 治疗
  heal(amount: number): void {
    this.currentHealth = Math.min(this.currentHealth + amount, this.attributes.health)
  }

  // 死亡
  private die(): void {
    this.state = CharacterState.DEAD
    if (this.physicsBody) {
      this.physicsBody.velocity = new Vector2(0, 0)
    }
    // 播放游戏结束音效
    AudioHelper.playGameOver()
  }

  // 应用道具效果
  applyEffect(effect: any): void {
    if (!effect) return
    
    switch (effect.type) {
      case 'speed':
        this.attributes.speed *= effect.multiplier
        setTimeout(() => {
          this.attributes.speed /= effect.multiplier
        }, effect.duration)
        break
      case 'shield':
        this.activateShield()
        break
      case 'magnet':
        this.activateMagnet()
        break
      case 'jump':
        this.attributes.jumpHeight *= effect.multiplier
        setTimeout(() => {
          this.attributes.jumpHeight /= effect.multiplier
        }, effect.duration)
        break
    }
  }

  // 渲染角色
  render(context: CanvasRenderingContext2D): void {
    if (this.state === CharacterState.DEAD) return
    
    context.save()
    
    // 无敌状态闪烁效果
    if (this.isInvincible && Math.floor(Date.now() / 100) % 2) {
      context.globalAlpha = 0.5
    }
    
    // 根据状态设置颜色
    let color = '#FF6B35' // 默认萝卜橙色
    switch (this.state) {
      case CharacterState.HURT:
        color = '#FF0000'
        break
      case CharacterState.SLIDING:
        color = '#FFD700'
        break
    }
    
    // 绘制萝卜角色
    context.fillStyle = color
    context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
    
    // 绘制萝卜叶子
    context.fillStyle = '#228B22'
    context.fillRect(this.position.x + 10, this.position.y - 10, 20, 15)
    
    // 绘制眼睛
    context.fillStyle = '#000000'
    context.fillRect(this.position.x + 8, this.position.y + 8, 4, 4)
    context.fillRect(this.position.x + 28, this.position.y + 8, 4, 4)
    
    // 绘制嘴巴
    context.fillStyle = '#000000'
    context.fillRect(this.position.x + 15, this.position.y + 20, 10, 2)
    
    // 绘制激活的技能效果
    this.renderSkillEffects(context)
    
    context.restore()
  }

  // 渲染技能效果
  private renderSkillEffects(context: CanvasRenderingContext2D): void {
    // 护盾效果
    if (this.activeSkills.has(CharacterSkill.SHIELD)) {
      context.strokeStyle = '#0000FF'
      context.lineWidth = 3
      context.strokeRect(this.position.x - 5, this.position.y - 5, this.size.x + 10, this.size.y + 10)
    }
    
    // 磁铁效果
    if (this.activeSkills.has(CharacterSkill.MAGNET)) {
      context.strokeStyle = '#FF00FF'
      context.lineWidth = 2
      context.beginPath()
      context.arc(this.position.x + this.size.x / 2, this.position.y + this.size.y / 2, 50, 0, Math.PI * 2)
      context.stroke()
    }
    
    // 加速效果
    if (this.activeSkills.has(CharacterSkill.SPEED_BOOST)) {
      context.fillStyle = '#00FF00'
      context.globalAlpha = 0.3
      context.fillRect(this.position.x - 2, this.position.y - 2, this.size.x + 4, this.size.y + 4)
      context.globalAlpha = 1
    }
  }

  // 应用道具效果
  applyEffect(effect: ItemEffect): void {
    this.effectManager.applyEffect(effect, effect.type as ItemType)
  }
  
  // 检查是否有保护效果
  hasProtection(): boolean {
    return this.effectManager.hasEffect(ItemType.SHIELD) || 
           this.effectManager.hasEffect(ItemType.INVINCIBLE) ||
           this.isInvincible
  }
  
  // 获取积分倍率
  getScoreMultiplier(): number {
    if (this.effectManager.hasEffect(ItemType.DOUBLE_SCORE)) {
      return this.effectManager.getEffectValue(ItemType.DOUBLE_SCORE)
    }
    return 1
  }
  
  // 获取磁铁范围
  getMagnetRange(): number {
    if (this.effectManager.hasEffect(ItemType.MAGNET)) {
      return this.effectManager.getEffectValue(ItemType.MAGNET)
    }
    return 0
  }
  
  // 获取活跃效果
  getActiveEffects(): ItemType[] {
    return this.effectManager.getActiveEffects()
  }
  
  // 获取效果剩余时间
  getEffectRemainingTime(type: ItemType): number {
    return this.effectManager.getRemainingTime(type)
  }

  // 重置角色状态
  reset(): void {
    this.position = new Vector2(100, 400)
    this.currentHealth = this.attributes.health
    this.state = CharacterState.IDLE
    this.activeSkills.clear()
    this.skillCooldowns.clear()
    this.isInvincible = false
    this.invincibilityTimer = 0
    this.canDoubleJump = false
    
    if (this.physicsBody) {
      this.physicsBody.position = this.position.copy()
      this.physicsBody.velocity = new Vector2(0, 0)
      this.physicsBody.acceleration = new Vector2(0, 0)
      this.physicsBody.isGrounded = false
    }
    
    // 清除所有道具效果
    this.effectManager.clearAllEffects()
  }
}

// 预定义的萝卜角色配置
export const CARROT_CHARACTERS = {
  'classic': {
    name: '经典萝卜',
    speed: 100,
    jumpHeight: 150,
    health: 3,
    skillCooldown: 5000,
    specialAbility: CharacterSkill.DOUBLE_JUMP,
    skills: [CharacterSkill.DOUBLE_JUMP],
    unlockCost: 0
  },
  'speedy': {
    name: '疾速萝卜',
    speed: 150,
    jumpHeight: 120,
    health: 2,
    skillCooldown: 4000,
    specialAbility: CharacterSkill.DASH,
    skills: [CharacterSkill.DASH, CharacterSkill.SPEED_BOOST],
    unlockCost: 500
  },
  'tank': {
    name: '坦克萝卜',
    speed: 80,
    jumpHeight: 100,
    health: 5,
    skillCooldown: 6000,
    specialAbility: CharacterSkill.SHIELD,
    skills: [CharacterSkill.SHIELD],
    unlockCost: 800
  },
  'collector': {
    name: '收集萝卜',
    speed: 110,
    jumpHeight: 130,
    health: 3,
    skillCooldown: 5000,
    specialAbility: CharacterSkill.MAGNET,
    skills: [CharacterSkill.MAGNET],
    unlockCost: 600
  }
}