//
//  DiceViewModel.swift
//  ExampleApp-HandlingErrors
//
//  Created by Ben Scheirman on 8/21/20.
//

import UIKit
import Combine

class DiceViewModel {
    
    enum DiceError: Error {
        case rolledOffTable
    }
    
    func rollDice() -> AnyPublisher<Int, DiceError> {
        Future {promise in
            if Int.random(in: 1...4) > 1 {
                promise(.success(Int.random(in: 1...6)))
            }
            else {
                promise(.failure(DiceError.rolledOffTable))
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
