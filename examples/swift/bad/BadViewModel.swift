// Deliberately bad Swift: scripts/check-configs.sh expects swift-format (lint) and SwiftLint to
// reject this file. Do not copy it. Each comment names the rule that should fire.
import SwiftUI
import Foundation  // swift-format OrderedImports

class robot_view_model {  // SwiftLint type_name, swift-format TypeNamesShouldBeCapitalized
  var Speeds: [Double] = []  // SwiftLint identifier_name, swift-format AlwaysUseLowerCamelCase

  func load(path: String) -> [Double] {
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))  // force_try, NeverUseForceTry
    let values = try! JSONDecoder().decode([Double].self, from: data);  // DoNotUseSemicolons
    if values.count == 0 { return [] }  // SwiftLint empty_count
    return values
  }
}

struct BadImageView: View {
  @State var isOn = false  // SwiftLint private_swiftui_state

  var body: some View {
    Image("robot")  // SwiftLint accessibility_label_for_image
  }
}
