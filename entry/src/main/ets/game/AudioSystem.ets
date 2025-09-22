import media from '@ohos.multimedia.media'
import { GameConfig } from '../common/GameConfig'

// 音效类型枚举
export enum AudioType {
  BACKGROUND_MUSIC = 'background_music',
  JUMP = 'jump',
  COLLECT_COIN = 'collect_coin',
  COLLECT_ITEM = 'collect_item',
  LEVEL_UP = 'level_up',
  GAME_OVER = 'game_over',
  BUTTON_CLICK = 'button_click',
  POWER_UP = 'power_up',
  HURT = 'hurt'
}

// 音频配置接口
interface AudioConfig {
  src: string
  loop: boolean
  volume: number
  category: 'music' | 'sfx'
}

// 音频实例接口
interface AudioInstance {
  player: media.AVPlayer | null
  config: AudioConfig
  isLoaded: boolean
  isPlaying: boolean
}

// 音效管理器类
class AudioManager {
  private static instance: AudioManager
  private audioInstances: Map<AudioType, AudioInstance> = new Map()
  private musicEnabled: boolean = true
  private sfxEnabled: boolean = true
  private musicVolume: number = 0.7
  private sfxVolume: number = 0.8
  private currentBackgroundMusic: AudioType | null = null

  // 音频资源配置
  private audioConfigs: Map<AudioType, AudioConfig> = new Map([
    [AudioType.BACKGROUND_MUSIC, {
      src: 'resources/audio/background_music.mp3',
      loop: true,
      volume: 0.6,
      category: 'music'
    }],
    [AudioType.JUMP, {
      src: 'resources/audio/jump.wav',
      loop: false,
      volume: 0.7,
      category: 'sfx'
    }],
    [AudioType.COLLECT_COIN, {
      src: 'resources/audio/collect_coin.wav',
      loop: false,
      volume: 0.8,
      category: 'sfx'
    }],
    [AudioType.COLLECT_ITEM, {
      src: 'resources/audio/collect_item.wav',
      loop: false,
      volume: 0.8,
      category: 'sfx'
    }],
    [AudioType.LEVEL_UP, {
      src: 'resources/audio/level_up.wav',
      loop: false,
      volume: 0.9,
      category: 'sfx'
    }],
    [AudioType.GAME_OVER, {
      src: 'resources/audio/game_over.wav',
      loop: false,
      volume: 0.8,
      category: 'sfx'
    }],
    [AudioType.BUTTON_CLICK, {
      src: 'resources/audio/button_click.wav',
      loop: false,
      volume: 0.5,
      category: 'sfx'
    }],
    [AudioType.POWER_UP, {
      src: 'resources/audio/power_up.wav',
      loop: false,
      volume: 0.8,
      category: 'sfx'
    }],
    [AudioType.HURT, {
      src: 'resources/audio/hurt.wav',
      loop: false,
      volume: 0.7,
      category: 'sfx'
    }]
  ])

  private constructor() {
    this.initializeAudio()
  }

