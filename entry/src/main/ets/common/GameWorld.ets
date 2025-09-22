// 游戏世界管理器 - 管理游戏场景中的所有元素
import { PhysicsEngine, PhysicsBody, Vector2 } from './PhysicsEngine'
import { Character } from './Character'
import { GameConfig } from './GameConfig'
import { Level, levelManager, MapTheme } from './LevelSystem'
import { ItemManager, Item, ItemType, effectManager } from './ItemSystem'
import { AudioHelper } from '../game/AudioSystem'

// 障碍物类型
export enum ObstacleType {
  STATIC_BLOCK = 'static_block',
  MOVING_PLATFORM = 'moving_platform',
  SPIKE = 'spike',
  HOLE = 'hole',
  WALL = 'wall'
}

// 道具类型
export enum ItemType {
  COIN = 'coin',
  SPEED_BOOST = 'speed_boost',
  SHIELD = 'shield',
  MAGNET = 'magnet',
  JUMP_BOOST = 'jump_boost'
}

// 游戏对象基类
export abstract class GameObject {
  position: Vector2
  size: Vector2
  physicsBody: PhysicsBody | null = null
  isActive: boolean = true
  id: string

  constructor(x: number, y: number, width: number, height: number) {
    this.position = new Vector2(x, y)
    this.size = new Vector2(width, height)
    this.id = Math.random().toString(36).substr(2, 9)
  }

  abstract update(deltaTime: number): void
  abstract render(context: CanvasRenderingContext2D): void

  // 销毁对象
  destroy(): void {
    this.isActive = false
    if (this.physicsBody) {
      // 从物理引擎中移除
    }
  }
}

// 障碍物类
export class Obstacle extends GameObject {
  type: ObstacleType
  damage: number = 1
  
  // 移动平台属性
  moveSpeed: number = 0
  moveDirection: Vector2 = new Vector2(1, 0)
  moveRange: number = 100
  startPosition: Vector2

  constructor(x: number, y: number, width: number, height: number, type: ObstacleType) {
    super(x, y, width, height)
    this.type = type
    this.startPosition = new Vector2(x, y)
    
    // 创建物理体
    this.physicsBody = new PhysicsBody(x, y, width, height)
    this.physicsBody.isStatic = true
    
    // 根据类型设置属性
    this.setupByType()
  }

  private setupByType(): void {
    switch (this.type) {
      case ObstacleType.STATIC_BLOCK:
        this.damage = 1
        break
      case ObstacleType.MOVING_PLATFORM:
        this.damage = 0
        this.moveSpeed = 50
        this.physicsBody!.isStatic = false
        break
      case ObstacleType.SPIKE:
        this.damage = 2
        break
      case ObstacleType.HOLE:
        this.damage = 3
        break
      case ObstacleType.WALL:
        this.damage = 1
        break
    }
  }

  update(deltaTime: number): void {
    if (!this.isActive) return

    // 移动平台逻辑
    if (this.type === ObstacleType.MOVING_PLATFORM && this.physicsBody) {
      const distanceFromStart = this.position.subtract(this.startPosition).magnitude()
      
      if (distanceFromStart >= this.moveRange) {
        this.moveDirection = this.moveDirection.multiply(-1)
      }
      
      const movement = this.moveDirection.multiply(this.moveSpeed * deltaTime)
      this.position = this.position.add(movement)
      this.physicsBody.position = this.position.copy()
    }
  }

  render(context: CanvasRenderingContext2D): void {
    if (!this.isActive) return

    context.save()
    
    // 根据类型设置颜色
    switch (this.type) {
      case ObstacleType.STATIC_BLOCK:
        context.fillStyle = '#8B4513'
        break
      case ObstacleType.MOVING_PLATFORM:
        context.fillStyle = '#4169E1'
        break
      case ObstacleType.SPIKE:
        context.fillStyle = '#FF4500'
        break
      case ObstacleType.HOLE:
        context.fillStyle = '#000000'
        break
      case ObstacleType.WALL:
        context.fillStyle = '#696969'
        break
    }
    
    context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
    
    // 绘制特殊效果
    if (this.type === ObstacleType.SPIKE) {
      this.drawSpikes(context)
    }
    
    context.restore()
  }

