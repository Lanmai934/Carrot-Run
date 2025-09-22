// 物理引擎 - 处理游戏中的物理计算和碰撞检测
import { GameConfig } from './GameConfig'

// 向量类
export class Vector2 {
  x: number = 0
  y: number = 0

  constructor(x: number = 0, y: number = 0) {
    this.x = x
    this.y = y
  }

  // 向量加法
  add(other: Vector2): Vector2 {
    return new Vector2(this.x + other.x, this.y + other.y)
  }

  // 向量减法
  subtract(other: Vector2): Vector2 {
    return new Vector2(this.x - other.x, this.y - other.y)
  }

  // 向量乘法
  multiply(scalar: number): Vector2 {
    return new Vector2(this.x * scalar, this.y * scalar)
  }

  // 向量长度
  magnitude(): number {
    return Math.sqrt(this.x * this.x + this.y * this.y)
  }

  // 向量归一化
  normalize(): Vector2 {
    const mag = this.magnitude()
    if (mag === 0) return new Vector2(0, 0)
    return new Vector2(this.x / mag, this.y / mag)
  }

  // 复制向量
  copy(): Vector2 {
    return new Vector2(this.x, this.y)
  }
}

// 碰撞盒类
export class CollisionBox {
  x: number = 0
  y: number = 0
  width: number = 0
  height: number = 0

  constructor(x: number, y: number, width: number, height: number) {
    this.x = x
    this.y = y
    this.width = width
    this.height = height
  }

  // 检查是否与另一个碰撞盒相交
  intersects(other: CollisionBox): boolean {
    return this.x < other.x + other.width &&
           this.x + this.width > other.x &&
           this.y < other.y + other.height &&
           this.y + this.height > other.y
  }

  // 检查点是否在碰撞盒内
  contains(x: number, y: number): boolean {
    return x >= this.x && x <= this.x + this.width &&
           y >= this.y && y <= this.y + this.height
  }

  // 获取中心点
  getCenter(): Vector2 {
    return new Vector2(this.x + this.width / 2, this.y + this.height / 2)
  }
}

// 物理体类
export class PhysicsBody {
  position: Vector2 = new Vector2()
  velocity: Vector2 = new Vector2()
  acceleration: Vector2 = new Vector2()
  collisionBox: CollisionBox = new CollisionBox(0, 0, 0, 0)
  
  // 物理属性
  mass: number = 1
  friction: number = 0.8
  restitution: number = 0.3 // 弹性系数
  isGrounded: boolean = false
  isStatic: boolean = false // 是否为静态物体

  constructor(x: number, y: number, width: number, height: number) {
    this.position = new Vector2(x, y)
    this.collisionBox = new CollisionBox(x, y, width, height)
  }

  // 更新物理状态
  update(deltaTime: number): void {
    if (this.isStatic) return

    // 应用重力
    if (!this.isGrounded) {
      this.acceleration.y += GameConfig.PHYSICS.GRAVITY
    }

    // 应用摩擦力
    this.velocity.x *= this.friction

    // 更新速度
    this.velocity = this.velocity.add(this.acceleration.multiply(deltaTime))

    // 限制最大速度
    if (Math.abs(this.velocity.x) > GameConfig.PHYSICS.MAX_VELOCITY_X) {
      this.velocity.x = Math.sign(this.velocity.x) * GameConfig.PHYSICS.MAX_VELOCITY_X
    }
    if (this.velocity.y > GameConfig.PHYSICS.MAX_VELOCITY_Y) {
      this.velocity.y = GameConfig.PHYSICS.MAX_VELOCITY_Y
    }

    // 更新位置
    this.position = this.position.add(this.velocity.multiply(deltaTime))

    // 更新碰撞盒位置
    this.collisionBox.x = this.position.x
    this.collisionBox.y = this.position.y

    // 重置加速度
    this.acceleration = new Vector2(0, 0)
  }

  // 应用力
  applyForce(force: Vector2): void {
    const acceleration = force.multiply(1 / this.mass)
    this.acceleration = this.acceleration.add(acceleration)
  }

  // 设置速度
  setVelocity(velocity: Vector2): void {
    this.velocity = velocity.copy()
  }

  // 跳跃
  jump(force: number = GameConfig.CHARACTER.JUMP_FORCE): void {
    if (this.isGrounded) {
      this.velocity.y = -force
      this.isGrounded = false
    }
  }

  // 移动
  move(direction: number, speed: number = GameConfig.CHARACTER.MOVE_SPEED): void {
    this.velocity.x = direction * speed
  }
}

// 碰撞检测结果
export interface CollisionResult {
  hasCollision: boolean
  normal: Vector2 // 碰撞法向量
  penetration: number // 穿透深度
  contactPoint: Vector2 // 接触点
}

// 物理引擎主类
export class PhysicsEngine {
  private bodies: PhysicsBody[] = []
  private staticBodies: PhysicsBody[] = []

  // 添加物理体
  addBody(body: PhysicsBody): void {
    if (body.isStatic) {
      this.staticBodies.push(body)
    } else {
      this.bodies.push(body)
    }
  }

  // 移除物理体
  removeBody(body: PhysicsBody): void {
    const index = this.bodies.indexOf(body)
    if (index > -1) {
      this.bodies.splice(index, 1)
    }
    const staticIndex = this.staticBodies.indexOf(body)
    if (staticIndex > -1) {
      this.staticBodies.splice(staticIndex, 1)
    }
  }

