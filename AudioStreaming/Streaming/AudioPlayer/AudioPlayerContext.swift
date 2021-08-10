//
//  Created by Dimitrios Chatzieleftheriou on 16/06/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

import Foundation

internal final class AudioPlayerContext {
    @Protected
    var stopReason: AudioPlayerStopReason = .none

    @Protected
    var state: AudioPlayerState = .ready
    var stateChanged: ((_ oldState: AudioPlayerState, _ newState: AudioPlayerState) -> Void)?

    @Protected
    var muted: Bool = false

    let entriesLock = UnfairLock()
    var audioReadingEntry: AudioEntry?
    var audioPlayingEntry: AudioEntry?

    var disposedRequested: Bool

    /// This is the player's internal state to use
    /// - NOTE: Do not use directly instead use the `internalState` to set and get the property
    /// or the `setInternalState(to:when:)`method
    @Protected
    var internalState: AudioPlayer.InternalState = .initial

    init() {
        disposedRequested = false
    }

    /// Sets the internal state if given the `inState` will be evaluated before assignment occurs.
    /// This also convenvienlty sets the `stopReason` as well
    /// - parameter state: The new `PlayerInternalState`
    /// - parameter inState: If the `inState` expression is not nil, the internalState will be set if the evaluated expression is `true`
    /// - NOTE: This sets the underlying `__playerInternalState` variable
    internal func setInternalState(to state: AudioPlayer.InternalState,
                                   when inState: ((AudioPlayer.InternalState) -> Bool)? = nil)
    {
        let newValues = playerStateAndStopReason(for: state)
        stopReason = newValues.stopReason
        guard state != internalState else { return }
        if let inState = inState, !inState(internalState) {
            return
        }
        internalState = state
        let previousPlayerState = self.state
        if newValues.state != previousPlayerState {
            self.state = newValues.state
            stateChanged?(previousPlayerState, newValues.state)
        }
    }
}
