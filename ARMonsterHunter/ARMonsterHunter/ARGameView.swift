import SwiftUI

struct ARGameView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Score: \(viewModel.score)")
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Spacer()
                }
                .padding()

                Spacer()

                Button {
                    viewModel.spawnSpider()
                } label: {
                    Text("Spawn Spider")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 16)

                Button {
                    viewModel.shoot()
                } label: {
                    Text("Shoot")
                        .font(.headline)
                        .frame(width: 132)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .padding(.bottom, 28)
            }

            CrosshairView()
                .allowsHitTesting(false)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CrosshairView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 30, height: 2)
            Rectangle()
                .fill(.white)
                .frame(width: 2, height: 30)
            Circle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 18, height: 18)
        }
        .shadow(radius: 2)
    }
}

#Preview {
    ARGameView()
}
