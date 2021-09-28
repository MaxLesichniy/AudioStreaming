//
//  WritePCMBufferToFile.swift
//  AudioStreaming
//
//  Created by Max Lesichniy on 10.08.2021.
//

import Foundation
import AVFoundation

func writeBuffer(_ audioBuffer: AudioBuffer, totalFrameCount: AVAudioFrameCount, to url: URL) {
    let outputFormatSettings = [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVLinearPCMBitDepthKey: 32,
        AVLinearPCMIsFloatKey: true,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2
        ] as [String : Any]

    let format = AVAudioFormat(settings: outputFormatSettings)!
    let writeFile = try! AVAudioFile(forWriting: url,
                                     settings: outputFormatSettings,
                                     commonFormat: .pcmFormatFloat32,
                                     interleaved: true)

    if let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                        frameCapacity: totalFrameCount) {
        
        memcpy(pcmBuffer.mutableAudioBufferList[0].mBuffers.mData,
               audioBuffer.mData,
               Int(audioBuffer.mDataByteSize))
        
        pcmBuffer.mutableAudioBufferList[0].mBuffers.mNumberChannels = 2
        pcmBuffer.mutableAudioBufferList[0].mBuffers.mDataByteSize = audioBuffer.mDataByteSize
        pcmBuffer.mutableAudioBufferList[0].mNumberBuffers = 1
        pcmBuffer.frameLength = totalFrameCount
        try! writeFile.write(from: pcmBuffer)
    }
}
