// 关卡系统 - 管理多主题地图和关卡生成
import { GameConfig } from './GameConfig'
import { Obstacle, ObstacleType, Item, ItemType, Ground, GameObject } from './GameWorld'
import { Vector2 } from './PhysicsEngine'
import { AudioHelper } from '../game/AudioSystem'

// 地图主题枚举
export enum MapTheme {
  FOREST = 'forest',
  DESERT = 'desert',
  SNOW = 'snow',
  CITY = 'city'
}

// 关卡难度枚举
export enum LevelDifficulty {
  EASY = 'easy',
  NORMAL = 'normal',
  HARD = 'hard',
  EXTREME = 'extreme'
}

// 地形类型
export enum TerrainType {
  FLAT = 'flat',
  HILL = 'hill',
  VALLEY = 'valley',
  PLATFORM = 'platform',
  GAP = 'gap'
}

// 关卡配置接口
export interface LevelConfig {
  theme: MapTheme
  difficulty: LevelDifficulty
  length: number
  obstacleFrequency: number
  itemFrequency: number
  terrainVariation: number
  backgroundElements: string[]
  specialFeatures: string[]
}

// 地形段配置
export interface TerrainSegment {
  type: TerrainType
  startX: number
  endX: number
  height: number
  obstacles: ObstacleConfig[]
  items: ItemConfig[]
}

// 障碍物配置
export interface ObstacleConfig {
  type: ObstacleType
  x: number
  y: number
  width: number
  height: number
  properties?: any
}

// 道具配置
export interface ItemConfig {
  type: ItemType
  x: number
  y: number
}

// 背景元素类
export class BackgroundElement {
  position: Vector2
  size: Vector2
  type: string
  layer: number // 渲染层级，数字越小越靠后
  scrollSpeed: number // 视差滚动速度

  constructor(x: number, y: number, width: number, height: number, type: string, layer: number = 1) {
    this.position = new Vector2(x, y)
    this.size = new Vector2(width, height)
    this.type = type
    this.layer = layer
    this.scrollSpeed = layer * 0.1 // 根据层级设置滚动速度
  }

  render(context: CanvasRenderingContext2D, cameraX: number, theme: MapTheme): void {
    const offsetX = this.position.x - cameraX * this.scrollSpeed

    context.save()
    
    switch (theme) {
      case MapTheme.FOREST:
        this.renderForestElement(context, offsetX)
        break
      case MapTheme.DESERT:
        this.renderDesertElement(context, offsetX)
        break
      case MapTheme.SNOW:
        this.renderSnowElement(context, offsetX)
        break
      case MapTheme.CITY:
        this.renderCityElement(context, offsetX)
        break
    }
    
    context.restore()
  }