  public static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager()
    }
    return AudioManager.instance
  }

  // 初始化音频系统
  private async initializeAudio(): Promise<void> {
    try {
      // 预加载关键音效
      await this.preloadAudio(AudioType.BACKGROUND_MUSIC)
      await this.preloadAudio(AudioType.JUMP)
      await this.preloadAudio(AudioType.COLLECT_COIN)
      await this.preloadAudio(AudioType.BUTTON_CLICK)
      
      console.log('音频系统初始化完成')
    } catch (error) {
      console.error('音频系统初始化失败:', error)
    }
  }

  // 预加载音频
  private async preloadAudio(audioType: AudioType): Promise<void> {
    const config = this.audioConfigs.get(audioType)
    if (!config) return

    try {
      const player = await media.createAVPlayer()
      
      const audioInstance: AudioInstance = {
        player: player,
        config: config,
        isLoaded: false,
        isPlaying: false
      }

      // 设置播放器事件监听
      player.on('stateChange', (state) => {
        console.log(`音频 ${audioType} 状态变化: ${state}`)
        if (state === 'prepared') {
          audioInstance.isLoaded = true
        }
      })

      player.on('error', (error) => {
        console.error(`音频 ${audioType} 播放错误:`, error)
      })

      // 设置音频源（这里使用占位符，实际项目中需要真实的音频文件）
      // player.url = config.src
      
      this.audioInstances.set(audioType, audioInstance)
    } catch (error) {
      console.error(`预加载音频 ${audioType} 失败:`, error)
    }
  }

  // 播放音效
  public async playSound(audioType: AudioType, volume?: number): Promise<void> {
    try {
      // 检查音效是否启用
      const config = this.audioConfigs.get(audioType)
      if (!config) return

      if (config.category === 'music' && !this.musicEnabled) return
      if (config.category === 'sfx' && !this.sfxEnabled) return

      let audioInstance = this.audioInstances.get(audioType)
      
      // 如果音频未预加载，则动态加载
      if (!audioInstance) {
        await this.preloadAudio(audioType)
        audioInstance = this.audioInstances.get(audioType)
      }

      if (!audioInstance || !audioInstance.player) return

      // 设置音量
      const finalVolume = volume ?? config.volume
      const categoryVolume = config.category === 'music' ? this.musicVolume : this.sfxVolume
      // audioInstance.player.volume = finalVolume * categoryVolume

      // 播放音频
      if (config.loop) {
        // audioInstance.player.loop = true
      }

      // await audioInstance.player.play()
      audioInstance.isPlaying = true

      // 对于非循环音频，播放完成后重置状态
      if (!config.loop) {
        setTimeout(() => {
          if (audioInstance) {
            audioInstance.isPlaying = false
          }
        }, 1000) // 假设音效时长不超过1秒
      }

      console.log(`播放音效: ${audioType}`)
    } catch (error) {
      console.error(`播放音效 ${audioType} 失败:`, error)
    }
  }

  // 停止音效
  public async stopSound(audioType: AudioType): Promise<void> {
    try {
      const audioInstance = this.audioInstances.get(audioType)
      if (!audioInstance || !audioInstance.player) return

      // await audioInstance.player.stop()
      audioInstance.isPlaying = false
      
      console.log(`停止音效: ${audioType}`)
    } catch (error) {
      console.error(`停止音效 ${audioType} 失败:`, error)
    }
  }

  // 播放背景音乐
  public async playBackgroundMusic(audioType: AudioType = AudioType.BACKGROUND_MUSIC): Promise<void> {
    if (this.currentBackgroundMusic === audioType) return

    // 停止当前背景音乐
    if (this.currentBackgroundMusic) {
      await this.stopSound(this.currentBackgroundMusic)
    }

    // 播放新的背景音乐
    await this.playSound(audioType)
    this.currentBackgroundMusic = audioType
  }

  // 停止背景音乐
  public async stopBackgroundMusic(): Promise<void> {
    if (this.currentBackgroundMusic) {
      await this.stopSound(this.currentBackgroundMusic)
      this.currentBackgroundMusic = null
    }
  }

  // 暂停所有音频
  public async pauseAll(): Promise<void> {
    for (const [audioType, audioInstance] of this.audioInstances) {
      if (audioInstance.isPlaying && audioInstance.player) {
        try {
          // await audioInstance.player.pause()
          console.log(`暂停音效: ${audioType}`)
        } catch (error) {
          console.error(`暂停音效 ${audioType} 失败:`, error)
        }
      }
    }
  }

  // 恢复所有音频
  public async resumeAll(): Promise<void> {
    for (const [audioType, audioInstance] of this.audioInstances) {
      if (audioInstance.isPlaying && audioInstance.player) {
        try {
          // await audioInstance.player.play()
          console.log(`恢复音效: ${audioType}`)
        } catch (error) {
          console.error(`恢复音效 ${audioType} 失败:`, error)
        }
      }
    }
  }

  // 设置音乐开关
  public setMusicEnabled(enabled: boolean): void {
    this.musicEnabled = enabled
    if (!enabled && this.currentBackgroundMusic) {
      this.stopBackgroundMusic()
    } else if (enabled && !this.currentBackgroundMusic) {
      this.playBackgroundMusic()
    }
  }

  // 设置音效开关
  public setSfxEnabled(enabled: boolean): void {
    this.sfxEnabled = enabled
  }

  // 设置音乐音量
  public setMusicVolume(volume: number): void {
    this.musicVolume = Math.max(0, Math.min(1, volume))
    
    // 更新当前播放的背景音乐音量
    if (this.currentBackgroundMusic) {
      const audioInstance = this.audioInstances.get(this.currentBackgroundMusic)
      if (audioInstance && audioInstance.player) {
        const config = audioInstance.config
        // audioInstance.player.volume = config.volume * this.musicVolume
      }
    }
  }

  // 设置音效音量
  public setSfxVolume(volume: number): void {
    this.sfxVolume = Math.max(0, Math.min(1, volume))
  }

  // 获取音乐开关状态
  public isMusicEnabled(): boolean {
    return this.musicEnabled
  }

  // 获取音效开关状态
  public isSfxEnabled(): boolean {
    return this.sfxEnabled
  }

  // 获取音乐音量
  public getMusicVolume(): number {
    return this.musicVolume
  }

  // 获取音效音量
  public getSfxVolume(): number {
    return this.sfxVolume
  }

  // 释放资源
  public async dispose(): Promise<void> {
    for (const [audioType, audioInstance] of this.audioInstances) {
      if (audioInstance.player) {
        try {
          // await audioInstance.player.release()
          console.log(`释放音频资源: ${audioType}`)
        } catch (error) {
          console.error(`释放音频资源 ${audioType} 失败:`, error)
        }
      }
    }
    this.audioInstances.clear()
    this.currentBackgroundMusic = null
  }
}

// 导出音效管理器单例
export const audioManager = AudioManager.getInstance()

// 便捷的音效播放函数
export class AudioHelper {
  // 播放按钮点击音效
  static playButtonClick(): void {
    audioManager.playSound(AudioType.BUTTON_CLICK)
  }

  // 播放跳跃音效
  static playJump(): void {
    audioManager.playSound(AudioType.JUMP)
  }

  // 播放收集金币音效
  static playCoinCollect(): void {
    audioManager.playSound(AudioType.COLLECT_COIN)
  }

  // 播放收集道具音效
  static playItemCollect(): void {
    audioManager.playSound(AudioType.COLLECT_ITEM)
  }

  // 播放升级音效
  static playLevelUp(): void {
    audioManager.playSound(AudioType.LEVEL_UP)
  }

  // 播放游戏结束音效
  static playGameOver(): void {
    audioManager.playSound(AudioType.GAME_OVER)
  }

  // 播放道具激活音效
  static playPowerUp(): void {
    audioManager.playSound(AudioType.POWER_UP)
  }

  // 播放受伤音效
  static playHurt(): void {
    audioManager.playSound(AudioType.HURT)
  }

  // 开始背景音乐
  static startBackgroundMusic(): void {
    audioManager.playBackgroundMusic()
  }

  // 停止背景音乐
  static stopBackgroundMusic(): void {
    audioManager.stopBackgroundMusic()
  }
}