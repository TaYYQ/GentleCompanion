//
//  Emotion.swift
//  GentleCompanion
//
//  Emotion models and data
//

import Foundation

enum Emotion: String, CaseIterable, Identifiable, Codable {
    case empty = "丧/空"
    case exhausted = "累到不想动"
    case anxious = "焦虑像小老鼠在跑"
    case lonely = "孤独但不想找人"
    case incompleteJoy = "开心但总觉得缺了点什么"
    case suppressedAnger = "愤怒想砸东西但怕后悔"
    case other = "其他"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .empty: return "🌑"
        case .exhausted: return "💤"
        case .anxious: return "🐭"
        case .lonely: return "🌙"
        case .incompleteJoy: return "🌤️"
        case .suppressedAnger: return "🔥"
        case .other: return "✨"
        }
    }
    
    var color: String {
        switch self {
        case .empty: return "#6B7280"
        case .exhausted: return "#9CA3AF"
        case .anxious: return "#FCD34D"
        case .lonely: return "#60A5FA"
        case .incompleteJoy: return "#FBBF24"
        case .suppressedAnger: return "#F87171"
        case .other: return "#A78BFA"
        }
    }
    
    var displayName: String {
        switch self {
        case .empty: return "丧/空"
        case .exhausted: return "疲惫"
        case .anxious: return "焦虑"
        case .lonely: return "孤独"
        case .incompleteJoy: return "复杂开心"
        case .suppressedAnger: return "压抑愤怒"
        case .other: return "其他"
        }
    }
    
    var gentleMessage: String {
        GentleMessage.messages(for: self).first ?? "一切都会好起来的。"
    }
}

struct GentleMessage: Identifiable, Codable {
    var id = UUID()
    let text: String
    let emotion: Emotion
    
    static func messages(for emotion: Emotion) -> [String] {
        switch emotion {
        case .empty:
            return [
                "允许今天什么都不做到极致。沙发、被子、昏暗的光，已经足够。",
                "今天的空白，是在为明天积攒温柔的力气。",
                "不必急着填满这片空白。就让这一天，静静地流过去。",
                "你不需要现在就好起来。允许自己暂停，允许自己什么都不做。",
                "这片空旷，也许是在告诉你：停下来，听一听心跳的声音。",
                "不要害怕这种空。它是温柔的朋友，不是可怕的敌人。",
                "就像夜晚也会有黑暗，今天也允许有空白。",
                "你现在感受到的，是生命在呼吸。让它自由地呼吸吧。"
            ]
        case .exhausted:
            return [
                "今天你已经尽力了。现在，把全部的重量都交给床，交给被子。",
                "身体累了，它不是在偷懒，它是在认真地说：我需要休息。",
                "不用再撑着了。躺下来，闭上眼，让世界在外面自己转。",
                "今天的电量已经耗尽，这没关系。明天会有新的太阳。",
                "不想动就不动。这不需要解释，也不需要内疚。",
                "你的身体记得所有你付出过的努力。现在，好好照顾它。",
                "躺平不是放弃，是和自己的身体和解。",
                "就像手机没电了要充电，你也一样。好好充电吧。"
            ]
        case .anxious:
            return [
                "小老鼠跑累了，会停下来。你的焦虑也终会停下来。",
                "现在感到的一切，都是暂时的。这波浪潮会过去的。",
                "呼吸。吸气，感受空气进入；呼气，让紧张离开。",
                "你比这些焦虑更强大。它们只是路过的小访客。",
                "闭上眼睛，想象自己坐在一片安静的草地上。一切都很安全。",
                "担心的事情，大多不会发生。让它们先在外面等一等。",
                "每一次心跳，都在提醒你：我还在，我还好好的。",
                "慢慢来，不着急。时间会给你答案。"
            ]
        case .lonely:
            return [
                "即使只有一个人，你也值得被温柔对待。",
                "孤独不是孤独，是和自己独处的时光。",
                "不想找人也没关系。有时候，只需要自己陪伴自己就够了。",
                "这个世界很大，但此刻你的小小空间也很温暖。",
                "你有你自己，这就足够了。",
                "孤独的时候，其实是心在和你说话。听听它想说什么。",
                "不想见人就别见。保护自己的能量也很重要。",
                "今天，你可以成为自己最好的朋友。"
            ]
        case .incompleteJoy:
            return [
                "开心了，那就很好。缺失感也许会慢慢填满。",
                "今天的快乐是真实的。其他的，明天再说。",
                "允许开心不完美。它是礼物，不是任务。",
                "有点缺憾也很正常。不完美才是生活。",
                "抓住这份开心，不管它完不完整。",
                "你值得快乐，不管它是什么样子的。",
                "快乐会来，也会走。但它来的时候，好好享受就好。",
                "今天的你，比昨天更靠近一点幸福。"
            ]
        case .suppressedAnger:
            return [
                "愤怒不是坏事，它在保护你。",
                "想砸东西，说明你在乎。这很正常。",
                "把愤怒写下来，然后撕掉。让它有个去处。",
                "你现在的克制，是温柔的另一种形式。",
                "愤怒像火，让它燃烧一会儿，然后让它平静下来。",
                "你不需要永远温柔。偶尔不温柔，也没关系。",
                "保护好自己，也保护好别人。你的愤怒在提醒你边界在哪里。",
                "明天，愤怒会变成另一种力量。"
            ]
        case .other:
            return [
                "无论你今天经历了什么，都值得被温柔对待。",
                "你现在感受到的，是真实的。这已经足够。",
                "每一天都是新的开始。今天，对自己好一点。",
                "你可以有各种感受，它们都是你的一部分。",
                "不急着定义它，就让它存在一会儿。",
                "你的感受很重要。它们不需要被理解，只需要被看见。",
                "今天，你已经在很努力地生活了。",
                "无论是什么，都允许它存在。它是你，你也是它。"
            ]
        }
    }
}