  private renderForestElement(context: CanvasRenderingContext2D, x: number): void {
    switch (this.type) {
      case 'tree':
        // 绘制树木
        context.fillStyle = '#8B4513'
        context.fillRect(x + this.size.x * 0.4, this.position.y + this.size.y * 0.6, this.size.x * 0.2, this.size.y * 0.4)
        context.fillStyle = '#228B22'
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.3, this.size.x * 0.3, 0, Math.PI * 2)
        context.fill()
        break
      case 'bush':
        // 绘制灌木
        context.fillStyle = '#32CD32'
        context.fillRect(x, this.position.y, this.size.x, this.size.y)
        break
      case 'flower':
        // 绘制花朵
        context.fillStyle = '#FF69B4'
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.5, this.size.x * 0.3, 0, Math.PI * 2)
        context.fill()
        break
    }
  }

  private renderDesertElement(context: CanvasRenderingContext2D, x: number): void {
    switch (this.type) {
      case 'cactus':
        // 绘制仙人掌
        context.fillStyle = '#228B22'
        context.fillRect(x + this.size.x * 0.4, this.position.y, this.size.x * 0.2, this.size.y)
        context.fillRect(x + this.size.x * 0.1, this.position.y + this.size.y * 0.3, this.size.x * 0.3, this.size.x * 0.1)
        break
      case 'rock':
        // 绘制岩石
        context.fillStyle = '#A0522D'
        context.fillRect(x, this.position.y, this.size.x, this.size.y)
        break
      case 'dune':
        // 绘制沙丘
        context.fillStyle = '#F4A460'
        context.beginPath()
        context.ellipse(x + this.size.x * 0.5, this.position.y + this.size.y, this.size.x * 0.5, this.size.y * 0.3, 0, 0, Math.PI * 2)
        context.fill()
        break
    }
  }

  private renderSnowElement(context: CanvasRenderingContext2D, x: number): void {
    switch (this.type) {
      case 'pine_tree':
        // 绘制松树
        context.fillStyle = '#8B4513'
        context.fillRect(x + this.size.x * 0.45, this.position.y + this.size.y * 0.7, this.size.x * 0.1, this.size.y * 0.3)
        context.fillStyle = '#006400'
        for (let i = 0; i < 3; i++) {
          const treeY = this.position.y + this.size.y * (0.2 + i * 0.2)
          const treeWidth = this.size.x * (0.6 - i * 0.1)
          context.beginPath()
          context.moveTo(x + this.size.x * 0.5, treeY)
          context.lineTo(x + this.size.x * 0.5 - treeWidth * 0.5, treeY + this.size.y * 0.2)
          context.lineTo(x + this.size.x * 0.5 + treeWidth * 0.5, treeY + this.size.y * 0.2)
          context.closePath()
          context.fill()
        }
        break
      case 'snowman':
        // 绘制雪人
        context.fillStyle = '#FFFFFF'
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.8, this.size.x * 0.3, 0, Math.PI * 2)
        context.fill()
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.5, this.size.x * 0.25, 0, Math.PI * 2)
        context.fill()
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.25, this.size.x * 0.2, 0, Math.PI * 2)
        context.fill()
        break
      case 'ice_crystal':
        // 绘制冰晶
        context.strokeStyle = '#87CEEB'
        context.lineWidth = 2
        context.beginPath()
        context.moveTo(x + this.size.x * 0.5, this.position.y)
        context.lineTo(x + this.size.x * 0.5, this.position.y + this.size.y)
        context.moveTo(x, this.position.y + this.size.y * 0.5)
        context.lineTo(x + this.size.x, this.position.y + this.size.y * 0.5)
        context.stroke()
        break
    }
  }

  private renderCityElement(context: CanvasRenderingContext2D, x: number): void {
    switch (this.type) {
      case 'building':
        // 绘制建筑物
        context.fillStyle = '#696969'
        context.fillRect(x, this.position.y, this.size.x, this.size.y)
        // 绘制窗户
        context.fillStyle = '#FFFF00'
        for (let i = 0; i < 3; i++) {
          for (let j = 0; j < Math.floor(this.size.y / 30); j++) {
            if (Math.random() > 0.3) {
              context.fillRect(x + 10 + i * 20, this.position.y + 10 + j * 30, 8, 8)
            }
          }
        }
        break
      case 'streetlight':
        // 绘制路灯
        context.fillStyle = '#2F4F4F'
        context.fillRect(x + this.size.x * 0.45, this.position.y, this.size.x * 0.1, this.size.y * 0.9)
        context.fillStyle = '#FFFF00'
        context.beginPath()
        context.arc(x + this.size.x * 0.5, this.position.y + this.size.y * 0.1, this.size.x * 0.2, 0, Math.PI * 2)
        context.fill()
        break
      case 'car':
        // 绘制汽车
        context.fillStyle = '#FF0000'
        context.fillRect(x, this.position.y, this.size.x, this.size.y * 0.6)
        context.fillStyle = '#000000'
        context.beginPath()
        context.arc(x + this.size.x * 0.2, this.position.y + this.size.y * 0.8, this.size.x * 0.1, 0, Math.PI * 2)
        context.fill()
        context.beginPath()
        context.arc(x + this.size.x * 0.8, this.position.y + this.size.y * 0.8, this.size.x * 0.1, 0, Math.PI * 2)
        context.fill()
        break
    }
  }
}

