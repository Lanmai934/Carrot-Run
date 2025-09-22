// 通用UI组件库
import { GameConfig } from './GameConfig'

// 按钮样式枚举
export enum ButtonStyle {
  PRIMARY = 'primary',
  SECONDARY = 'secondary',
  SUCCESS = 'success',
  WARNING = 'warning',
  DANGER = 'danger',
  TRANSPARENT = 'transparent'
}

// 按钮大小枚举
export enum ButtonSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

// 游戏按钮组件
@Component
export struct GameButton {
  @Prop text: string = ''
  @Prop style: ButtonStyle = ButtonStyle.PRIMARY
  @Prop size: ButtonSize = ButtonSize.MEDIUM
  @Prop disabled: boolean = false
  @Prop icon?: string
  @Prop width?: number | string
  @Prop height?: number | string
  onClick?: () => void

  build() {
    Button() {
      Row() {
        if (this.icon) {
          Text(this.icon)
            .fontSize(this.getIconSize())
            .fontColor(this.getTextColor())
            .margin({ right: this.text ? 8 : 0 })
        }
        
        if (this.text) {
          Text(this.text)
            .fontSize(this.getTextSize())
            .fontColor(this.getTextColor())
            .fontWeight(FontWeight.Bold)
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(this.width || this.getButtonWidth())
    .height(this.height || this.getButtonHeight())
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(this.getBorderRadius())
    .border({
      width: 2,
      color: this.getBorderColor()
    })
    .shadow({
      radius: this.disabled ? 0 : 8,
      color: this.getShadowColor(),
      offsetX: 0,
      offsetY: this.disabled ? 0 : 4
    })
    .opacity(this.disabled ? 0.6 : 1)
    .enabled(!this.disabled)
    .onClick(() => {
      if (!this.disabled && this.onClick) {
        this.onClick()
      }
    })
    .animation({
      duration: 150,
      curve: Curve.EaseInOut
    })
  }

  private getButtonWidth(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return 80
      case ButtonSize.MEDIUM: return 120
      case ButtonSize.LARGE: return 160
      default: return 120
    }
  }

  private getButtonHeight(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return 32
      case ButtonSize.MEDIUM: return 44
      case ButtonSize.LARGE: return 56
      default: return 44
    }
  }

  private getTextSize(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return 12
      case ButtonSize.MEDIUM: return 16
      case ButtonSize.LARGE: return 20
      default: return 16
    }
  }

  private getIconSize(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return 14
      case ButtonSize.MEDIUM: return 18
      case ButtonSize.LARGE: return 24
      default: return 18
    }
  }

  private getBorderRadius(): number {
    switch (this.size) {
      case ButtonSize.SMALL: return 16
      case ButtonSize.MEDIUM: return 22
      case ButtonSize.LARGE: return 28
      default: return 22
    }
  }

  private getBackgroundColor(): string {
    switch (this.style) {
      case ButtonStyle.PRIMARY: return GameConfig.COLORS.PRIMARY
      case ButtonStyle.SECONDARY: return GameConfig.COLORS.SECONDARY
      case ButtonStyle.SUCCESS: return '#28a745'
      case ButtonStyle.WARNING: return '#ffc107'
      case ButtonStyle.DANGER: return '#dc3545'
      case ButtonStyle.TRANSPARENT: return 'rgba(255,255,255,0.1)'
      default: return GameConfig.COLORS.PRIMARY
    }
  }

  private getBorderColor(): string {
    switch (this.style) {
      case ButtonStyle.TRANSPARENT: return 'rgba(255,255,255,0.3)'
      default: return this.getBackgroundColor()
    }
  }

  private getTextColor(): string {
    switch (this.style) {
      case ButtonStyle.WARNING: return '#000000'
      default: return '#FFFFFF'
    }
  }

  private getShadowColor(): string {
    return this.getBackgroundColor() + '40'
  }
}

// 游戏面板组件
@Component
export struct GamePanel {
  @Prop title?: string
  @Prop showCloseButton: boolean = false
  @Prop backgroundColor: string = 'rgba(0,0,0,0.8)'
  @Prop borderRadius: number = 16
  @Prop padding: number = 20
  @BuilderParam content: () => void
  onClose?: () => void

  build() {
    Column() {
      // 标题栏
      if (this.title || this.showCloseButton) {
        Row() {
          if (this.title) {
            Text(this.title)
              .fontSize(24)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          
          Blank()
          
          if (this.showCloseButton) {
            Button() {
              Text('×')
                .fontSize(24)
                .fontColor(Color.White)
            }
            .width(32)
            .height(32)
            .backgroundColor('rgba(255,255,255,0.2)')
            .borderRadius(16)
            .onClick(() => {
              if (this.onClose) {
                this.onClose()
              }
            })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })
      }
      
      // 内容区域
      this.content()
    }
    .width('90%')
    .maxWidth(400)
    .backgroundColor(this.backgroundColor)
    .borderRadius(this.borderRadius)
    .padding(this.padding)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.5)',
      offsetX: 0,
      offsetY: 8
    })
  }
}

// 进度条组件
@Component
export struct GameProgressBar {
  @Prop current: number = 0
  @Prop max: number = 100
  @Prop width: number = 200
  @Prop height: number = 8
  @Prop backgroundColor: string = 'rgba(255,255,255,0.3)'
  @Prop progressColor: string = GameConfig.COLORS.PRIMARY
  @Prop showText: boolean = false
  @Prop text?: string

