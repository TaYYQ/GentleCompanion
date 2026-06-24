//
//  GardenGame.swift
//  GentleCompanion
//
//  🌸 花园物语 — 种花养草，收集图鉴
//

import SwiftUI

struct GardenGame: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    let duration: PlayDuration
    
    @State private var gardenSlots: [GardenSlot] = []
    @State private var selectedSeed: FlowerType?
    @State private var collection: Set<String> = []
    @State private var showCollection: Bool = false
    @State private var butterflies: [Butterfly] = []
    @State private var remainingSeconds: Int?
    @State private var timer: Timer?
    
    private let columns = 4
    private let rows = 3
    private let totalSlots = 12
    
    // 花的类型
    private let flowerTypes: [FlowerType] = [
        FlowerType(id: "rose", name: "玫瑰", emoji: "🌹", color: Color(hex: "#F87171"), growTime: 5, butterflyChance: 0.8),
        FlowerType(id: "sunflower", name: "向日葵", emoji: "🌻", color: Color(hex: "#FCD34D"), growTime: 4, butterflyChance: 0.6),
        FlowerType(id: "tulip", name: "郁金香", emoji: "🌷", color: Color(hex: "#F472B6"), growTime: 4, butterflyChance: 0.7),
        FlowerType(id: "cherry", name: "樱花", emoji: "🌸", color: Color(hex: "#FBCFE8"), growTime: 6, butterflyChance: 0.9),
        FlowerType(id: "daisy", name: "雏菊", emoji: "🌼", color: Color(hex: "#FDE68A"), growTime: 3, butterflyChance: 0.5),
        FlowerType(id: "hibiscus", name: "木槿", emoji: "🌺", color: Color(hex: "#FB923C"), growTime: 5, butterflyChance: 0.7),
        FlowerType(id: "lavender", name: "薰衣草", emoji: "💜", color: Color(hex: "#A78BFA"), growTime: 7, butterflyChance: 1.0),
        FlowerType(id: "lily", name: "百合", emoji: "🪷", color: Color(hex: "#FCA5A5"), growTime: 6, butterflyChance: 0.8)
    ]
    
    struct FlowerType {
        let id: String
        let name: String
        let emoji: String
        let color: Color
        let growTime: TimeInterval  // 秒
        let butterflyChance: Double
    }
    
    struct GardenSlot: Identifiable {
        let id = UUID()
        var flowerId: String? = nil
        var stage: GrowthStage = .empty
        var plantedAt: Date? = nil
        var growDuration: TimeInterval = 0
        var waterDrops: Int = 0
    }
    
    enum GrowthStage: Int {
        case empty = 0
        case seed = 1
        case sprout = 2
        case budding = 3
        case blooming = 4
    }
    
    struct Butterfly: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var targetX: CGFloat
        var targetY: CGFloat
        var emoji: String
        var opacity: Double = 0
        var wingPhase: Double = 0
    }
    
    var body: some View {
        ZStack {
            // 浅紫渐变背景
            LinearGradient(
                colors: [Color(hex: "#F8F0FF"), Color(hex: "#F0E7FF"), Color(hex: "#F5F0FF")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 蝴蝶
            ForEach(butterflies) { butterfly in
                Text(butterfly.emoji)
                    .font(.system(size: 20))
                    .opacity(butterfly.opacity)
                    .position(x: butterfly.x, y: butterfly.y)
                    .rotationEffect(.degrees(sin(butterfly.wingPhase) * 10))
            }
            
            VStack(spacing: 0) {
                // 顶栏
                gardenTopBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: GentleSpacing.xl) {
                        // 种子选择
                        seedSelector
                        
                        // 花园网格
                        gardenGrid
                        
                        Spacer().frame(height: GentleSpacing.xl)
                    }
                    .padding(.horizontal, GentleSpacing.xl)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 图鉴弹窗
            if showCollection {
                collectionOverlay
            }
        }
        .onAppear {
            initGarden()
            startTimerIfNeeded()
            startButterflyAnimation()
            startGrowthTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Top Bar
    
    private var gardenTopBar: some View {
        HStack {
            Button {
                isPresented = false
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Gentle.Background.primary)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Gentle.Primary.lavender.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Gentle.Text.primary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("🌸 花园物语")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("种一朵花，收获一份快乐")
                    .font(.system(size: 12))
                    .foregroundColor(Gentle.Text.secondary)
            }
            
            Spacer()
            
            // 图鉴按钮
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showCollection.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "book.fill")
                    Text("图鉴 \(collection.count)/\(flowerTypes.count)")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Gentle.Text.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Gentle.Background.primary)
                        .overlay(
                            Capsule()
                                .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, GentleSpacing.lg)
        .padding(.vertical, GentleSpacing.md)
    }
    
    // MARK: - Seed Selector
    
    private var seedSelector: some View {
        VStack(spacing: GentleSpacing.md) {
            Text("选择种子")
                .font(GentleFont.caption(13))
                .foregroundColor(Gentle.Text.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GentleSpacing.md) {
                    ForEach(flowerTypes, id: \.id) { flower in
                        let isSelected = selectedSeed?.id == flower.id
                        let isCollected = collection.contains(flower.id)
                        
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                selectedSeed = flower
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(flower.emoji)
                                    .font(.system(size: 28))
                                    .opacity(isCollected ? 1.0 : 0.4)
                                
                                Text(flower.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(isSelected ? flower.color : Gentle.Text.secondary)
                            }
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous)
                                    .fill(isSelected ? flower.color.opacity(0.15) : Gentle.Background.primary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous)
                                    .stroke(isSelected ? flower.color.opacity(0.5) : Gentle.Primary.lavender.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .shadow(color: isSelected ? flower.color.opacity(0.2) : .clear, radius: isSelected ? 8 : 0, x: 0, y: isSelected ? 4 : 0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, GentleSpacing.sm)
            }
        }
    }
    
    // MARK: - Garden Grid
    
    private var gardenGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: GentleSpacing.md), count: columns), spacing: GentleSpacing.md) {
            ForEach($gardenSlots) { $slot in
                gardenSlotView(slot: $slot)
            }
        }
    }
    
    private func gardenSlotView(slot: Binding<GardenSlot>) -> some View {
        let currentSlot = slot.wrappedValue
        let flower = currentSlot.flowerId.flatMap { id in flowerTypes.first { $0.id == id } }
        
        return Button {
            plantOrHarvest(slot: &slot.wrappedValue)
        } label: {
            ZStack {
                // 花园槽背景
                RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Gentle.Background.primary.opacity(0.8), Gentle.Primary.lavender.opacity(0.1)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: GentleRadius.lg, style: .continuous)
                            .stroke(Gentle.Primary.lavender.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 100)
                
                // 生长阶段
                switch currentSlot.stage {
                case .empty:
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundColor(Gentle.Text.tertiary)
                        Text("种下")
                            .font(.system(size: 10))
                            .foregroundColor(Gentle.Text.tertiary)
                    }
                    
                case .seed:
                    VStack(spacing: 4) {
                        Text("🌱")
                            .font(.system(size: 24))
                        Text("种子")
                            .font(.system(size: 9))
                            .foregroundColor(Gentle.Text.secondary)
                    }
                    
                case .sprout:
                    VStack(spacing: 4) {
                        Text("🌿")
                            .font(.system(size: 28))
                        Text("发芽")
                            .font(.system(size: 9))
                            .foregroundColor(flower?.color.opacity(0.8) ?? Gentle.Text.secondary)
                    }
                    
                case .budding:
                    VStack(spacing: 4) {
                        Text("🌺")
                            .font(.system(size: 30))
                            .scaleEffect(0.9)
                        Text("含苞")
                            .font(.system(size: 9))
                            .foregroundColor(flower?.color ?? Gentle.Text.primary)
                    }
                    
                case .blooming:
                    VStack(spacing: 4) {
                        Text(flower?.emoji ?? "🌸")
                            .font(.system(size: 36))
                            .shadow(color: (flower?.color ?? Gentle.Primary.pink).opacity(0.3), radius: 8, x: 0, y: 2)
                        Text(flower?.name ?? "")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(flower?.color ?? Gentle.Text.primary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(currentSlot.stage != .empty && currentSlot.stage != .blooming)
    }
    
    // MARK: - Collection Overlay
    
    private var collectionOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showCollection = false }
                }
            
            VStack(spacing: GentleSpacing.xl) {
                Text("🌸 花卉图鉴")
                    .font(GentleFont.title(22))
                    .foregroundColor(Gentle.Text.primary)
                
                Text("已收集 \(collection.count) / \(flowerTypes.count)")
                    .font(GentleFont.caption(13))
                    .foregroundColor(Gentle.Text.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: GentleSpacing.md), count: 4), spacing: GentleSpacing.md) {
                    ForEach(flowerTypes, id: \.id) { flower in
                        let isCollected = collection.contains(flower.id)
                        VStack(spacing: 4) {
                            Text(flower.emoji)
                                .font(.system(size: 36))
                                .opacity(isCollected ? 1.0 : 0.2)
                                .grayscale(isCollected ? 0 : 1)
                            
                            Text(isCollected ? flower.name : "???")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(isCollected ? flower.color : Gentle.Text.tertiary)
                        }
                        .frame(width: 70, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: GentleRadius.md, style: .continuous)
                                .fill(isCollected ? flower.color.opacity(0.1) : Gentle.Background.tertiary.opacity(0.5))
                        )
                    }
                }
                .padding(.horizontal, GentleSpacing.md)
                
                Button("关闭") {
                    withAnimation { showCollection = false }
                }
                .buttonStyle(GentlePrimaryButtonStyle())
            }
            .padding(GentleSpacing.xxl)
            .frame(width: 440)
            .background(
                RoundedRectangle(cornerRadius: GentleRadius.xxl, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Game Logic
    
    private func initGarden() {
        gardenSlots = (0..<totalSlots).map { _ in GardenSlot() }
    }
    
    private func plantOrHarvest(slot: inout GardenSlot) {
        if slot.stage == .empty {
            // 种下种子
            guard let seed = selectedSeed else { return }
            slot.flowerId = seed.id
            slot.stage = .seed
            slot.plantedAt = Date()
            slot.growDuration = seed.growTime
        } else if slot.stage == .blooming {
            // 收获
            if let flowerId = slot.flowerId {
                collection.insert(flowerId)
                
                // 蝴蝶概率
                if let flower = flowerTypes.first(where: { $0.id == flowerId }),
                   Double.random(in: 0...1) < flower.butterflyChance {
                    spawnButterfly()
                }
            }
            slot = GardenSlot()
        }
    }
    
    private func startGrowthTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                for i in gardenSlots.indices {
                    guard let plantedAt = gardenSlots[i].plantedAt else { continue }
                    let elapsed = Date().timeIntervalSince(plantedAt)
                    let progress = elapsed / gardenSlots[i].growDuration
                    
                    if progress >= 1.0 && gardenSlots[i].stage != .blooming {
                        gardenSlots[i].stage = .blooming
                    } else if progress >= 0.66 && gardenSlots[i].stage.rawValue < 3 {
                        gardenSlots[i].stage = .budding
                    } else if progress >= 0.33 && gardenSlots[i].stage.rawValue < 2 {
                        gardenSlots[i].stage = .sprout
                    }
                }
            }
        }
    }
    
    private func spawnButterfly() {
        let butterflyEmojis = ["🦋", "🦋", "🦋"]
        let b = Butterfly(
            x: CGFloat.random(in: 50...920),
            y: CGFloat.random(in: 120...600),
            targetX: CGFloat.random(in: 50...920),
            targetY: CGFloat.random(in: 120...600),
            emoji: butterflyEmojis.randomElement()!,
            opacity: 0,
            wingPhase: 0
        )
        butterflies.append(b)
    }
    
    private func startButterflyAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            Task { @MainActor in
                for i in butterflies.indices {
                    butterflies[i].wingPhase += 0.15
                    
                    // 移向目标
                    let dx = butterflies[i].targetX - butterflies[i].x
                    let dy = butterflies[i].targetY - butterflies[i].y
                    butterflies[i].x += dx * 0.02
                    butterflies[i].y += dy * 0.02 + sin(butterflies[i].wingPhase) * 0.5
                    
                    // 淡入
                    if butterflies[i].opacity < 1.0 {
                        butterflies[i].opacity += 0.05
                    }
                    
                    // 到达目标，换新目标
                    if abs(dx) < 5 && abs(dy) < 5 {
                        butterflies[i].targetX = CGFloat.random(in: 50...920)
                        butterflies[i].targetY = CGFloat.random(in: 120...600)
                    }
                }
            }
        }
    }
    
    private func startTimerIfNeeded() {
        if let seconds = duration.seconds {
            remainingSeconds = seconds
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor in
                    if let remaining = remainingSeconds, remaining > 0 {
                        remainingSeconds = remaining - 1
                    } else {
                        timer?.invalidate()
                    }
                }
            }
        }
    }
}