// 关卡生成器类
export class LevelGenerator {
  private static readonly THEME_CONFIGS: Record<MapTheme, LevelConfig> = {
    [MapTheme.FOREST]: {
      theme: MapTheme.FOREST,
      difficulty: LevelDifficulty.EASY,
      length: 2000,
      obstacleFrequency: 0.3,
      itemFrequency: 0.4,
      terrainVariation: 0.2,
      backgroundElements: ['tree', 'bush', 'flower'],
      specialFeatures: ['moving_platform', 'vine_swing']
    },
    [MapTheme.DESERT]: {
      theme: MapTheme.DESERT,
      difficulty: LevelDifficulty.NORMAL,
      length: 2500,
      obstacleFrequency: 0.4,
      itemFrequency: 0.3,
      terrainVariation: 0.3,
      backgroundElements: ['cactus', 'rock', 'dune'],
      specialFeatures: ['sandstorm', 'quicksand']
    },
    [MapTheme.SNOW]: {
      theme: MapTheme.SNOW,
      difficulty: LevelDifficulty.HARD,
      length: 3000,
      obstacleFrequency: 0.5,
      itemFrequency: 0.25,
      terrainVariation: 0.4,
      backgroundElements: ['pine_tree', 'snowman', 'ice_crystal'],
      specialFeatures: ['ice_platform', 'blizzard']
    },
    [MapTheme.CITY]: {
      theme: MapTheme.CITY,
      difficulty: LevelDifficulty.EXTREME,
      length: 3500,
      obstacleFrequency: 0.6,
      itemFrequency: 0.2,
      terrainVariation: 0.5,
      backgroundElements: ['building', 'streetlight', 'car'],
      specialFeatures: ['traffic', 'construction']
    }
  }

  // 生成关卡
  static generateLevel(theme: MapTheme, customConfig?: Partial<LevelConfig>): Level {
    const config = { ...this.THEME_CONFIGS[theme], ...customConfig }
    const level = new Level(config)
    
    // 生成地形
    const terrainSegments = this.generateTerrain(config)
    level.setTerrain(terrainSegments)
    
    // 生成背景元素
    const backgroundElements = this.generateBackgroundElements(config)
    level.setBackgroundElements(backgroundElements)
    
    return level
  }

  // 生成地形
  private static generateTerrain(config: LevelConfig): TerrainSegment[] {
    const segments: TerrainSegment[] = []
    const segmentLength = 200
    const segmentCount = Math.ceil(config.length / segmentLength)
    
    for (let i = 0; i < segmentCount; i++) {
      const startX = i * segmentLength
      const endX = startX + segmentLength
      
      // 根据主题和难度选择地形类型
      const terrainType = this.selectTerrainType(config, i / segmentCount)
      const height = this.calculateTerrainHeight(terrainType, config)
      
      const segment: TerrainSegment = {
        type: terrainType,
        startX,
        endX,
        height,
        obstacles: this.generateObstaclesForSegment(config, startX, endX, height),
        items: this.generateItemsForSegment(config, startX, endX, height)
      }
      
      segments.push(segment)
    }
    
    return segments
  }

  // 选择地形类型
  private static selectTerrainType(config: LevelConfig, progress: number): TerrainType {
    const random = Math.random()
    
    // 根据进度增加难度
    if (progress < 0.3) {
      return random < 0.7 ? TerrainType.FLAT : TerrainType.HILL
    } else if (progress < 0.6) {
      if (random < 0.4) return TerrainType.FLAT
      if (random < 0.7) return TerrainType.HILL
      if (random < 0.9) return TerrainType.PLATFORM
      return TerrainType.VALLEY
    } else {
      if (random < 0.2) return TerrainType.FLAT
      if (random < 0.4) return TerrainType.HILL
      if (random < 0.6) return TerrainType.PLATFORM
      if (random < 0.8) return TerrainType.VALLEY
      return TerrainType.GAP
    }
  }

