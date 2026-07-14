"use client";

import { useState } from "react";

export default function Showcase() {
  const [hasVideo, setHasVideo] = useState(true);

  return (
    <section className="py-32 flex justify-center">
      <div className="relative w-[85%] rounded-3xl overflow-hidden border border-white/10 shadow-2xl">
        <div className="absolute inset-0 bg-gradient-to-b from-white/5 to-transparent pointer-events-none z-10" />

        {hasVideo ? (
          <video
            className="w-full"
            autoPlay
            muted
            loop
            playsInline
            preload="none"
            poster="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 9'%3E%3C/svg%3E"
            onError={() => setHasVideo(false)}
          >
            <source src="/demo.mp4" type="video/mp4" />
            <source src="/demo.mov" type="video/quicktime" />
          </video>
        ) : (
          <div className="aspect-video bg-gradient-to-br from-indigo-900/40 via-purple-900/30 to-slate-900 flex items-center justify-center">
            <div className="text-center">
              <svg
                className="w-16 h-16 mx-auto text-white/20 mb-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1}
                  d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1}
                  d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <p className="text-white/30 text-sm">将 demo.mov 或 demo.mp4 放入 /public 目录</p>
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
