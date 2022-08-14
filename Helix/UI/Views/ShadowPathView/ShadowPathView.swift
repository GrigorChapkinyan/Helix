//
//  ShadowPathView.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 14.08.22.
//

import UIKit

@IBDesignable class ShadowPathView: UIView {
    @IBInspectable var radius: CGFloat = 5 {
        didSet {
            configureShadow()
        }
    }
    
    @IBInspectable var additionalWidthForShadow: CGFloat = 0 {
        didSet {
            configureShadow()
        }
    }
    
    // MARK: - Private Properties
    
    private let shadowLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    
    // MARK: - View Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadow()
    }
    
    // MARK: - Private API
    
    private func commonInit() {
        // these properties don't change
        backgroundColor = .clear
        
        layer.addSublayer(shadowLayer)
        
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.gray.cgColor
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowOffset = .zero
        
        // set the layer mask
        shadowLayer.mask = maskLayer
    }
    
    private func configureShadow() {
        shadowLayer.frame = bounds
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        
        // create a rect bezier path, large enough to exceed the shadow bounds
        let bez = UIBezierPath(rect: bounds.insetBy(dx: -radius * 2.0, dy: -radius * 2.0))
        
        // create a path for the "hole" in the layer
        let holePath = UIBezierPath(rect: bounds.insetBy(dx: radius, dy: radius))
        
        // this "cuts a hole" in the path
        bez.append(holePath)
        bez.usesEvenOddFillRule = true
        maskLayer.fillRule = .evenOdd
        
        // set the path of the mask layer
        maskLayer.path = bez.cgPath
        
        // make the shadow rect larger than bounds
        let shadowRect = bounds.insetBy(dx: -additionalWidthForShadow, dy: -additionalWidthForShadow)
        // set the shadow path
        //  make the corner radius larger to make the curves look correct
        shadowLayer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: radius + additionalWidthForShadow).cgPath
    }
}
