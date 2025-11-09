//
//  PokeAPIApp.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/6/25.
//

//import SwiftUI
//
//@main
//struct PokeAPIApp: App {
//    var body: some Scene {
//        WindowGroup {
//            PokemonView()
//        }
//    }
//}

import UIKit
import SwiftUI

@main
struct PokeAPIApp: App {
    var body: some Scene {
        WindowGroup {
            UIKitWrapperViewController()
        }
    }
}

struct UIKitWrapperViewController: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: PokemonListViewController())
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
