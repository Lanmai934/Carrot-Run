// 简单的语法验证脚本
const fs = require('fs');
const path = require('path');

// 检查关键文件是否存在语法错误
const filesToCheck = [
  'entry/src/main/ets/common/ItemSystem.ets',
  'entry/src/main/ets/common/GameWorld.ets',
  'entry/src/main/ets/common/LevelSystem.ets',
  'entry/src/main/ets/common/Character.ets',
  'entry/src/main/ets/pages/GamePage.ets'
];

console.log('验证 ItemType 重复定义修复...');

filesToCheck.forEach(file => {
  const fullPath = path.join(__dirname, file);
  if (fs.existsSync(fullPath)) {
    const content = fs.readFileSync(fullPath, 'utf8');
    
    // 检查是否有重复的 ItemType 定义
    const enumMatches = content.match(/enum\s+ItemType/g);
    if (enumMatches && enumMatches.length > 0) {
      if (file.includes('ItemSystem.ets')) {
        console.log(`✓ ${file}: 正确包含 ItemType 定义`);
      } else {
        console.log(`✗ ${file}: 发现重复的 ItemType 定义`);
      }
    }
    
    // 检查导入语句
    const importMatches = content.match(/import.*ItemType.*from.*ItemSystem/);
    if (importMatches && !file.includes('ItemSystem.ets')) {
      console.log(`✓ ${file}: 正确导入 ItemType`);
    }
  } else {
    console.log(`✗ 文件不存在: ${file}`);
  }
});

console.log('验证完成！');