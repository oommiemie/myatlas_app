import ActivityKit
import SwiftUI
import UIKit
import WidgetKit

// Palette — matches the in-app queue card (water-blue theme).
private let brandBlueLight = Color(red: 0.310, green: 0.765, blue: 0.969)   // #4FC3F7
private let brandBlueDeep  = Color(red: 0.118, green: 0.533, blue: 0.898)   // #1E88E5
private let brandInk       = Color(red: 0.102, green: 0.102, blue: 0.180)   // #1A1A2E

@available(iOS 16.2, *)
private struct BrandLogo: View {
  let size: CGFloat
  var body: some View {
    Group {
      if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
         let img  = UIImage(contentsOfFile: path),
         let cg   = img.cgImage {
        Image(decorative: cg, scale: 1.0)
          .resizable()
          .interpolation(.high)
          .aspectRatio(contentMode: .fit)
      } else {
        Circle().fill(Color.orange)
      }
    }
    .frame(width: size, height: size)
  }
}

@available(iOS 16.2, *)
struct HospitalQueueLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: HospitalQueueAttributes.self) { context in
      // ── Lock Screen / banner ───────────────────────────────────────
      LockScreenView(attrs: context.attributes, state: context.state)
        .padding(16)
        .activityBackgroundTint(brandInk.opacity(0.95))
        .activitySystemActionForegroundColor(.white)

    } dynamicIsland: { context in
      // ── Dynamic Island ─────────────────────────────────────────────
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          HStack(spacing: 6) {
            BrandLogo(size: 22)
            VStack(alignment: .leading, spacing: 0) {
              Text("คิว")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
              Text(context.attributes.queueCode)
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
          }
        }

        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing, spacing: 0) {
            Text(context.state.etaLabel)
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(.white)
              .lineLimit(1)
              .minimumScaleFactor(0.6)
            Text("รอ \(context.state.waitCount) คิว")
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(brandBlueLight)
              .lineLimit(1)
          }
        }

        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            Text(context.state.statusLabel)
              .font(.system(size: 13, weight: .semibold))
              .foregroundStyle(.white.opacity(0.85))
            QueueProgressBar(step: context.state.step)
          }
        }
      } compactLeading: {
        BrandLogo(size: 20)
      } compactTrailing: {
        Text(context.attributes.queueCode)
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(.white)
          .monospacedDigit()
      } minimal: {
        BrandLogo(size: 22)
      }
      .widgetURL(URL(string: "myatlas://queue"))
      .keylineTint(brandBlueDeep)
    }
  }
}

// ── Lock-screen banner ──────────────────────────────────────────────────
@available(iOS 16.2, *)
private struct LockScreenView: View {
  let attrs: HospitalQueueAttributes
  let state: HospitalQueueAttributes.ContentState

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Top row: hospital icon + status | hospital name
      HStack(alignment: .top) {
        HStack(spacing: 8) {
          BrandLogo(size: 28)
          Text(state.statusLabel)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
        }
        Spacer(minLength: 8)
        VStack(alignment: .trailing, spacing: 2) {
          Text(attrs.hospitalName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.65))
            .lineLimit(2)
            .multilineTextAlignment(.trailing)
        }
      }

      // Middle row: eta big timer + queue #
      HStack(alignment: .lastTextBaseline) {
        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 4) {
            Image(systemName: "clock")
              .foregroundStyle(.white.opacity(0.55))
              .font(.system(size: 11, weight: .semibold))
            Text("คาดว่าถึงคิว")
              .font(.system(size: 11, weight: .semibold))
              .foregroundStyle(.white.opacity(0.55))
          }
          Text(state.etaLabel)
            .font(.system(size: 32, weight: .heavy))
            .foregroundStyle(.white)
            .monospacedDigit()
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text(attrs.servicePoint)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.65))
          Text("คิว \(attrs.queueCode)")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
            .monospacedDigit()
        }
      }

      // Progress row: 4 steps
      QueueProgressBar(step: state.step)
        .padding(.top, 2)
    }
  }
}

// ── 4-step progress bar (register → wait → serve → done) ───────────────
@available(iOS 16.2, *)
private struct QueueProgressBar: View {
  let step: Int   // 0..3

  private let icons = ["person.crop.circle.badge.plus",
                       "hourglass",
                       "cross.case",
                       "checkmark.circle.fill"]

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<4) { i in
        Image(systemName: icons[i])
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(i <= step ? brandBlueLight : .white.opacity(0.35))
          .frame(width: 18)
        if i < 3 {
          GeometryReader { g in
            ZStack(alignment: .leading) {
              Capsule()
                .fill(.white.opacity(0.18))
                .frame(height: 4)
              Capsule()
                .fill(brandBlueLight)
                .frame(width: i < step ? g.size.width
                                       : (i == step ? g.size.width * 0.5 : 0),
                       height: 4)
            }
          }
          .frame(height: 4)
        }
      }
    }
  }
}
