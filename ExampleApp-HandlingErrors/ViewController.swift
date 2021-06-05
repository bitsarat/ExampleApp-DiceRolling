//
//  ViewController.swift
//  ExampleApp-HandlingErrors
//
//  Created by Ben Scheirman on 8/21/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var diceImage: UIImageView!
    @IBOutlet weak var rollDiceButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = DiceViewModel()
    private static var unknownDiceImage = UIImage(systemName: "questionmark.square.fill")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiceImage()
                
    }
    
    private func configureDiceImage() {
        diceImage.layer.shadowColor = UIColor.black.cgColor
        diceImage.layer.shadowOpacity = 0.25
        diceImage.layer.shadowRadius = 2
        diceImage.layer.shadowOffset = .zero
    }
    
    private var isRolling = false {
        didSet {
            UIView.animate(withDuration: 0.33) { [unowned self] in
                diceImage.alpha = isRolling ? 0.5 : 1.0
                diceImage.transform = isRolling ? CGAffineTransform(scaleX: 0.5, y: 0.5) :
                    CGAffineTransform.identity
            }
            rollDiceButton.isEnabled = !isRolling
        }
    }

    @IBAction func rollDiceTapped(_ sender: Any) {
        viewModel.rollDice()
            .handleEvents(receiveSubscription: { [unowned self] _ in
                isRolling = true
            }, receiveCompletion: { [unowned self] _ in
                isRolling = false
            }, receiveCancel: { [unowned self] in
                isRolling = false
            })
            .sink { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    showErrorAlert(error)
                default:
                    break
                }
            } receiveValue: { [unowned self] roll in
                diceImage.image = diceImage(for: roll)
            }
            .store(in: &cancellables)
    }
   
    func showErrorAlert(_ error: DiceViewModel.DiceError) {
        let alert = UIAlertController(title: "Dice Error", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reroll", style: .default, handler: { [unowned self] _ in
            rollDiceTapped(self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func diceImage(for value: Int) -> UIImage {
        switch value {
        case 1: return UIImage(named: "dice-one")!
        case 2: return UIImage(named: "dice-two")!
        case 3: return UIImage(named: "dice-three")!
        case 4: return UIImage(named: "dice-four")!
        case 5: return UIImage(named: "dice-five")!
        case 6: return UIImage(named: "dice-six")!
        default:
            return Self.unknownDiceImage
        }
    }
}