  private drawSpikes(context: CanvasRenderingContext2D): void {
    context.fillStyle = '#FF6347'
    const spikeCount = Math.floor(this.size.x / 10)
    const spikeWidth = this.size.x / spikeCount
    
    for (let i = 0; i < spikeCount; i++) {
      const x = this.position.x + i * spikeWidth
      const y = this.position.y
      
      context.beginPath()
      context.moveTo(x, y)
      context.lineTo(x + spikeWidth / 2, y - 10)
      context.lineTo(x + spikeWidth, y)
      context.closePath()
      context.fill()
    }
  }
}

// 道具类
export class Item extends GameObject {
  type: ItemType
  value: number = 1
  effect: any = null
  collected: boolean = false

  constructor(x: number, y: number, type: ItemType) {
    super(x, y, 20, 20) // 默认道具大小
    this.type = type
    
    // 创建物理体（触发器）
    this.physicsBody = new PhysicsBody(x, y, 20, 20)
    this.physicsBody.isStatic = true
    
    this.setupByType()
  }

  private setupByType(): void {
    switch (this.type) {
      case ItemType.COIN:
        this.value = 10
        break
      case ItemType.SPEED_BOOST:
        this.value = 1
        this.effect = { type: 'speed', multiplier: 1.5, duration: 5000 }
        break
      case ItemType.SHIELD:
        this.value = 1
        this.effect = { type: 'shield', duration: 10000 }
        break
      case ItemType.MAGNET:
        this.value = 1
        this.effect = { type: 'magnet', range: 100, duration: 8000 }
        break
      case ItemType.JUMP_BOOST:
        this.value = 1
        this.effect = { type: 'jump', multiplier: 1.3, duration: 6000 }
        break
    }
  }

  update(deltaTime: number): void {
    if (!this.isActive || this.collected) return
    
    // 道具浮动效果
    this.position.y += Math.sin(Date.now() * 0.005) * 0.5
  }

  render(context: CanvasRenderingContext2D): void {
    if (!this.isActive || this.collected) return

    context.save()
    
    // 根据类型设置颜色和形状
    switch (this.type) {
      case ItemType.COIN:
        context.fillStyle = '#FFD700'
        context.beginPath()
        context.arc(this.position.x + this.size.x / 2, this.position.y + this.size.y / 2, this.size.x / 2, 0, Math.PI * 2)
        context.fill()
        break
      case ItemType.SPEED_BOOST:
        context.fillStyle = '#00FF00'
        context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
        break
      case ItemType.SHIELD:
        context.fillStyle = '#0000FF'
        context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
        break
      case ItemType.MAGNET:
        context.fillStyle = '#FF00FF'
        context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
        break
      case ItemType.JUMP_BOOST:
        context.fillStyle = '#FFA500'
        context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
        break
    }
    
    context.restore()
  }

  collect(): any {
    this.collected = true
    this.isActive = false
    return this.effect
  }
}

// 地面类
export class Ground extends GameObject {
  constructor(x: number, y: number, width: number, height: number = 50) {
    super(x, y, width, height)
    
    // 创建静态物理体
    this.physicsBody = new PhysicsBody(x, y, width, height)
    this.physicsBody.isStatic = true
  }

  update(deltaTime: number): void {
    // 地面不需要更新
  }

  render(context: CanvasRenderingContext2D): void {
    if (!this.isActive) return

    context.save()
    context.fillStyle = '#228B22'
    context.fillRect(this.position.x, this.position.y, this.size.x, this.size.y)
    
    // 绘制草地纹理
    context.fillStyle = '#32CD32'
    for (let i = 0; i < this.size.x; i += 10) {
      context.fillRect(this.position.x + i, this.position.y, 2, 5)
    }
    
    context.restore()
  }
}

