//
//  GentiOSProfileView.swift
//  GentleCompanion iOS
//
//  我的页 — Liquid Glass 风格 + 编辑资料
//

import SwiftUI
@preconcurrency import PhotosUI

// MARK: - Avatar Presets

private let avatarOptions = [
    "🌸", "🌺", "🌻", "🌙", "⭐", "🦋", "🐱", "🐶", "🐰", "🦊",
    "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧",
    "🐦", "🦉", "🦄", "🐙", "🦀", "🐬", "🪷", "🍀", "💜", "🪐"
]

// MARK: - Main View

struct GentiOSProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var account = AccountManager.shared
    @ObservedObject private var themeManager = GentleThemeManager.shared
    @State private var showLogoutAlert = false
    @State private var notificationEnabled = SettingsManager.shared.settings.reminderEnabled
    @State private var appear = false

    @State private var showAuth = false
    @State private var showEditProfile = false
    @State private var showAgreement = false
    @State private var showThemePicker = false
    @State private var showPrivacy = false

    var body: some View {
        ZStack {
            Gentle.Glass.darkBase.ignoresSafeArea()
            Gentle.Glass.ambientGlow(color: Color(hex: "#EC4899"))
                .frame(width: 350, height: 350)
                .offset(y: -280)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    titleRow

                    Button {
                        if account.isLoggedIn {
                            showEditProfile = true
                        } else {
                            showAuth = true
                        }
                    } label: {
                        profileHeader
                    }
                    .buttonStyle(.plain)

                    settingsSection
                    aboutSection
                    if account.isLoggedIn { logoutButton }
                    bottomLinks
                    Spacer().frame(height: 8)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appear = true }
        }
        .fullScreenCover(isPresented: $showAuth) {
            ActivationFlowView {
                showAuth = false
                account.objectWillChange.send()
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showAgreement) {
            AgreementView(title: "用户协议", content: userAgreementText)
        }
        .sheet(isPresented: $showPrivacy) {
            AgreementView(title: "隐私政策", content: privacyPolicyText)
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerSheet()
        }
        .alert("确认退出", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) { account.logout() }
        } message: {
            Text("退出后需要重新登录才能使用完整功能。")
        }
    }

    // MARK: - Title

    private var titleRow: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.08))
                            .overlay(Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5))
                    )
            }
            .padding(.trailing, 6)

            Text("我的")
                .font(.system(size: 28, weight: .thin, design: .serif))
                .foregroundColor(Gentle.Glass.textPrimary)
            Spacer()
            if account.isLoggedIn {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
        }
        .padding(.top, 8)
        .opacity(appear ? 1 : 0)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A855F7"), Color(hex: "#EC4899")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .overlay { Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }
                    .shadow(color: Color(hex: "#A855F7").opacity(0.3), radius: 16, y: 6)

                avatarDisplayView(
                    account.isLoggedIn ? (account.currentAccount?.avatar ?? "🌸") : "🌸",
                    size: 26
                )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(account.isLoggedIn
                     ? (account.currentAccount?.username ?? "温柔点用户")
                     : "点击登录")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Gentle.Glass.textPrimary)

                HStack(spacing: 4) {
                    if account.isLoggedIn {
                        if let gender = account.currentAccount?.gender {
                            Text(gender.icon + " " + gender.rawValue)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Gentle.Glass.textSecondary)
                        }
                        if let bio = account.currentAccount?.bio, !bio.isEmpty {
                            if account.currentAccount?.gender != nil {
                                Text("·").foregroundColor(Gentle.Glass.textTertiary)
                            }
                            Text(bio)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Gentle.Glass.textSecondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text("登录以编辑个人资料")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Gentle.Glass.textSecondary)
                    }
                }
            }

            Spacer()

            Image(systemName: account.isLoggedIn ? "pencil.circle.fill" : "person.crop.circle.badge.plus")
                .font(.system(size: 22))
                .foregroundColor(Gentle.Glass.textTertiary)
        }
        .padding(18)
        .liquidGlassCard(cornerRadius: GentleRadius.xxxl, opacity: 0.5)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 16)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 1) {
            sectionLabel("设置")

            toggleRow(icon: "bell.fill", title: "每日提醒", color: "#FCD34D", isOn: $notificationEnabled)
                .onChange(of: notificationEnabled) { _, v in
                    var s = SettingsManager.shared.settings; s.reminderEnabled = v
                    SettingsManager.shared.settings = s
                    if v {
                        NotificationManager.shared.requestAuthorization { granted in
                            if !granted {
                                DispatchQueue.main.async {
                                    notificationEnabled = false
                                    var s2 = SettingsManager.shared.settings
                                    s2.reminderEnabled = false
                                    SettingsManager.shared.settings = s2
                                }
                            }
                        }
                    }
                }

            divider
            Button {
                showThemePicker = true
            } label: {
                navRow(icon: "paintpalette.fill", title: "主题", color: "#A78BFA", value: themeManager.current.displayName)
            }
            .buttonStyle(.plain)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(spacing: 1) {
            sectionLabel("关于")

            Button {
                showAgreement = true
            } label: {
                navRow(icon: "doc.text.fill", title: "用户协议", color: "#9CA3AF")
            }
            .buttonStyle(.plain)

            divider

            Button {
                showPrivacy = true
            } label: {
                navRow(icon: "shield.fill", title: "隐私政策", color: "#9CA3AF")
            }
            .buttonStyle(.plain)

            divider
            navRow(icon: "app.badge.fill", title: "版本", color: "#9CA3AF", value: "1.0.0 (Build 1)")
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 24)
    }

    // MARK: - Bottom Links

    private var bottomLinks: some View {
        HStack(spacing: 24) {
            Button("用户协议") { showAgreement = true }
                .font(.system(size: 11))
                .foregroundColor(Gentle.Glass.textTertiary)
                .buttonStyle(.plain)

            Text("·").foregroundColor(Gentle.Glass.textTertiary)

            Button("隐私政策") { showPrivacy = true }
                .font(.system(size: 11))
                .foregroundColor(Gentle.Glass.textTertiary)
                .buttonStyle(.plain)

            if account.isLoggedIn {
                Text("·").foregroundColor(Gentle.Glass.textTertiary)
                Button("退出登录") { showLogoutAlert = true }
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#F87171").opacity(0.5))
                    .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button { showLogoutAlert = true } label: {
            Text("退出登录")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#F87171"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.35)
                .overlay {
                    RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                        .stroke(Color(hex: "#F87171").opacity(0.12), lineWidth: 0.5)
                }
        }
        .opacity(appear ? 1 : 0)
    }

    // MARK: - Shared Components

    private var divider: some View {
        Rectangle()
            .fill(Gentle.Glass.borderWhite)
            .frame(height: 0.5)
            .padding(.leading, 44)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Gentle.Glass.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
            .padding(.bottom, 6)
    }

    private func navRow(icon: String, title: String, color: String, value: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: color))
                .frame(width: 22)
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Gentle.Glass.textPrimary)
            Spacer()
            if let v = value {
                Text(v)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(Gentle.Glass.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.45)
    }

    private func toggleRow(icon: String, title: String, color: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: color))
                .frame(width: 22)
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Gentle.Glass.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color(hex: "#A855F7"))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: GentleRadius.lg, opacity: 0.45)
    }
}

