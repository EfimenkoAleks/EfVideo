//
//  Reactive+Extension.swift
//  EfVideo
//
//  Created by user on 29.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: BaseViewController {
    
    /// Bindable sink for `showLoader()`, `hideLoader()` methods.
    internal var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (vc, active) in
            if active {
                vc.showLoader()
            } else {
                vc.hideLoader()
            }
        })
    }
    
}
