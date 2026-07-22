import ActivityKit
import Foundation

// Shared model — used by both the app (to start/update Live Activity)
// and the widget extension (to render it).
public struct HospitalQueueAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    // Number of people ahead of the user (0 = up next).
    public var waitCount: Int
    // Countdown label — "12 นาที", "ใกล้ถึงแล้ว", …
    public var etaLabel: String
    // Current pipeline step (0..3): register → wait → serve → done.
    public var step: Int
    // Displayed status — "กำลังรอเรียก", "เชิญห้อง 022", …
    public var statusLabel: String

    public init(waitCount: Int, etaLabel: String, step: Int, statusLabel: String) {
      self.waitCount = waitCount
      self.etaLabel = etaLabel
      self.step = step
      self.statusLabel = statusLabel
    }
  }

  // Immutable per-session data — hospital, queue code, service point.
  public var hospitalName: String
  public var queueCode: String
  public var servicePoint: String

  public init(hospitalName: String, queueCode: String, servicePoint: String) {
    self.hospitalName = hospitalName
    self.queueCode = queueCode
    self.servicePoint = servicePoint
  }
}
