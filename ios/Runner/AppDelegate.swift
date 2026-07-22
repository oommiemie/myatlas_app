import ActivityKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var currentActivityId: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let channel = FlutterMethodChannel(
      name: "myatlas/live_activity",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard #available(iOS 16.2, *) else {
        result(FlutterError(code: "UNSUPPORTED",
                            message: "Live Activities require iOS 16.2+",
                            details: nil))
        return
      }
      switch call.method {
      case "isSupported":
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
      case "start":
        self?.startActivity(call: call, result: result)
      case "update":
        self?.updateActivity(call: call, result: result)
      case "end":
        self?.endActivity(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @available(iOS 16.2, *)
  private func startActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let hospitalName = args["hospitalName"] as? String,
          let queueCode = args["queueCode"] as? String,
          let servicePoint = args["servicePoint"] as? String,
          let waitCount = args["waitCount"] as? Int,
          let etaLabel = args["etaLabel"] as? String,
          let step = args["step"] as? Int,
          let statusLabel = args["statusLabel"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Missing fields", details: nil))
      return
    }

    // If one is already running, end it first — one queue per session.
    if let id = currentActivityId {
      Task {
        for activity in Activity<HospitalQueueAttributes>.activities where activity.id == id {
          await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivityId = nil
        self.launchActivity(hospitalName: hospitalName,
                            queueCode: queueCode,
                            servicePoint: servicePoint,
                            waitCount: waitCount,
                            etaLabel: etaLabel,
                            step: step,
                            statusLabel: statusLabel,
                            result: result)
      }
    } else {
      launchActivity(hospitalName: hospitalName,
                     queueCode: queueCode,
                     servicePoint: servicePoint,
                     waitCount: waitCount,
                     etaLabel: etaLabel,
                     step: step,
                     statusLabel: statusLabel,
                     result: result)
    }
  }

  @available(iOS 16.2, *)
  private func launchActivity(hospitalName: String,
                              queueCode: String,
                              servicePoint: String,
                              waitCount: Int,
                              etaLabel: String,
                              step: Int,
                              statusLabel: String,
                              result: @escaping FlutterResult) {
    let attrs = HospitalQueueAttributes(
      hospitalName: hospitalName,
      queueCode: queueCode,
      servicePoint: servicePoint
    )
    let state = HospitalQueueAttributes.ContentState(
      waitCount: waitCount,
      etaLabel: etaLabel,
      step: step,
      statusLabel: statusLabel
    )
    do {
      let activity = try Activity.request(
        attributes: attrs,
        content: .init(state: state, staleDate: nil),
        pushType: nil
      )
      currentActivityId = activity.id
      result(activity.id)
    } catch {
      result(FlutterError(code: "START_FAILED",
                          message: error.localizedDescription,
                          details: nil))
    }
  }

  @available(iOS 16.2, *)
  private func updateActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let waitCount = args["waitCount"] as? Int,
          let etaLabel = args["etaLabel"] as? String,
          let step = args["step"] as? Int,
          let statusLabel = args["statusLabel"] as? String,
          let id = currentActivityId else {
      result(FlutterError(code: "BAD_ARGS", message: "Missing fields or no active", details: nil))
      return
    }
    Task {
      let state = HospitalQueueAttributes.ContentState(
        waitCount: waitCount,
        etaLabel: etaLabel,
        step: step,
        statusLabel: statusLabel
      )
      for activity in Activity<HospitalQueueAttributes>.activities where activity.id == id {
        await activity.update(.init(state: state, staleDate: nil))
      }
      result(true)
    }
  }

  @available(iOS 16.2, *)
  private func endActivity(result: @escaping FlutterResult) {
    guard let id = currentActivityId else {
      result(false)
      return
    }
    Task {
      for activity in Activity<HospitalQueueAttributes>.activities where activity.id == id {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
      currentActivityId = nil
      result(true)
    }
  }
}
