//
//  PomodoroWidgetBundle.swift
//  PomodoroWidget
//
//  Widget Extension 入口
//

import WidgetKit
import SwiftUI

@main
struct PomodoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomodoroLiveActivity()
    }
}
