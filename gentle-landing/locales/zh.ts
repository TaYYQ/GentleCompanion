const zh = {
  nav: {
    features: "功能",
    story: "我们的故事",
    download: "下载",
  },
  hero: {
    title: "GentleCompanion",
    subtitle: "当你的思绪太吵闹时，一个安静的空间。",
    description: "一款 macOS 应用，不催促你提高效率——它只是陪着你，直到一切都变得轻松一些。",
    downloadBtn: "下载 macOS 版",
    githubBtn: "GitHub 查看",
    scroll: "向下滚动",
  },
  showcase: {
    placeholder: "放入 /public/demo.mp4 来显示演示视频",
  },
  features: {
    badge: "功能",
    title: "你所需要的一切",
    titleHighlight: "让心情变轻松",
    items: [
      {
        title: "天气心情",
        desc: "实时天气联动情绪文案，晴雨雪雾都有属于你的温柔解读。支持全球城市搜索。",
      },
      {
        title: "番茄钟专注",
        desc: "Liquid Glass 风格计时器，25 分钟深度专注，完成统计与连续天数追踪。",
      },
      {
        title: "呼吸练习",
        desc: "4-4-6-2 科学呼吸法引导，60fps 粒子动画，帮你从焦虑中慢慢回到当下。",
      },
      {
        title: "三款解压小游戏",
        desc: "泡泡戳破释放压力、花园养成种植花卉、律动圆环节奏踩点，随心切换。",
      },
      {
        title: "温柔墙",
        desc: "匿名发布心情，按情绪标签浏览，点赞彼此的脆弱时刻。不评判，只陪伴。",
      },
      {
        title: "社交连接",
        desc: "关注好友、私信、番茄钟排行。不比较成就，只分享存在感。",
      },
    ],
  },
  weather: {
    badge: "天气 & 心情",
    title: "天气知道你的心情",
    description: "不是普通的天气预报。接入和风天气 API，7 种情绪 × 20 种天气场景 = 专属温柔文案，让每个天气都成为被理解的理由。支持全球城市，点击即可切换。",
    tags: ["晴天光芒粒子", "云朵漂移", "雨滴下落", "雪花飘落", "闪电特效"],
    mockCity: "杭州 · 晴朗",
    mockMessage: "杭州晴，太阳在轻轻说：今天也值得被爱。",
  },
  pomodoro: {
    badge: "番茄钟",
    title: "专注，但不焦虑",
    description: "番茄钟不是催促你，而是陪着你。Liquid Glass 风格计时器自动检测是否进入 macOS 全屏模式，专注统计面板记录你每一次认真面对自己的时刻。",
    quickIntents: ["清掉邮件", "写完那段文字", "静静呼吸"],
    stats: [
      { value: "3", label: "阶段计时" },
      { value: "∞", label: "快捷意图" },
      { value: "60fps", label: "粒子特效" },
    ],
  },
  breathing: {
    badge: "呼吸练习",
    title: "呼吸，是最简单的回归",
    description: "4 秒吸气、4 秒屏息、6 秒呼气、2 秒停顿。科学验证的呼吸节奏，配合 20 个上升粒子 + 呼吸球体缩放动画，让每一次呼吸都变成可视化的温柔仪式。",
    inhale: "吸气 4s",
    method: "4-4-6-2 呼吸法",
    stats: [
      { value: "4", label: "阶段节奏" },
      { value: "60fps", label: "Canvas 渲染" },
      { value: "4", label: "色渐变" },
    ],
  },
  gentleWall: {
    badge: "温柔墙",
    title: "匿名温柔墙",
    subtitle: "没有评判，没有建议，只有「我听到了」。每条消息都是一次被看见。",
    messages: [
      { emotion: "疲惫", text: "今天真的好累，什么都不想做，只想有人跟我说一句「没关系」。", likes: 42 },
      { emotion: "焦虑", text: "明天的汇报让我失眠三天了，但我还在呼吸，这已经很好了。", likes: 38 },
      { emotion: "孤独", text: "朋友很多，但能说真话的很少。这里至少没人会 judge 我。", likes: 56 },
      { emotion: "复杂开心", text: "升职了，应该是开心的，但压力大到想哭。这矛盾的感觉有人懂吗？", likes: 31 },
      { emotion: "丧/空", text: "没有原因，就是觉得空空的。不想说话，也不想被问「你怎么了」。", likes: 49 },
      { emotion: "压抑", text: "表面看起来一切都好，内心已经在暴风雨了。但我不想吓到任何人。", likes: 67 },
    ],
  },
  developer: {
    badge: "开发人员",
    title: "创造者",
    name: "张天成",
    role: "独立开发者 · macOS & iOS 工程师",
    bio: "相信科技可以温柔地存在。致力于打造不催促、不评判、只是安静陪伴的数字空间。每一行代码都带着对使用者情绪的在意。",
    tags: ["SwiftUI", "AppKit", "Combine", "Core Animation", "CloudKit", "REST API"],
    philosophy: [
      { title: "不催促", desc: "不是又一个效率工具，而是陪你慢下来的空间" },
      { title: "不评判", desc: "每一种情绪都值得被看见、被接纳" },
      { title: "只陪伴", desc: "有时最好的帮助，就是安静地在那里" },
    ],
  },
  story: {
    title: "为什么做这个",
    paragraph1: "我不想要另一个效率应用，催我做更多、更专注、或优化我的生活。",
    paragraph2: "我想要的是，当一切让人喘不过气时，有东西能简单地陪在你身边。",
    paragraph3: "安静的。温柔的。",
  },
  download: {
    title: "准备好了吗",
    titleHighlight: "让心情变轻松",
    description: "GentleCompanion 完全免费且开源。适用于 macOS 14.0+。",
    downloadBtn: "下载 macOS 版",
    githubBtn: "Star on GitHub",
    footnote: "macOS 14.0+ · MIT License · 不收集任何数据",
  },
  footer: {
    line1: "你现在不需要好起来。",
    line2: "为安静的灵魂而建。",
    developer: "开发人员：张天成",
  },
  langSwitch: "English",
};

export default zh;