  // 计算地形高度
  private static calculateTerrainHeight(type: TerrainType, config: LevelConfig): number {
    const baseHeight = 500
    
    switch (type) {
      case TerrainType.FLAT:
        return baseHeight
      case TerrainType.HILL:
        return baseHeight - 50 - Math.random() * 100
      case TerrainType.VALLEY:
        return baseHeight + 50 + Math.random() * 100
      case TerrainType.PLATFORM:
        return baseHeight - 100 - Math.random() * 150
      case TerrainType.GAP:
        return baseHeight + 200 // 深坑
      default:
        return baseHeight
    }
  }

  // 为地形段生成障碍物
  private static generateObstaclesForSegment(config: LevelConfig, startX: number, endX: number, height: number): ObstacleConfig[] {
    const obstacles: ObstacleConfig[] = []
    const segmentLength = endX - startX
    const obstacleCount = Math.floor(segmentLength * config.obstacleFrequency / 100)
    
    for (let i = 0; i < obstacleCount; i++) {
      const x = startX + Math.random() * segmentLength
      const obstacleType = this.selectObstacleType(config.theme)
      const size = this.getObstacleSize(obstacleType)
      
      obstacles.push({
        type: obstacleType,
        x,
        y: height - size.height,
        width: size.width,
        height: size.height
      })
    }
    
    return obstacles
  }

  // 选择障碍物类型
  private static selectObstacleType(theme: MapTheme): ObstacleType {
    const themeObstacles = {
      [MapTheme.FOREST]: [ObstacleType.STATIC_BLOCK, ObstacleType.MOVING_PLATFORM],
      [MapTheme.DESERT]: [ObstacleType.STATIC_BLOCK, ObstacleType.SPIKE],
      [MapTheme.SNOW]: [ObstacleType.STATIC_BLOCK, ObstacleType.HOLE, ObstacleType.MOVING_PLATFORM],
      [MapTheme.CITY]: [ObstacleType.WALL, ObstacleType.SPIKE, ObstacleType.MOVING_PLATFORM]
    }
    
    const availableTypes = themeObstacles[theme]
    return availableTypes[Math.floor(Math.random() * availableTypes.length)]
  }

  // 获取障碍物大小
  private static getObstacleSize(type: ObstacleType): { width: number, height: number } {
    switch (type) {
      case ObstacleType.STATIC_BLOCK:
        return { width: 30 + Math.random() * 20, height: 30 + Math.random() * 20 }
      case ObstacleType.SPIKE:
        return { width: 40, height: 20 }
      case ObstacleType.WALL:
        return { width: 20, height: 80 + Math.random() * 40 }
      case ObstacleType.MOVING_PLATFORM:
        return { width: 80, height: 20 }
      case ObstacleType.HOLE:
        return { width: 60 + Math.random() * 40, height: 100 }
      default:
        return { width: 30, height: 30 }
    }
  }

  // 为地形段生成道具
  private static generateItemsForSegment(config: LevelConfig, startX: number, endX: number, height: number): ItemConfig[] {
    const items: ItemConfig[] = []
    const segmentLength = endX - startX
    const itemCount = Math.floor(segmentLength * config.itemFrequency / 100)
    
    for (let i = 0; i < itemCount; i++) {
      const x = startX + Math.random() * segmentLength
      const y = height - 50 - Math.random() * 100
      const itemType = this.selectItemType()
      
      items.push({
        type: itemType,
        x,
        y
      })
    }
    
    return items
  }