  build() {
    Column() {
      if (this.showText && this.text) {
        Text(this.text)
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ bottom: 4 })
      }
      
      Stack() {
        // 背景
        Rectangle()
          .width(this.width)
          .height(this.height)
          .fill(this.backgroundColor)
          .borderRadius(this.height / 2)
        
        // 进度
        Rectangle()
          .width(this.width * Math.min(this.current / this.max, 1))
          .height(this.height)
          .fill(this.progressColor)
          .borderRadius(this.height / 2)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }
      .alignContent(Alignment.Start)
      
      if (this.showText && !this.text) {
        Text(`${Math.round(this.current)}/${this.max}`)
          .fontSize(10)
          .fontColor(Color.White)
          .margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}

// 游戏图标组件
@Component
export struct GameIcon {
  @Prop icon: string = ''
  @Prop size: number = 24
  @Prop color: string = Color.White
  @Prop backgroundColor?: string
  @Prop borderRadius?: number
  @Prop padding?: number

  build() {
    Stack() {
      if (this.backgroundColor) {
        Circle({ width: this.size + (this.padding || 0) * 2, height: this.size + (this.padding || 0) * 2 })
          .fill(this.backgroundColor)
      }
      
      Text(this.icon)
        .fontSize(this.size)
        .fontColor(this.color)
    }
    .borderRadius(this.borderRadius || 0)
  }
}

// 游戏统计卡片组件
@Component
export struct GameStatCard {
  @Prop title: string = ''
  @Prop value: string | number = ''
  @Prop icon?: string
  @Prop color: string = GameConfig.COLORS.PRIMARY
  @Prop width: number = 100

  build() {
    Column() {
      if (this.icon) {
        GameIcon({
          icon: this.icon,
          size: 24,
          color: this.color,
          backgroundColor: this.color + '20',
          padding: 8,
          borderRadius: 20
        })
        .margin({ bottom: 8 })
      }
      
      Text(this.value.toString())
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 })
      
      Text(this.title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.7)')
        .textAlign(TextAlign.Center)
    }
    .width(this.width)
    .padding(12)
    .backgroundColor('rgba(255,255,255,0.1)')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// 游戏列表项组件
@Component
export struct GameListItem {
  @Prop title: string = ''
  @Prop subtitle?: string
  @Prop icon?: string
  @Prop rightText?: string
  @Prop rightIcon?: string
  @Prop showArrow: boolean = false
  @Prop disabled: boolean = false
  onClick?: () => void

  build() {
    Row() {
      // 左侧图标
      if (this.icon) {
        GameIcon({
          icon: this.icon,
          size: 20,
          backgroundColor: GameConfig.COLORS.PRIMARY + '20',
          padding: 8,
          borderRadius: 16
        })
        .margin({ right: 12 })
      }
      
      // 中间内容
      Column() {
        Text(this.title)
          .fontSize(16)
          .fontColor(this.disabled ? 'rgba(255,255,255,0.5)' : Color.White)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .width('100%')
        
        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.7)')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      // 右侧内容
      Row() {
        if (this.rightText) {
          Text(this.rightText)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ right: 8 })
        }
        
        if (this.rightIcon) {
          GameIcon({
            icon: this.rightIcon,
            size: 16,
            color: 'rgba(255,255,255,0.7)'
          })
        }
        
        if (this.showArrow) {
          GameIcon({
            icon: '›',
            size: 16,
            color: 'rgba(255,255,255,0.5)'
          })
          .margin({ left: 4 })
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.disabled ? 'rgba(255,255,255,0.05)' : 'rgba(255,255,255,0.1)')
    .borderRadius(12)
    .opacity(this.disabled ? 0.6 : 1)
    .enabled(!this.disabled)
    .onClick(() => {
      if (!this.disabled && this.onClick) {
        this.onClick()
      }
    })
  }
}

// 游戏对话框组件
@Component
export struct GameDialog {
  @Prop title: string = ''
  @Prop message: string = ''
  @Prop confirmText: string = '确定'
  @Prop cancelText: string = '取消'
  @Prop showCancel: boolean = true
  @Prop visible: boolean = false
  onConfirm?: () => void
  onCancel?: () => void

  build() {
    if (this.visible) {
      Stack() {
        // 背景遮罩
        Rectangle()
          .width('100%')
          .height('100%')
          .fill('rgba(0,0,0,0.5)')
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })
        
        // 对话框内容
        GamePanel({
          title: this.title,
          backgroundColor: 'rgba(20,20,20,0.95)',
          content: () => {
            this.DialogContent()
          }
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  @Builder DialogContent() {
    Column() {
      Text(this.message)
        .fontSize(16)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })
      
      Row() {
        if (this.showCancel) {
          GameButton({
            text: this.cancelText,
            style: ButtonStyle.SECONDARY,
            size: ButtonSize.MEDIUM,
            onClick: () => {
              if (this.onCancel) {
                this.onCancel()
              }
            }
          })
          .layoutWeight(1)
          .margin({ right: 8 })
        }
        
        GameButton({
          text: this.confirmText,
          style: ButtonStyle.PRIMARY,
          size: ButtonSize.MEDIUM,
          onClick: () => {
            if (this.onConfirm) {
              this.onConfirm()
            }
          }
        })
        .layoutWeight(1)
        .margin({ left: this.showCancel ? 8 : 0 })
      }
      .width('100%')
    }
  }
}