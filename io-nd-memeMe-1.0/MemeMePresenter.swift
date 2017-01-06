//
//  MemeMePresenter.swift
//  io-nd-memeMe-1.0
//
//  Created by Patrice Müller on 22.12.16.
//  Copyright © 2016 swissonid. All rights reserved.
//

import Foundation

protocol MemeView: class {
    var isSharedOptionEnabled: Bool { get set }
    var isCancelOptionEnabled: Bool { get set }
    var topText: String { get set }
    var bottomText: String { get set }
    var hasImage: Bool { get }
}

class MemeMePresenter {

    weak private var memeView: MemeView?
    
    func attachView(view:MemeView){
        memeView = view
    }
    
    func detachView() {
        memeView = nil
    }
}