  // 选择道具类型
  private static selectItemType(): ItemType {
    const types = Object.values(ItemType)
    const weights = [0.5, 0.15, 0.15, 0.1, 0.1] // 金币概率最高
    
    const random = Math.random()
    let cumulative = 0
    
    for (let i = 0; i < types.length; i++) {
      cumulative += weights[i]
      if (random <= cumulative) {
        return types[i]
      }
    }
    
    return ItemType.COIN
  }

  // 生成背景元素
  private static generateBackgroundElements(config: LevelConfig): BackgroundElement[] {
    const elements: BackgroundElement[] = []
    const elementCount = Math.floor(config.length / 100)
    
    for (let i = 0; i < elementCount; i++) {
      const x = Math.random() * config.length
      const y = 100 + Math.random() * 300
      const elementType = config.backgroundElements[Math.floor(Math.random() * config.backgroundElements.length)]
      const layer = Math.floor(Math.random() * 3) + 1
      const size = this.getBackgroundElementSize(elementType)
      
      elements.push(new BackgroundElement(x, y, size.width, size.height, elementType, layer))
    }
    
    return elements
  }

  // 获取背景元素大小
  private static getBackgroundElementSize(type: string): { width: number, height: number } {
    switch (type) {
      case 'tree':
      case 'pine_tree':
        return { width: 60 + Math.random() * 40, height: 80 + Math.random() * 60 }
      case 'building':
        return { width: 80 + Math.random() * 120, height: 150 + Math.random() * 200 }
      case 'cactus':
        return { width: 30 + Math.random() * 20, height: 60 + Math.random() * 40 }
      default:
        return { width: 40 + Math.random() * 20, height: 40 + Math.random() * 20 }
    }
  }
}

// 关卡类
export class Level {
  config: LevelConfig
  terrain: TerrainSegment[] = []
  backgroundElements: BackgroundElement[] = []
  gameObjects: GameObject[] = []

  constructor(config: LevelConfig) {
    this.config = config
  }

  setTerrain(terrain: TerrainSegment[]): void {
    this.terrain = terrain
    this.generateGameObjects()
  }

  setBackgroundElements(elements: BackgroundElement[]): void {
    this.backgroundElements = elements
  }

  // 根据地形生成游戏对象
  private generateGameObjects(): void {
    this.gameObjects = []
    
    for (const segment of this.terrain) {
      // 生成地面
      const ground = new Ground(segment.startX, segment.height, segment.endX - segment.startX, 50)
      this.gameObjects.push(ground)
      
      // 生成障碍物
      for (const obstacleConfig of segment.obstacles) {
        const obstacle = new Obstacle(
          obstacleConfig.x,
          obstacleConfig.y,
          obstacleConfig.width,
          obstacleConfig.height,
          obstacleConfig.type
        )
        this.gameObjects.push(obstacle)
      }
      
      // 生成道具
      for (const itemConfig of segment.items) {
        const item = new Item(itemConfig.x, itemConfig.y, itemConfig.type)
        this.gameObjects.push(item)
      }
    }
  }

  // 渲染关卡
  render(context: CanvasRenderingContext2D, cameraX: number): void {
    // 渲染背景
    this.renderBackground(context, cameraX)
    
    // 渲染背景元素（按层级排序）
    const sortedElements = this.backgroundElements.sort((a, b) => a.layer - b.layer)
    for (const element of sortedElements) {
      element.render(context, cameraX, this.config.theme)
    }
  }

  // 渲染背景
  private renderBackground(context: CanvasRenderingContext2D, cameraX: number): void {
    const gradient = context.createLinearGradient(0, 0, 0, 600)
    
    switch (this.config.theme) {
      case MapTheme.FOREST:
        gradient.addColorStop(0, '#87CEEB') // 天蓝色
        gradient.addColorStop(1, '#98FB98') // 淡绿色
        break
      case MapTheme.DESERT:
        gradient.addColorStop(0, '#FFE4B5') // 浅黄色
        gradient.addColorStop(1, '#DEB887') // 深黄色
        break
      case MapTheme.SNOW:
        gradient.addColorStop(0, '#B0E0E6') // 粉蓝色
        gradient.addColorStop(1, '#F0F8FF') // 雪白色
        break
      case MapTheme.CITY:
        gradient.addColorStop(0, '#2F4F4F') // 深灰色
        gradient.addColorStop(1, '#696969') // 灰色
        break
    }
    
    context.fillStyle = gradient
    context.fillRect(cameraX, 0, 800, 600)
  }

