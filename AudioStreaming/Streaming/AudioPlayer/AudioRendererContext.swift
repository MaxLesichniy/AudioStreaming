//
//  Created by Dimitrios Chatzieleftheriou on 10/06/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

import AVFoundation
import CoreAudio

internal var maxFramesPerSlice: AVAudioFrameCount = 8192

public final class AudioRendererContext {
    @Protected
    var waiting: Bool = false

    let lock = UnfairLock()

    let bufferContext: BufferContext

    public var audioBuffer: AudioBuffer
    var inOutAudioBufferList: UnsafeMutablePointer<AudioBufferList>

    let packetsSemaphore = DispatchSemaphore(value: 0)

//    var discontinuous: Bool = false ???

    let framesRequiredToStartPlaying: UInt32
    let framesRequiredAfterRebuffering: UInt32
    let framesRequiredForDataAfterSeekPlaying: UInt32

    @Protected
    var waitingForDataAfterSeekFrameCount: Int32 = 0

    private let configuration: AudioPlayerConfiguration

    init(configuration: AudioPlayerConfiguration, outputAudioFormat: AVAudioFormat) {
        self.configuration = configuration

        let canonicalStream = outputAudioFormat.basicStreamDescription

        framesRequiredToStartPlaying = UInt32(canonicalStream.mSampleRate) * UInt32(configuration.secondsRequiredToStartPlaying)
        framesRequiredAfterRebuffering = UInt32(canonicalStream.mSampleRate) * UInt32(configuration.secondsRequiredToStartPlayingAfterBufferUnderun)
        framesRequiredForDataAfterSeekPlaying = UInt32(canonicalStream.mSampleRate) * UInt32(configuration.gracePeriodAfterSeekInSeconds)

        let dataByteSize = Int(canonicalStream.mSampleRate * configuration.bufferSizeInSeconds) * Int(canonicalStream.mBytesPerFrame)
        inOutAudioBufferList = allocateBufferList(dataByteSize: dataByteSize)

        audioBuffer = inOutAudioBufferList[0].mBuffers

        let bufferTotalFrameCount = UInt32(dataByteSize) / canonicalStream.mBytesPerFrame

        bufferContext = BufferContext(bytesPerFrame: canonicalStream.mBytesPerFrame,
                                      totalFrameCount: bufferTotalFrameCount)
    }

    func fillSilenceAudioBuffer() {
        let count = Int(bufferContext.totalFrameCount * bufferContext.bytesPerFrame)
        memset(audioBuffer.mData, 0, count)
    }

    /// Deallocates buffer resources
    func clean() {
        inOutAudioBufferList.deallocate()
        audioBuffer.mData?.deallocate()
    }

    /// Resets the `BufferContext`
    func resetBuffers() {
        lock.lock(); defer { lock.unlock() }
        bufferContext.frameStartIndex = 0
        bufferContext.frameUsedCount = 0
    }
}

/// Allocates a buffer list
///
/// - parameter dataByteSize: An `Int` value indicating the size that the buffer will hold
/// - Returns: An `UnsafeMutablePointer<AudioBufferList>` object
private func allocateBufferList(dataByteSize: Int) -> UnsafeMutablePointer<AudioBufferList> {
    let _bufferList = AudioBufferList.allocate(maximumBuffers: 1)

    _bufferList[0].mDataByteSize = UInt32(dataByteSize)
    let alingment = MemoryLayout<UInt8>.alignment
    let mData = UnsafeMutableRawPointer.allocate(byteCount: dataByteSize, alignment: alingment)
    _bufferList[0].mData = mData
    _bufferList[0].mNumberChannels = 2

    return _bufferList.unsafeMutablePointer
}
