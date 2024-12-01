import SwiftUI

var amount = 2;

struct ContentView: View {
    
    @State var screenAmount: Int = 3;
    
    var body: some View {
        TabView {
            
            ForEach(0..<screenAmount, id: \.self) { _ in
                MainScreenView(screenAmount: screenAmount, increaseScreenAmount: increaseScreenAmount, decreaseScreenAmount: decreaseScreenAmount)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea(.all)
    }
    
    private func increaseScreenAmount() -> Void {
        self.screenAmount += 1
    }
    
    private func decreaseScreenAmount() -> Void {
        self.screenAmount -= 1
    }
}