  // 获取关卡中的游戏对象
  getGameObjects(): GameObject[] {
    return this.gameObjects
  }

  // 获取关卡长度
  getLength(): number {
    return this.config.length
  }

  // 获取关卡主题
  getTheme(): MapTheme {
    return this.config.theme
  }
}

// 关卡管理器
export class LevelManager {
  private currentLevel: Level | null = null
  private currentTheme: MapTheme = MapTheme.FOREST
  private levelProgress: number = 0
  private unlockedThemes: Set<MapTheme> = new Set([MapTheme.FOREST])

  constructor() {
    this.generateLevel(MapTheme.FOREST)
  }

  // 生成新关卡
  generateLevel(theme: MapTheme): void {
    if (!this.unlockedThemes.has(theme)) {
      console.warn(`主题 ${theme} 尚未解锁`)
      return
    }
    
    this.currentTheme = theme
    this.currentLevel = LevelGenerator.generateLevel(theme)
    this.levelProgress = 0
  }

  // 获取当前关卡
  getCurrentLevel(): Level | null {
    return this.currentLevel
  }

  // 更新关卡进度
  updateProgress(distance: number): void {
    if (!this.currentLevel) return
    
    this.levelProgress = distance / this.currentLevel.getLength()
    
    // 检查是否需要解锁新主题
    this.checkThemeUnlock()
  }

  // 检查主题解锁
  private checkThemeUnlock(): void {
    if (this.levelProgress >= 1.0) {
      switch (this.currentTheme) {
        case MapTheme.FOREST:
          this.unlockedThemes.add(MapTheme.DESERT)
          break
        case MapTheme.DESERT:
          this.unlockedThemes.add(MapTheme.SNOW)
          break
        case MapTheme.SNOW:
          this.unlockedThemes.add(MapTheme.CITY)
          break
      }
    }
  }

  // 获取已解锁的主题
  getUnlockedThemes(): MapTheme[] {
    return Array.from(this.unlockedThemes)
  }

  // 获取当前主题
  getCurrentTheme(): MapTheme {
    return this.currentTheme
  }

  // 获取关卡进度
  getProgress(): number {
    return this.levelProgress
  }

  // 进入下一关
  nextLevel(): void {
    // 播放升级音效
    AudioHelper.playLevelUp()
    
    // 切换到下一个主题（如果已解锁）
    const themes = [MapTheme.FOREST, MapTheme.DESERT, MapTheme.SNOW, MapTheme.CITY]
    const currentIndex = themes.indexOf(this.currentTheme)
    
    if (currentIndex < themes.length - 1) {
      const nextTheme = themes[currentIndex + 1]
      if (this.unlockedThemes.has(nextTheme)) {
        this.generateLevel(nextTheme)
      } else {
        // 如果下一个主题未解锁，重新生成当前主题的关卡
        this.generateLevel(this.currentTheme)
      }
    } else {
      // 如果已经是最后一个主题，重新生成当前主题的关卡
      this.generateLevel(this.currentTheme)
    }
  }

  // 重置关卡管理器
  reset(): void {
    this.currentLevel = null
    this.currentTheme = MapTheme.FOREST
    this.levelProgress = 0
    this.unlockedThemes = new Set([MapTheme.FOREST])
    this.generateLevel(MapTheme.FOREST)
  }
}

// 导出单例关卡管理器
export const levelManager = new LevelManager()