// 游戏世界类
export class GameWorld {
  private physicsEngine: PhysicsEngine
  private gameObjects: GameObject[] = []
  private character: Character | null = null
  private camera: Vector2 = new Vector2(0, 0)
  private currentLevel: Level | null = null
  
  // 游戏状态
  private score: number = 0
  private distance: number = 0
  private coins: number = 0
  private gameSpeed: number = GameConfig.GAME.INITIAL_SPEED

  constructor(physicsEngine: PhysicsEngine) {
    this.physicsEngine = physicsEngine
    this.initializeWorld()
  }

  private initializeWorld(): void {
    // 获取当前关卡
    this.currentLevel = levelManager.getCurrentLevel()
    
    if (this.currentLevel) {
      // 从关卡中加载游戏对象
      const levelObjects = this.currentLevel.getGameObjects()
      for (const obj of levelObjects) {
        this.addGameObject(obj)
      }
    }
  }

  // 添加游戏对象
  addGameObject(obj: GameObject): void {
    this.gameObjects.push(obj)
    if (obj.physicsBody) {
      this.physicsEngine.addBody(obj.physicsBody)
    }
  }

  // 移除游戏对象
  removeGameObject(obj: GameObject): void {
    const index = this.gameObjects.indexOf(obj)
    if (index > -1) {
      this.gameObjects.splice(index, 1)
      if (obj.physicsBody) {
        this.physicsEngine.removeBody(obj.physicsBody)
      }
    }
  }

  // 设置角色
  setCharacter(character: Character): void {
    this.character = character
    if (character.physicsBody) {
      this.physicsEngine.addBody(character.physicsBody)
    }
  }

  // 更新游戏世界
  update(deltaTime: number): void {
    // 更新物理引擎
    this.physicsEngine.update(deltaTime)
    
    // 更新所有游戏对象
    for (const obj of this.gameObjects) {
      obj.update(deltaTime)
    }
    
    // 更新角色
    if (this.character) {
      this.character.update(deltaTime)
      
      // 处理磁铁效果
      this.handleMagnetEffect()
      
      this.updateCamera()
      this.checkCollisions()
    }
    
    // 清理非活跃对象
    this.cleanupInactiveObjects()
    
    // 更新游戏状态
    this.updateGameState(deltaTime)
  }

  private updateCamera(): void {
    if (!this.character) return
    
    // 相机跟随角色
    this.camera.x = this.character.position.x - 200
    this.camera.y = Math.max(0, this.character.position.y - 300)
  }

  private checkCollisions(): void {
    if (!this.character) return
    
    for (const obj of this.gameObjects) {
      if (!obj.isActive || !obj.physicsBody) continue
      
      // 检查角色与障碍物的碰撞
      if (obj instanceof Obstacle) {
        if (this.character.physicsBody!.collisionBox.intersects(obj.physicsBody.collisionBox)) {
          this.character.takeDamage(obj.damage)
        }
      }
      
      // 检查角色与道具的碰撞
      if (obj instanceof Item && !obj.collected) {
        if (this.character.physicsBody!.collisionBox.intersects(obj.physicsBody.collisionBox)) {
          const effect = obj.collect()
          
          if (obj.type === ItemType.COIN) {
            // 金币收集，应用积分倍率
            const coinValue = obj.value * (this.character?.getScoreMultiplier() || 1)
            this.coins += coinValue
            // 播放金币收集音效
            AudioHelper.playCoinCollect()
          } else {
            // 其他道具，应用效果到角色
            if (this.character) {
              this.character.applyEffect(effect)
            }
            // 道具本身也可能有积分奖励
            const scoreValue = obj.value * (this.character?.getScoreMultiplier() || 1)
            this.score += scoreValue
            // 播放道具收集音效
            AudioHelper.playItemCollect()
          }
        }
      }
    }
  }

