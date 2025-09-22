// 道具系统 - 管理游戏中的各种道具
import { Vector2 } from './PhysicsEngine'
import { GameConfig } from './GameConfig'

// 道具类型枚举
export enum ItemType {
  COIN = 'coin',
  SPEED_BOOST = 'speed_boost',
  SHIELD = 'shield',
  MAGNET = 'magnet',
  JUMP_BOOST = 'jump_boost',
  DOUBLE_SCORE = 'double_score',
  INVINCIBLE = 'invincible',
  SLOW_TIME = 'slow_time'
}

// 道具效果类型
export enum EffectType {
  INSTANT = 'instant',      // 瞬时效果
  DURATION = 'duration',    // 持续效果
  PASSIVE = 'passive'       // 被动效果
}

// 道具效果接口
export interface ItemEffect {
  type: EffectType
  duration?: number         // 持续时间（毫秒）
  value: number            // 效果值
  stackable: boolean       // 是否可叠加
}

// 道具配置接口
export interface ItemConfig {
  type: ItemType
  name: string
  description: string
  icon: string
  rarity: 'common' | 'rare' | 'epic' | 'legendary'
  effect: ItemEffect
  spawnWeight: number      // 生成权重
  price?: number          // 商店价格
}

// 道具实例类
export class Item {
  public position: Vector2
  public size: Vector2
  public type: ItemType
  public config: ItemConfig
  public collected: boolean = false
  public animationTime: number = 0
  public glowIntensity: number = 0

  constructor(x: number, y: number, type: ItemType) {
    this.position = new Vector2(x, y)
    this.size = new Vector2(30, 30)
    this.type = type
    this.config = ItemManager.getItemConfig(type)
  }

  update(deltaTime: number): void {
    if (this.collected) return

    // 更新动画
    this.animationTime += deltaTime
    
    // 浮动动画
    const floatOffset = Math.sin(this.animationTime * 0.003) * 5
    this.position.y += floatOffset * deltaTime * 0.001
    
    // 发光效果
    this.glowIntensity = (Math.sin(this.animationTime * 0.005) + 1) * 0.5
  }

  render(context: CanvasRenderingContext2D): void {
    if (this.collected) return

    context.save()
    
    // 绘制发光效果
    if (this.config.rarity !== 'common') {
      const glowRadius = 20 + this.glowIntensity * 10
      const gradient = context.createRadialGradient(
        this.position.x + this.size.x / 2, this.position.y + this.size.y / 2, 0,
        this.position.x + this.size.x / 2, this.position.y + this.size.y / 2, glowRadius
      )
      
      const glowColor = this.getRarityColor()
      gradient.addColorStop(0, `${glowColor}80`)
      gradient.addColorStop(1, `${glowColor}00`)
      
      context.fillStyle = gradient
      context.fillRect(
        this.position.x - glowRadius / 2,
        this.position.y - glowRadius / 2,
        this.size.x + glowRadius,
        this.size.y + glowRadius
      )
    }
    
    // 绘制道具图标
    this.renderIcon(context)
    
    context.restore()
  }

  private renderIcon(context: CanvasRenderingContext2D): void {
    const centerX = this.position.x + this.size.x / 2
    const centerY = this.position.y + this.size.y / 2
    const radius = this.size.x / 2

    context.fillStyle = this.getItemColor()
    context.beginPath()
    context.arc(centerX, centerY, radius, 0, Math.PI * 2)
    context.fill()

    // 绘制道具符号
    context.fillStyle = 'white'
    context.font = '16px Arial'
    context.textAlign = 'center'
    context.textBaseline = 'middle'
    context.fillText(this.getItemSymbol(), centerX, centerY)
  }