// MARK: - Avatar Helpers

func avatarDocumentsURL() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("AvatarImages", isDirectory: true)
}

func ensureAvatarDir() -> URL {
    let url = avatarDocumentsURL()
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

func saveAvatarImage(_ image: UIImage) -> String {
    let dir = ensureAvatarDir()
    let filename = "avatar_\(UUID().uuidString.prefix(8)).jpg"
    let url = dir.appendingPathComponent(filename)
    if let data = image.jpegData(compressionQuality: 0.8) {
        try? data.write(to: url)
    }
    return filename
}

func loadAvatarImage(_ avatar: String) -> UIImage? {
    guard avatar.hasPrefix("avatar_"), avatar.contains(".") else { return nil }
    let dir = ensureAvatarDir()
    let url = dir.appendingPathComponent(avatar)
    return UIImage(contentsOfFile: url.path)
}

@ViewBuilder
func avatarDisplayView(_ avatar: String, size: CGFloat) -> some View {
    if let img = loadAvatarImage(avatar) {
        Image(uiImage: img)
            .resizable()
            .scaledToFill()
            .frame(width: size * 2.38, height: size * 2.38)
            .clipShape(Circle())
    } else {
        Text(avatar)
            .font(.system(size: size))
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var account = AccountManager.shared

    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var avatar: String = "🌸"
    @State private var gender: Gender? = nil

    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    var body: some View {
        ZStack {
            Gentle.Glass.baseBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("取消") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundColor(Gentle.Glass.textSecondary)
                    Spacer()
                    Text("编辑资料")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                    Spacer()
                    Button("保存") {
                        if let img = pickedImage {
                            avatar = saveAvatarImage(img)
                        }
                        account.updateBasicProfile(
                            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                            avatar: avatar,
                            gender: gender
                        )
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Gentle.Primary.lavender)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        avatarPicker
                        fieldSection("昵称", text: $username, placeholder: "你的昵称")
                        bioSection
                        genderSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            username = account.currentAccount?.username ?? ""
            bio = account.currentAccount?.bio ?? ""
            avatar = account.currentAccount?.avatar ?? "🌸"
            gender = account.currentAccount?.gender
            pickedImage = loadAvatarImage(avatar)
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { pickedImage = img }
                }
            }
        }
    }

    // MARK: - Avatar Picker

    private var avatarPicker: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A855F7").opacity(0.3), Color(hex: "#EC4899").opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay { Circle().stroke(Gentle.Glass.borderWhite, lineWidth: 0.5) }

                if let img = pickedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Text(avatar)
                        .font(.system(size: 38))
                }
            }

            Button {
                showPhotoPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus").font(.system(size: 13))
                    Text(pickedImage != nil ? "更换照片" : "上传本地照片")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Gentle.Primary.lavender)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .liquidGlassCard(cornerRadius: GentleRadius.full, opacity: 0.4)
                .overlay {
                    RoundedRectangle(cornerRadius: GentleRadius.full, style: .continuous)
                        .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 0.5)
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)

            if pickedImage != nil {
                Button("使用 Emoji 头像") {
                    withAnimation(.spring(response: 0.3)) { pickedImage = nil }
                }
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Gentle.Glass.textSecondary)
            }

            Text("或选择 Emoji 头像")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Gentle.Glass.textSecondary)
                .padding(.top, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(avatarOptions, id: \.self) { emoji in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            avatar = emoji
                            pickedImage = nil
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(avatar == emoji && pickedImage == nil ? Color(hex: "#A78BFA").opacity(0.2) : Gentle.Glass.borderWhite)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        avatar == emoji && pickedImage == nil ? Color(hex: "#A78BFA").opacity(0.3) : Gentle.Glass.borderWhite,
                                        lineWidth: 0.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Fields

    private func fieldSection(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Gentle.Glass.textTertiary)
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundColor(Gentle.Glass.textPrimary)
                .padding(.horizontal, 14).padding(.vertical, 12)
                .liquidGlassCard(cornerRadius: 14, opacity: 0.35)
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("简介")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Gentle.Glass.textTertiary)
            TextEditor(text: $bio)
                .font(.system(size: 14))
                .foregroundColor(Gentle.Glass.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(height: 80)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .liquidGlassCard(cornerRadius: 14, opacity: 0.35)
        }
    }

    // MARK: - Gender

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("性别")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Gentle.Glass.textTertiary)

            HStack(spacing: 8) {
                ForEach(Gender.allCases, id: \.rawValue) { g in
                    Button {
                        withAnimation(.spring(response: 0.3)) { gender = g }
                    } label: {
                        HStack(spacing: 5) {
                            Text(g.icon).font(.system(size: 16))
                            Text(g.rawValue).font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(gender == g ? Gentle.Glass.textPrimary : Gentle.Glass.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(gender == g ? Color(hex: "#A78BFA").opacity(0.15) : Gentle.Glass.borderWhite)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    gender == g ? Color(hex: "#A78BFA").opacity(0.25) : Gentle.Glass.borderWhite,
                                    lineWidth: 0.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Theme Picker Sheet

private struct ThemePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = GentleThemeManager.shared

    var body: some View {
        ZStack {
            Gentle.Glass.baseBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶栏
                HStack {
                    Text("选择主题")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Gentle.Glass.textPrimary)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Gentle.Glass.textTertiary)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 12)

                // 主题网格
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(GentlePlatformTheme.allCases, id: \.self) { theme in
                        themeCard(theme)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func themeCard(_ theme: GentlePlatformTheme) -> some View {
        let isSelected = themeManager.current == theme
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                themeManager.apply(theme)
            }
        } label: {
            VStack(spacing: 10) {
                // 预览色块
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.primaryGradient)
                    .frame(height: 60)
                    .overlay {
                        HStack(spacing: 4) {
                            Circle().fill(.white.opacity(0.5)).frame(width: 5, height: 5)
                            Circle().fill(.white.opacity(0.3)).frame(width: 5, height: 5)
                            Circle().fill(.white.opacity(0.2)).frame(width: 5, height: 5)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 10).padding(.top, 8)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isSelected ? .white.opacity(0.4) : .white.opacity(0.08),
                                lineWidth: isSelected ? 2 : 0.5
                            )
                    }

                // 名称 + 标语
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? Gentle.Glass.textPrimary : Gentle.Glass.textSecondary)
                        Text(theme.displayName)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? Gentle.Glass.textPrimary : Gentle.Glass.textSecondary)
                    }
                    Text(theme.tagline)
                        .font(.system(size: 10))
                        .foregroundColor(Gentle.Glass.textTertiary)
                }
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? theme.primary.opacity(0.15) : Gentle.Glass.borderWhite)
            }
        }
        .buttonStyle(.plain)
    }
}
