//
//  Created by Dimitrios Chatzieleftheriou on 05/08/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

import Foundation

final class BufferContext {
    let bytesPerFrame: UInt32
    let totalFrameCount: UInt32

    var frameStartIndex: UInt32 = 0
    var frameUsedCount: UInt32 = 0

    var end: UInt32 {
        (frameStartIndex + frameUsedCount) % totalFrameCount
    }

    init(bytesPerFrame: UInt32, totalFrameCount: UInt32) {
        self.bytesPerFrame = bytesPerFrame
        self.totalFrameCount = totalFrameCount
    }

    func reset() {
        frameStartIndex = 0
        frameUsedCount = 0
    }
}