  private getItemColor(): string {
    switch (this.type) {
      case ItemType.COIN: return '#FFD700'
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

  private getItemSymbol(): string {
    switch (this.type) {
      case ItemType.COIN: return '¥'
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

  private getRarityColor(): string {
    switch (this.config.rarity) {
      case 'common': return '#FFFFFF'
      case 'rare': return '#00FF00'
      case 'epic': return '#9932CC'
      case 'legendary': return '#FFD700'
      default: return '#FFFFFF'
    }
  }

  collect(): ItemEffect {
    this.collected = true
    return this.config.effect
  }

  getValue(): number {
    return this.config.effect.value
  }
}

// 道具管理器
export class ItemManager {
  private static itemConfigs: Map<ItemType, ItemConfig> = new Map()
  private static initialized: boolean = false

  static initialize(): void {
    if (this.initialized) return

    // 初始化道具配置
    this.itemConfigs.set(ItemType.COIN, {
      type: ItemType.COIN,
      name: '金币',
      description: '收集金币来购买新角色和道具',
      icon: '¥',
      rarity: 'common',
      effect: {
        type: EffectType.INSTANT,
        value: 10,
        stackable: true
      },
      spawnWeight: 50
    })

    this.itemConfigs.set(ItemType.SPEED_BOOST, {
      type: ItemType.SPEED_BOOST,
      name: '加速道具',
      description: '短时间内大幅提升移动速度',
      icon: '⚡',
      rarity: 'rare',
      effect: {
        type: EffectType.DURATION,
        duration: 5000,
        value: 1.5,
        stackable: false
      },
      spawnWeight: 15,
      price: 50
    })

    this.itemConfigs.set(ItemType.SHIELD, {
      type: ItemType.SHIELD,
      name: '保护盾',
      description: '抵御一次障碍物撞击',
      icon: '🛡',
      rarity: 'rare',
      effect: {
        type: EffectType.DURATION,
        duration: 10000,
        value: 1,
        stackable: false
      },
      spawnWeight: 12,
      price: 75
    })

    this.itemConfigs.set(ItemType.MAGNET, {
      type: ItemType.MAGNET,
      name: '吸铁石',
      description: '自动收集周围的金币',
      icon: '🧲',
      rarity: 'epic',
      effect: {
        type: EffectType.DURATION,
        duration: 8000,
        value: 100, // 吸引范围
        stackable: false
      },
      spawnWeight: 8,
      price: 100
    })

    this.itemConfigs.set(ItemType.JUMP_BOOST, {
      type: ItemType.JUMP_BOOST,
      name: '跳跃增强',
      description: '增加跳跃高度和距离',
      icon: '↑',
      rarity: 'rare',
      effect: {
        type: EffectType.DURATION,
        duration: 6000,
        value: 1.3,
        stackable: false
      },
      spawnWeight: 10,
      price: 60
    })

    this.itemConfigs.set(ItemType.DOUBLE_SCORE, {
      type: ItemType.DOUBLE_SCORE,
      name: '双倍积分',
      description: '短时间内获得双倍积分',
      icon: '×2',
      rarity: 'epic',
      effect: {
        type: EffectType.DURATION,
        duration: 10000,
        value: 2,
        stackable: false
      },
      spawnWeight: 6,
      price: 120
    })

    this.itemConfigs.set(ItemType.INVINCIBLE, {
      type: ItemType.INVINCIBLE,
      name: '无敌状态',
      description: '短时间内免疫所有伤害',
      icon: '★',
      rarity: 'legendary',
      effect: {
        type: EffectType.DURATION,
        duration: 5000,
        value: 1,
        stackable: false
      },
      spawnWeight: 3,
      price: 200
    })

    this.itemConfigs.set(ItemType.SLOW_TIME, {
      type: ItemType.SLOW_TIME,
      name: '时间减缓',
      description: '减缓游戏时间，更容易躲避障碍',
      icon: '⏰',
      rarity: 'legendary',
      effect: {
        type: EffectType.DURATION,
        duration: 4000,
        value: 0.5, // 时间倍率
        stackable: false
      },
      spawnWeight: 2,
      price: 250
    })

    this.initialized = true
  }

  static getItemConfig(type: ItemType): ItemConfig {
    const config = this.itemConfigs.get(type)
    if (!config) {
      throw new Error(`未找到道具配置: ${type}`)
    }
    return config
  }

  static getAllConfigs(): ItemConfig[] {
    return Array.from(this.itemConfigs.values())
  }

  static getRandomItemType(): ItemType {
    const configs = Array.from(this.itemConfigs.values())
    const totalWeight = configs.reduce((sum, config) => sum + config.spawnWeight, 0)
    
    let random = Math.random() * totalWeight
    for (const config of configs) {
      random -= config.spawnWeight
      if (random <= 0) {
        return config.type
      }
    }
    
    return ItemType.COIN // 默认返回金币
  }

  static createRandomItem(x: number, y: number): Item {
    const type = this.getRandomItemType()
    return new Item(x, y, type)
  }
}

// 道具效果管理器
export class EffectManager {
  private activeEffects: Map<ItemType, { effect: ItemEffect, startTime: number }> = new Map()
  private timeScale: number = 1.0

  applyEffect(effect: ItemEffect, type: ItemType): void {
    if (effect.type === EffectType.INSTANT) {
      // 瞬时效果直接处理
      return
    }

    if (effect.type === EffectType.DURATION) {
      if (!effect.stackable && this.activeEffects.has(type)) {
        // 如果不可叠加且已存在，重置时间
        const existing = this.activeEffects.get(type)!
        existing.startTime = Date.now()
      } else {
        // 添加新效果
        this.activeEffects.set(type, {
          effect: effect,
          startTime: Date.now()
        })
      }
    }
  }

  update(deltaTime: number): void {
    const currentTime = Date.now()
    const expiredEffects: ItemType[] = []

    for (const [type, activeEffect] of this.activeEffects) {
      const elapsed = currentTime - activeEffect.startTime
      if (activeEffect.effect.duration && elapsed >= activeEffect.effect.duration) {
        expiredEffects.push(type)
      }
    }

    // 移除过期效果
    for (const type of expiredEffects) {
      this.activeEffects.delete(type)
    }

    // 更新时间缩放
    this.updateTimeScale()
  }

  private updateTimeScale(): void {
    const slowTimeEffect = this.activeEffects.get(ItemType.SLOW_TIME)
    if (slowTimeEffect) {
      this.timeScale = slowTimeEffect.effect.value
    } else {
      this.timeScale = 1.0
    }
  }

  hasEffect(type: ItemType): boolean {
    return this.activeEffects.has(type)
  }

  getEffectValue(type: ItemType): number {
    const effect = this.activeEffects.get(type)
    return effect ? effect.effect.value : 1
  }

  getTimeScale(): number {
    return this.timeScale
  }

  getRemainingTime(type: ItemType): number {
    const effect = this.activeEffects.get(type)
    if (!effect || !effect.effect.duration) return 0
    
    const elapsed = Date.now() - effect.startTime
    return Math.max(0, effect.effect.duration - elapsed)
  }

  clearAllEffects(): void {
    this.activeEffects.clear()
    this.timeScale = 1.0
  }

  getActiveEffects(): ItemType[] {
    return Array.from(this.activeEffects.keys())
  }
}

// 导出单例
export const itemManager = new ItemManager()
export const effectManager = new EffectManager()

// 初始化道具系统
ItemManager.initialize()