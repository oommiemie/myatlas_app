import SwiftUI
import WidgetKit

@main
struct HospitalQueueWidgetBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.2, *) {
      HospitalQueueLiveActivity()
    }
  }
}
