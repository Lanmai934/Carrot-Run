// 游戏配置类
export class GameConfig {
  // 游戏基础设置
  public static readonly GAME_WIDTH = 360;
  public static readonly GAME_HEIGHT = 640;
  public static readonly FPS = 60;

  // 物理参数
  public static readonly GRAVITY = 0.8;
  public static readonly JUMP_FORCE = -15;
  public static readonly GROUND_LEVEL = 500;
  public static readonly GAME_SPEED = 3;

  // 角色参数
  public static readonly CARROT_WIDTH = 40;
  public static readonly CARROT_HEIGHT = 60;
  public static readonly CARROT_START_X = 80;
  public static readonly CARROT_START_Y = 440;

  // 道具参数
  public static readonly ITEM_WIDTH = 30;
  public static readonly ITEM_HEIGHT = 30;
  public static readonly COIN_VALUE = 10;

  // 障碍物参数
  public static readonly OBSTACLE_WIDTH = 40;
  public static readonly OBSTACLE_HEIGHT = 60;
  public static readonly OBSTACLE_SPAWN_DISTANCE = 200;

  // 游戏难度设置
  public static readonly DIFFICULTY_INCREASE_INTERVAL = 30000; // 30秒增加一次难度
  public static readonly MAX_GAME_SPEED = 8;
  public static readonly SPEED_INCREASE_RATE = 0.2;

  // 音效设置
  public static readonly MASTER_VOLUME = 0.8;
  public static readonly MUSIC_VOLUME = 0.6;
  public static readonly SFX_VOLUME = 0.8;

  // 颜色配置
  public static readonly COLORS = {
    PRIMARY: '#FF6B35',
    SECONDARY: '#F7931E',
    BACKGROUND: '#87CEEB',
    GROUND: '#8B4513',
    TEXT: '#FFFFFF',
    SHADOW: '#000000'
  };

  // 关卡主题配置
  public static readonly LEVEL_THEMES = {
    FOREST: {
      name: '森林',
      backgroundColor: '#228B22',
      groundColor: '#8B4513',
      obstacleColor: '#654321'
    },
    DESERT: {
      name: '沙漠',
      backgroundColor: '#F4A460',
      groundColor: '#DEB887',
      obstacleColor: '#8B4513'
    },
    SNOW: {
      name: '雪山',
      backgroundColor: '#B0E0E6',
      groundColor: '#FFFFFF',
      obstacleColor: '#708090'
    },
    CITY: {
      name: '城市',
      backgroundColor: '#4682B4',
      groundColor: '#696969',
      obstacleColor: '#2F4F4F'
    }
  };

  // 角色类型配置
  public static readonly CHARACTER_TYPES = {
    SPEED_CARROT: {
      name: '速度萝卜',
      speed: 1.2,
      jump: 1.0,
      special: 'speed_boost'
    },
    JUMP_CARROT: {
      name: '跳跃萝卜',
      speed: 1.0,
      jump: 1.3,
      special: 'double_jump'
    },
    TANK_CARROT: {
      name: '坦克萝卜',
      speed: 0.8,
      jump: 0.9,
      special: 'shield'
    },
    LUCKY_CARROT: {
      name: '幸运萝卜',
      speed: 1.0,
      jump: 1.0,
      special: 'coin_magnet'
    }
  };

  // 道具类型配置
  public static readonly ITEM_TYPES = {
    SPEED_BOOST: {
      name: '加速道具',
      duration: 5000,
      effect: 'speed'
    },
    SHIELD: {
      name: '保护盾',
      duration: 8000,
      effect: 'protection'
    },
    MAGNET: {
      name: '吸铁石',
      duration: 6000,
      effect: 'coin_magnet'
    },
    DOUBLE_JUMP: {
      name: '二段跳',
      duration: 10000,
      effect: 'double_jump'
    }
  };
}