  // 更新物理世界
  update(deltaTime: number): void {
    // 更新所有动态物理体
    for (const body of this.bodies) {
      body.update(deltaTime)
    }

    // 检测碰撞
    this.detectCollisions()
  }

  // 碰撞检测
  private detectCollisions(): void {
    // 动态物体与静态物体的碰撞
    for (const dynamicBody of this.bodies) {
      dynamicBody.isGrounded = false
      
      for (const staticBody of this.staticBodies) {
        const result = this.checkCollision(dynamicBody, staticBody)
        if (result.hasCollision) {
          this.resolveCollision(dynamicBody, staticBody, result)
        }
      }
    }

    // 动态物体之间的碰撞
    for (let i = 0; i < this.bodies.length; i++) {
      for (let j = i + 1; j < this.bodies.length; j++) {
        const result = this.checkCollision(this.bodies[i], this.bodies[j])
        if (result.hasCollision) {
          this.resolveCollision(this.bodies[i], this.bodies[j], result)
        }
      }
    }
  }

  // 检查两个物体的碰撞
  private checkCollision(bodyA: PhysicsBody, bodyB: PhysicsBody): CollisionResult {
    const boxA = bodyA.collisionBox
    const boxB = bodyB.collisionBox

    if (!boxA.intersects(boxB)) {
      return {
        hasCollision: false,
        normal: new Vector2(),
        penetration: 0,
        contactPoint: new Vector2()
      }
    }

    // 计算重叠区域
    const overlapX = Math.min(boxA.x + boxA.width, boxB.x + boxB.width) - 
                     Math.max(boxA.x, boxB.x)
    const overlapY = Math.min(boxA.y + boxA.height, boxB.y + boxB.height) - 
                     Math.max(boxA.y, boxB.y)

    // 确定碰撞方向和穿透深度
    let normal: Vector2
    let penetration: number

    if (overlapX < overlapY) {
      // 水平碰撞
      penetration = overlapX
      normal = boxA.x < boxB.x ? new Vector2(-1, 0) : new Vector2(1, 0)
    } else {
      // 垂直碰撞
      penetration = overlapY
      normal = boxA.y < boxB.y ? new Vector2(0, -1) : new Vector2(0, 1)
    }

    // 计算接触点
    const contactPoint = new Vector2(
      Math.max(boxA.x, boxB.x) + overlapX / 2,
      Math.max(boxA.y, boxB.y) + overlapY / 2
    )

    return {
      hasCollision: true,
      normal,
      penetration,
      contactPoint
    }
  }

  // 解决碰撞
  private resolveCollision(bodyA: PhysicsBody, bodyB: PhysicsBody, result: CollisionResult): void {
    const { normal, penetration } = result

    // 位置修正
    const correction = normal.multiply(penetration / 2)
    
    if (!bodyA.isStatic) {
      bodyA.position = bodyA.position.subtract(correction)
      bodyA.collisionBox.x = bodyA.position.x
      bodyA.collisionBox.y = bodyA.position.y
    }
    
    if (!bodyB.isStatic) {
      bodyB.position = bodyB.position.add(correction)
      bodyB.collisionBox.x = bodyB.position.x
      bodyB.collisionBox.y = bodyB.position.y
    }

    // 速度修正
    if (!bodyA.isStatic) {
      // 检查是否着地
      if (normal.y < 0 && bodyA.velocity.y > 0) {
        bodyA.isGrounded = true
        bodyA.velocity.y = 0
      }
      
      // 反弹效果
      const relativeVelocity = bodyA.velocity.subtract(bodyB.velocity)
      const velocityAlongNormal = relativeVelocity.x * normal.x + relativeVelocity.y * normal.y
      
      if (velocityAlongNormal > 0) return // 物体正在分离
      
      const restitution = Math.min(bodyA.restitution, bodyB.restitution)
      const impulse = -(1 + restitution) * velocityAlongNormal
      const impulseVector = normal.multiply(impulse)
      
      bodyA.velocity = bodyA.velocity.add(impulseVector)
    }
  }

  // 射线检测
  raycast(start: Vector2, direction: Vector2, maxDistance: number): PhysicsBody | null {
    const normalizedDirection = direction.normalize()
    const end = start.add(normalizedDirection.multiply(maxDistance))
    
    let closestBody: PhysicsBody | null = null
    let closestDistance = maxDistance
    
    // 检查所有物理体
    const allBodies = [...this.bodies, ...this.staticBodies]
    
    for (const body of allBodies) {
      const intersection = this.lineIntersectsBox(start, end, body.collisionBox)
      if (intersection) {
        const distance = start.subtract(intersection).magnitude()
        if (distance < closestDistance) {
          closestDistance = distance
          closestBody = body
        }
      }
    }
    
    return closestBody
  }

  // 直线与矩形相交检测
  private lineIntersectsBox(start: Vector2, end: Vector2, box: CollisionBox): Vector2 | null {
    const minX = Math.min(start.x, end.x)
    const maxX = Math.max(start.x, end.x)
    const minY = Math.min(start.y, end.y)
    const maxY = Math.max(start.y, end.y)
    
    if (maxX < box.x || minX > box.x + box.width ||
        maxY < box.y || minY > box.y + box.height) {
      return null
    }
    
    // 简化处理，返回起点（实际应该计算精确交点）
    return start.copy()
  }

  // 清空所有物理体
  clear(): void {
    this.bodies = []
    this.staticBodies = []
  }

  // 获取所有物理体
  getAllBodies(): PhysicsBody[] {
    return [...this.bodies, ...this.staticBodies]
  }
}

// 导出单例物理引擎
export const physicsEngine = new PhysicsEngine()