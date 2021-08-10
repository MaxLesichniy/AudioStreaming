//
//  NodeAudioPlayerDelegate.swift
//  AudioStreaming
//
//  Created by Max Lesichniy on 02.08.2021.
//

import Foundation

public protocol AudioPlayerNodeDelegate: AnyObject {
    /// Tells the delegate that the player started player
    func audioPlayerDidStartPlaying(player: AudioPlayerNode, with entryId: AudioEntryId)

    /// Tells the delegate that the player finished buffering for an entry.
    /// - note: May be called multiple times when seek is requested
    func audioPlayerDidFinishBuffering(player: AudioPlayerNode, with entryId: AudioEntryId)

    /// Tells the delegate that the state has changed passing both the new state and previous.
    func audioPlayerStateChanged(player: AudioPlayerNode, with newState: AudioPlayerState, previous: AudioPlayerState)

    /// Tells the delegate that an entry has finished
    func audioPlayerDidFinishPlaying(player: AudioPlayerNode,
                                     entryId: AudioEntryId,
                                     stopReason: AudioPlayerStopReason,
                                     progress: Double,
                                     duration: Double)
    /// Tells the delegate when an unexpected error occured.
    /// - note: Probably a good time to recreate the player when this occurs
    func audioPlayerUnexpectedError(player: AudioPlayerNode, error: AudioPlayerError)

    /// Tells the delegate when cancel occurs, usually due to a stop or play (new source)
    func audioPlayerDidCancel(player: AudioPlayerNode, queuedItems: [AudioEntryId])

    /// Tells the delegate when a metadata read occurred from the stream.
    func audioPlayerDidReadMetadata(player: AudioPlayerNode, metadata: [String: String])
}
