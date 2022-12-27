//
//  CutView.swift
//  EfVideo
//
//  Created by user on 27.12.2022.
//

import UIKit
import MultiSlider

class CutView: UIView {
    
    var sendButton: UIButton?
    var cutSlider: MultiSlider?
    
    private var cutView: UIView?
    private var label1: UILabel?
    private var label2: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCutView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabel1(_ text: String) {
        label1?.text = text
    }
    
    func setLabel2(_ text: String) {
        label2?.text = text
    }
    
    func sendButtonAction(_ selector: Selector) {
        sendButton?.addTarget(self, action: selector, for: .touchUpInside)
    }
    
    private func createCutView() -> UIView {
        let cutView = UIView()
        cutView.layer.cornerRadius = 10
        cutView.layer.borderWidth = 1
        cutView.layer.borderColor = UIColor.white.cgColor
        cutView.layer.masksToBounds = true
        cutView.backgroundColor = UIColor.black
        cutView.translatesAutoresizingMaskIntoConstraints = false
        return cutView
    }
    
    private func createMultiSlider(constMinValue: CGFloat, constMaxValue: CGFloat) -> MultiSlider {
        let cutSlider = MultiSlider()
        cutSlider.minimumValue = constMinValue
        cutSlider.maximumValue = constMaxValue
        cutSlider.outerTrackColor = .lightGray
        cutSlider.orientation = .horizontal
        
        cutSlider.valueLabelPosition = .notAnAttribute // .notAnAttribute = don't show labels
        cutSlider.isValueLabelRelative = true // show differences between thumbs instead of absolute values
        cutSlider.valueLabelFormatter.positiveSuffix = ""
        
        cutSlider.tintColor = UIColor.systemBlue // color of track
        cutSlider.trackWidth = 10
        cutSlider.hasRoundTrackEnds = true
        cutSlider.showsThumbImageShadow = false // wide tracks look better without thumb shadow
        
        cutSlider.thumbImage   = UIImage(named: "balloon")
        cutSlider.minimumImage = UIImage(named: "clown")
        cutSlider.maximumImage = UIImage(named: "cloud")
        
        cutSlider.disabledThumbIndices = []
        
        cutSlider.snapStepSize = 0.0  // default is 0.0, i.e. don't snap

        cutSlider.value = [constMinValue, constMaxValue]
        
        cutSlider.translatesAutoresizingMaskIntoConstraints = false
        return cutSlider
    }
    
    private func createSendButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.layer.cornerRadius = 5.0
        sendButton.layer.masksToBounds = true
        sendButton.backgroundColor = UIColor.systemBlue
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }
    
    private func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func addCutView() {
 
        cutView = createCutView()
        guard let cutView = cutView else { return }
        addSubview(cutView)
        
        NSLayoutConstraint.activate([
            cutView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            cutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            cutView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        let constMinValue: CGFloat = 0.0
        let constMaxValue: CGFloat = 100.0
        
        cutSlider = createMultiSlider(constMinValue: constMinValue, constMaxValue: constMaxValue)
        
        guard let slider = cutSlider else { return }
        cutView.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.bottomAnchor.constraint(equalTo: cutView.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: cutView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: cutView.trailingAnchor)
        ])
        
        sendButton = createSendButton()
        guard let sendButton = sendButton else { return }
        cutView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: cutView.trailingAnchor, constant: -10),
            sendButton.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        label1 = createTimeLabel()
        guard let label1 = label1 else { return }
        cutView.addSubview(label1)
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: cutView.leadingAnchor, constant: 10),
            label1.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            label1.widthAnchor.constraint(equalToConstant: 100),
            label1.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        label2 = createTimeLabel()
        guard let label2 = label2 else { return }
        cutView.addSubview(label2)
        
        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 10),
            label2.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            label2.widthAnchor.constraint(equalToConstant: 100),
            label2.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
