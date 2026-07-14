"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useLang } from "@/context/LangContext";
import { flagMap } from "@/locales";

export default function DownloadPage() {
  const { t, lang, setLang } = useLang();
  const router = useRouter();
  const [entered, setEntered] = useState(false);
  const [exiting, setExiting] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setEntered(true), 300);
    return () => clearTimeout(timer);
  }, []);

  const handleBack = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      if (exiting) return;
      setExiting(true);
      setTimeout(() => router.push("/"), 650);
    },
    [exiting, router]
  );

  const isZh = lang === "zh";

  const text = {
    title: isZh ? "下载 GentleCompanion" : "Download GentleCompanion",
    subtitle: isZh
      ? "选择适合你设备的版本开始温柔陪伴"
      : "Choose your platform and start gentle companionship",
    mac: isZh ? "macOS 版" : "macOS",
    macDesc: isZh
      ? "原生 SwiftUI 构建，完美适配 macOS 设计语言"
      : "Native SwiftUI app, perfectly adapted to macOS design language",
    macVersion: "v1.0.0 · macOS 14.0+",
    intel: isZh ? "下载 DMG（Intel 芯片）" : "Download DMG (Intel)",
    intelSize: "~48 MB",
    appleSilicon: isZh ? "下载 DMG（Apple 芯片）" : "Download DMG (Apple Silicon)",
    appleSiliconSize: "~42 MB",
    appleSiliconTag: isZh ? "M1/M2/M3/M4 推荐" : "M1/M2/M3/M4 Recommended",
    windows: isZh ? "Windows 版" : "Windows",
    windowsComing: isZh ? "敬请期待" : "Coming Soon",
    windowsDesc: isZh
      ? "Windows 版本正在规划中，我们将尽快为更多用户带来温柔陪伴。"
      : "Windows version is being planned. We'll bring gentle companionship to more users soon.",
    ios: isZh ? "iOS 版" : "iOS",
    iosComing: isZh ? "敬请期待" : "Coming Soon",
    iosDesc: isZh
      ? "移动端版本正在设计中，让你的温柔陪伴随时随地触手可及。"
      : "Mobile version is being designed. Take your gentle companion anywhere.",
    github: t.hero.githubBtn,
    back: isZh ? "返回首页" : "Back Home",
  };

  return (
    <main className="min-h-screen bg-[#070A12] text-white relative overflow-hidden">
      {/* Background glows */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute w-[800px] h-[800px] bg-purple-500/12 blur-[180px] rounded-full top-[-250px] left-1/2 -translate-x-1/2" />
        <div className="absolute w-[600px] h-[600px] bg-blue-500/6 blur-[150px] rounded-full bottom-[-200px] right-[-100px]" />
        <div className="absolute w-[400px] h-[400px] bg-pink-500/5 blur-[120px] rounded-full bottom-[20%] left-[-100px]" />
      </div>

      {/* Entry overlay */}
      <div
        className={`fixed inset-0 z-50 bg-[#070A12] flex items-center justify-center transition-all duration-700 ${
          entered && !exiting ? "opacity-0 pointer-events-none" : "opacity-100"
        }`}
      >
        <div className="flex flex-col items-center gap-6">
          <div
            className="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500/30 via-blue-500/25 to-pink-500/20 border border-white/10 flex items-center justify-center animate-pulse"
            style={{ animationDuration: "2s" }}
          >
            <svg
              className="w-8 h-8 text-white/60"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3"
              />
            </svg>
          </div>
          <span className="text-white/40 text-sm tracking-widest">
            {exiting
              ? isZh ? "正在返回..." : "Going back..."
              : isZh ? "准备温柔的下载体验..." : "Preparing gentle download..."
            }
          </span>
        </div>
      </div>

      {/* Header */}
      <div className="relative z-10">
        <button
          onClick={() => setLang(lang === "zh" ? "en" : "zh")}
          className="absolute top-8 right-8 px-4 py-2 rounded-full border border-white/10 hover:bg-white/10 transition-all text-sm text-white/60 hover:text-white/80"
        >
          {flagMap[lang === "zh" ? "en" : "zh"]} {t.langSwitch}
        </button>

        <a
          href="/"
          onClick={handleBack}
          className="absolute top-8 left-8 px-4 py-2 rounded-full border border-white/10 hover:bg-white/10 transition-all text-sm text-white/50 flex items-center gap-2 cursor-pointer"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          {text.back}
        </a>
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-4xl mx-auto px-6 pt-32 pb-20">
        {/* Title */}
        <div className="text-center mb-16">
          <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-purple-500/20 via-blue-500/20 to-pink-500/20 border border-white/10 flex items-center justify-center">
            <svg className="w-9 h-9 text-white/60" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
            </svg>
          </div>
          <h1 className="text-4xl md:text-5xl font-medium mb-4">{text.title}</h1>
          <p className="text-white/40 text-lg">{text.subtitle}</p>
        </div>

        {/* ============ macOS ============ */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-6">
            <span className="text-2xl">🍎</span>
            <h2 className="text-2xl font-medium">{text.mac}</h2>
            <span className="px-2.5 py-0.5 rounded-full bg-green-500/10 border border-green-500/20 text-green-400 text-[11px]">
              {isZh ? "可用" : "Available"}
            </span>
          </div>
          <p className="text-white/40 text-sm mb-8 ml-11">{text.macDesc}</p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 ml-11">
            {/* Intel */}
            <div className="bg-white/[0.03] border border-white/10 rounded-2xl p-6 hover:border-white/20 hover:bg-white/[0.05] transition-all group">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center text-lg">
                  💻
                </div>
                <div>
                  <p className="text-white/80 text-sm font-medium">{isZh ? "Intel 芯片" : "Intel Chip"}</p>
                  <p className="text-white/20 text-xs">{text.intelSize}</p>
                </div>
              </div>
              <a
                href="#"
                className="w-full block text-center px-4 py-3 rounded-xl bg-white text-black font-medium hover:scale-[1.02] active:scale-[0.98] transition-all text-sm"
              >
                {text.intel}
              </a>
            </div>

            {/* Apple Silicon */}
            <div className="bg-white/[0.03] border border-white/10 rounded-2xl p-6 hover:border-purple-500/30 hover:bg-white/[0.05] transition-all group relative overflow-hidden">
              <div className="absolute top-0 right-0 bg-purple-500/20 text-purple-300 text-[10px] px-3 py-1 rounded-bl-xl">
                {text.appleSiliconTag}
              </div>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-purple-500/10 flex items-center justify-center text-lg">
                  ⚡
                </div>
                <div>
                  <p className="text-white/80 text-sm font-medium">{isZh ? "Apple 芯片" : "Apple Silicon"}</p>
                  <p className="text-white/20 text-xs">{text.appleSiliconSize}</p>
                </div>
              </div>
              <a
                href="#"
                className="w-full block text-center px-4 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-blue-500 text-white font-medium hover:scale-[1.02] active:scale-[0.98] transition-all text-sm"
              >
                {text.appleSilicon}
              </a>
            </div>
          </div>

          <p className="ml-11 mt-4 text-white/15 text-xs">{text.macVersion}</p>
        </div>

        {/* Divider */}
        <div className="border-t border-white/5 mb-12" />

        {/* ============ Windows ============ */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-6">
            <span className="text-2xl">🪟</span>
            <h2 className="text-2xl font-medium">{text.windows}</h2>
            <span className="px-2.5 py-0.5 rounded-full bg-yellow-500/10 border border-yellow-500/20 text-yellow-400 text-[11px]">
              {text.windowsComing}
            </span>
          </div>
          <p className="text-white/30 text-sm mb-6 ml-11 leading-relaxed max-w-lg">{text.windowsDesc}</p>
          <div className="ml-11">
            <div className="bg-white/[0.02] border border-white/5 rounded-2xl p-6 max-w-sm opacity-50 pointer-events-none">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center text-lg">💻</div>
                <div>
                  <p className="text-white/40 text-sm font-medium">Windows 11 / 10</p>
                  <p className="text-white/10 text-xs">~50 MB</p>
                </div>
              </div>
              <div className="w-full text-center px-4 py-3 rounded-xl bg-white/5 text-white/20 text-sm">
                {text.windowsComing}
              </div>
            </div>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-white/5 mb-12" />

        {/* ============ iOS ============ */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-6">
            <span className="text-2xl">📱</span>
            <h2 className="text-2xl font-medium">{text.ios}</h2>
            <span className="px-2.5 py-0.5 rounded-full bg-yellow-500/10 border border-yellow-500/20 text-yellow-400 text-[11px]">
              {text.iosComing}
            </span>
          </div>
          <p className="text-white/30 text-sm mb-6 ml-11 leading-relaxed max-w-lg">{text.iosDesc}</p>
          <div className="ml-11">
            <div className="bg-white/[0.02] border border-white/5 rounded-2xl p-6 max-w-sm opacity-50 pointer-events-none">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center text-lg">📱</div>
                <div>
                  <p className="text-white/40 text-sm font-medium">iPhone / iPad</p>
                  <p className="text-white/10 text-xs">iOS 17.0+</p>
                </div>
              </div>
              <div className="w-full text-center px-4 py-3 rounded-xl bg-white/5 text-white/20 text-sm">
                {text.iosComing}
              </div>
            </div>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-white/5 mb-12" />

        {/* Bottom actions */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <a
            href="https://github.com/TaYYQ/GentleCompanion"
            target="_blank"
            rel="noopener noreferrer"
            className="px-6 py-3 rounded-full border border-white/20 hover:bg-white/10 transition-all text-white/60 text-center"
          >
            {text.github}
          </a>
          <Link
            href="/"
            onClick={handleBack}
            className="px-6 py-3 rounded-full bg-white/5 border border-white/10 text-white/60 hover:bg-white/10 transition-all text-center cursor-pointer"
          >
            {text.back}
          </Link>
        </div>
      </div>
    </main>
  );
}
