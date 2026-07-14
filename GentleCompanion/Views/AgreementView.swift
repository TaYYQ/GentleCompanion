//
//  AgreementView.swift
//  GentleCompanion
//
//  Shared user agreement & privacy policy — Liquid Glass sheet
//

import SwiftUI

// MARK: - Agreement / Privacy Policy View

struct AgreementView: View {
    @ObservedObject private var themeManager = GentleThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var appear = false
    @State private var hasScrolledToBottom = false

    let title: String
    let content: String

    private let icon: String
    private let accentColor: Color

    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.icon = title.contains("隐私") ? "hand.raised.fill" : "doc.text.fill"
        self.accentColor = title.contains("隐私") ? Color(hex: "#34D399") : Color(hex: "#A78BFA")
    }

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        heroSection
                        contentSections.padding(.bottom, 40)
                        confirmationBar
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).maxY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .scrollIndicators(.hidden)
                .onPreferenceChange(ScrollOffsetKey.self) { maxY in
#if os(iOS)
                    let threshold: CGFloat = UIScreen.main.bounds.height + 100
#else
                    let threshold: CGFloat = 800
#endif
                    if maxY < threshold && !hasScrolledToBottom {
                        withAnimation { hasScrolledToBottom = true }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appear = true }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Gentle.Glass.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Gentle.Glass.borderWhite))
                    .overlay { Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }
            }

            Spacer()

            Image(systemName: icon)
                .font(.system(size: 14)).foregroundColor(accentColor)
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Gentle.Glass.textPrimary)

            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)
        .background(.ultraThinMaterial.opacity(0.7))
        .overlay(alignment: .bottom) {
            Rectangle().frame(height: 0.5).foregroundColor(Gentle.Glass.borderWhite)
        }
        .opacity(appear ? 1 : 0)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.15), accentColor.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 24)).foregroundColor(accentColor)
            }
            .padding(.top, 32)

            Text(title)
                .font(.system(size: 22, weight: .thin, design: .serif))
                .foregroundColor(Gentle.Glass.textPrimary)
            Text(title.contains("隐私") ? "我们非常重视您的隐私保护" : "请仔细阅读以下条款")
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Gentle.Glass.textTertiary)
            Text("更新日期：2026年7月10日 · 生效日期：2026年7月10日")
                .font(.system(size: 11, weight: .light))
                .foregroundColor(Gentle.Glass.textTertiary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 28)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
    }

    // MARK: - Content Sections

    private var contentSections: some View {
        let sections = parseSections(from: content)
        return ForEach(sections.indices, id: \.self) { index in
            let section = sections[index]
            VStack(alignment: .leading, spacing: 4) {
                if let heading = section.heading {
                    Text(heading)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(accentColor.opacity(0.9))
                        .padding(.top, index == 0 ? 0 : 20)
                        .padding(.bottom, 8)
                }
                Text(section.body)
                    .font(.system(size: 13.5, weight: .light))
                    .foregroundColor(Gentle.Glass.textSecondary)
                    .lineSpacing(7)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Confirmation Bar

    private var confirmationBar: some View {
        VStack(spacing: 14) {
            if hasScrolledToBottom {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#34D399"))
                    Text("已阅读完毕")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#34D399").opacity(0.8))
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button { dismiss() } label: {
                Text("我知道了")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .liquidGlassCard(cornerRadius: 16, opacity: 0.5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(accentColor.opacity(0.2), lineWidth: 0.5)
                    }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Section Parser

private struct DocSection {
    let heading: String?
    let body: String
}

private func parseSections(from text: String) -> [DocSection] {
    let lines = text.components(separatedBy: "\n")
    var sections: [DocSection] = []
    var currentHeading: String? = nil
    var currentBody: [String] = []

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { continue }
        if trimmed.range(of: #"^[一二三四五六七八九十]+、"#, options: .regularExpression) != nil
            || trimmed.range(of: #"^温柔点"#, options: .regularExpression) != nil {
            if !currentBody.isEmpty {
                sections.append(DocSection(heading: currentHeading, body: currentBody.joined(separator: "\n")))
            }
            currentHeading = trimmed
            currentBody = []
        } else {
            if trimmed.range(of: #"^(更新日期|生效日期)"#, options: .regularExpression) == nil {
                currentBody.append(trimmed)
            }
        }
    }

    if !currentBody.isEmpty {
        sections.append(DocSection(heading: currentHeading, body: currentBody.joined(separator: "\n")))
    }
    return sections
}

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Content Texts

let userAgreementText = """
温柔点 用户协议

更新日期：2026年7月10日
生效日期：2026年7月10日

欢迎使用「温柔点」！

请您在使用本软件前仔细阅读本协议。使用本软件即表示您已充分阅读、理解并同意接受本协议的全部条款。

一、服务说明

温柔点是一款专注于情绪管理与个人成长的陪伴类应用，提供以下核心功能：
· 情绪记录与分析
· 番茄钟专注计时
· 深呼吸放松引导
· 社区互动与温柔墙
· 个人成长追踪

二、账号管理

1. 您可以通过邮箱注册或通过 Apple ID 登录使用本服务。
2. 您应妥善保管账号信息，因账号保管不善造成的损失由您自行承担。
3. 您可以随时在设置中申请注销账号，注销后您的数据将被永久删除。

三、用户行为规范

1. 您不得利用本软件从事任何违法违规活动。
2. 您在社区和温柔墙发布的内容应遵守公序良俗，不得发布色情、暴力、仇恨言论等不当内容。
3. 不得利用技术手段干扰本软件的正常运行或窃取其他用户的信息。

四、知识产权

1. 温柔点的所有设计、代码、文案、图标等知识产权归开发团队所有。
2. 未经书面授权，任何人不得复制、修改、分发本软件的任何部分。

五、免责声明

1. 本软件提供的情绪分析仅供参考，不能替代专业心理咨询或医疗诊断。
2. 因不可抗力、网络故障等原因导致的服务中断，我们不承担赔偿责任。
3. 我们有权在不事先通知的情况下修改或终止部分服务。

六、协议修改

我们可能会适时更新本协议。更新后的协议一经发布即生效，继续使用本软件即视为接受更新后的协议。

七、联系我们

如对本协议有任何疑问，请通过以下方式联系我们：
邮箱：support@gentlecompanion.app

感谢您选择温柔点，愿温柔与你相伴。
"""

let privacyPolicyText = """
温柔点 隐私政策

更新日期：2026年7月10日
生效日期：2026年7月10日

温柔点（以下简称「我们」）非常重视您的隐私。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息。

一、我们收集的信息

1. 账号信息
   · 当您注册账号时，我们收集您的邮箱地址、用户名和加密密码。
   · 当您使用 Apple ID 登录时，我们收集 Apple 提供的用户标识符。

2. 个人资料
   · 您主动填写的昵称、简介、性别、出生日期、兴趣爱好等信息。
   · 您选择的头像（系统预设 emoji）。

3. 使用数据
   · 您记录的情绪数据
   · 您创建的番茄钟会话记录
   · 您在社区和温柔墙发布的内容
   · 您的应用设置偏好

4. 设备信息
   · 设备型号、操作系统版本、应用版本等基本信息
   · 用于优化用户体验，不包含个人身份信息

二、信息的使用

我们收集的信息仅用于以下目的：
· 提供、维护和改进我们的服务
· 个性化您的使用体验
· 生成情绪分析和成长报告
· 保障账号安全和防范欺诈

三、信息的存储

1. 您的数据存储在您的设备本地（UserDefaults）和您的 iCloud 账户中。
2. 我们不会将您的个人数据上传至第三方服务器。
3. 您可以使用 iCloud 同步功能在多设备间同步数据。

四、信息的共享

1. 我们不会将您的个人信息出售给第三方。
2. 您在社区和温柔墙公开发布的内容将对其他用户可见。
3. 除非法律法规要求，我们不会向任何第三方披露您的私人信息。

五、数据安全

1. 您的密码使用 PBKDF2-SHA256 算法加密存储，即使开发者也无法获知您的原始密码。
2. 我们采取合理的技术手段保护您的数据安全。
3. 建议您使用强密码并定期更换密码。

六、您的权利

1. 您可以随时查看、修改您的个人信息。
2. 您可以随时删除您的情绪记录、社区帖子等数据。
3. 您可以随时注销账号，注销后所有关联数据将被永久删除。
4. 您可以导出您的数据副本。

七、儿童隐私

本应用不面向 13 岁以下的儿童提供服务。如果您是监护人且发现您的孩子未经同意向我们提供了个人信息，请联系我们。

八、政策更新

我们可能会更新本隐私政策。重大变更时，我们会在应用内通过通知提醒您。

九、联系我们

如对本隐私政策有任何疑问或建议，请联系：
邮箱：support@gentlecompanion.app

保护您的隐私是我们最重要的承诺。
"""