  private cleanupInactiveObjects(): void {
    this.gameObjects = this.gameObjects.filter(obj => {
      if (!obj.isActive) {
        if (obj.physicsBody) {
          this.physicsEngine.removeBody(obj.physicsBody)
        }
        return false
      }
      return true
    })
  }

  private updateGameState(deltaTime: number): void {
    if (this.character) {
      this.distance = Math.max(this.distance, this.character.position.x)
      
      // 更新关卡进度
      levelManager.updateProgress(this.distance)
      
      // 根据距离增加游戏速度
      this.gameSpeed = GameConfig.GAME.INITIAL_SPEED + (this.distance / 1000) * 10
    }
  }

  // 渲染游戏世界
  render(context: CanvasRenderingContext2D): void {
    context.save()
    
    // 应用相机变换
    context.translate(-this.camera.x, -this.camera.y)
    
    // 渲染关卡背景
    if (this.currentLevel) {
      this.currentLevel.render(context, this.camera.x)
    }
    
    // 渲染所有游戏对象
    for (const obj of this.gameObjects) {
      obj.render(context)
    }
    
    // 渲染角色
    if (this.character) {
      this.character.render(context)
    }
    
    context.restore()
  }

  // 获取游戏状态
  getScore(): number {
    return this.score
  }

  getDistance(): number {
    return Math.floor(this.distance)
  }

  getCoins(): number {
    return this.coins
  }

  getGameSpeed(): number {
    return this.gameSpeed
  }

  getCharacter(): Character | null {
    return this.character
  }

  getCamera(): Vector2 {
    return this.camera
  }

  getCurrentLevel(): Level | null {
    return this.currentLevel
  }
  
  // 关卡管理
  loadLevel(levelId: number): void {
    levelManager.loadLevel(levelId)
    this.currentLevel = levelManager.getCurrentLevel()
    this.resetWorld()
  }
  
  nextLevel(): void {
    levelManager.nextLevel()
    this.currentLevel = levelManager.getCurrentLevel()
    this.resetWorld()
  }
  
  private resetWorld(): void {
    // 清除当前游戏对象
    this.gameObjects = []
    
    // 重置游戏状态
    this.score = 0
    this.distance = 0
    this.gameSpeed = GameConfig.GAME.INITIAL_SPEED
    
    // 重新初始化世界
    this.initializeWorld()
  }
  
  // 处理磁铁效果
  private handleMagnetEffect(): void {
    if (!this.character) return
    
    const magnetRange = this.character.getMagnetRange()
    if (magnetRange <= 0) return
    
    const characterPos = this.character.position
    
    for (const obj of this.gameObjects) {
      if (obj instanceof Item && obj.type === ItemType.COIN && !obj.collected) {
        const distance = Math.sqrt(
          Math.pow(obj.position.x - characterPos.x, 2) + 
          Math.pow(obj.position.y - characterPos.y, 2)
        )
        
        if (distance <= magnetRange) {
          // 计算吸引方向
          const dirX = characterPos.x - obj.position.x
          const dirY = characterPos.y - obj.position.y
          const magnitude = Math.sqrt(dirX * dirX + dirY * dirY)
          
          if (magnitude > 0) {
            // 归一化方向向量
            const normalizedX = dirX / magnitude
            const normalizedY = dirY / magnitude
            
            // 吸引速度与距离成反比
            const attractSpeed = 300 * (magnetRange - distance) / magnetRange
            
            // 移动道具
            obj.position.x += normalizedX * attractSpeed * 0.016 // 假设60fps
            obj.position.y += normalizedY * attractSpeed * 0.016
          }
        }
      }
    }
  }

  // 重置游戏世界
  reset(): void {
    this.gameObjects = []
    this.physicsEngine.clear()
    this.score = 0
    this.distance = 0
    this.gameSpeed = GameConfig.GAME.INITIAL_SPEED
    this.camera = new Vector2(0, 0)
    this.initializeWorld()
  }
}