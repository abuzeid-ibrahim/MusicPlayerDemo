//
//  MiniPlayerViewModel.swift
//  MusicPlayerDemo
//
//  Created by abuzeid on 10/13/19.
//  Copyright © 2019 abuzeid. All rights reserved.
//

import Foundation
import RxOptional
import RxSwift

protocol PlayerViewModel {
    func playSong(index: IndexPath)
}

///
class MiniPlayerViewModel: PlayerViewModel {
    private let disposeBag = DisposeBag()
    var songsList = BehaviorSubject<ArtistsRespose>(value: [])

    private var player: AudioPlayer
    var currentUser: Artist?
    init(player: AudioPlayer, songs: [SongEntity]) {
        self.player = player
        songsList.onNext(songs)
    }

    /// play song
    /// - Parameter index: the index of the song selected from the table of songs
    func playSong(index: IndexPath) {
        songsList.subscribe(onNext: { [unowned self] value in
            self.player.playAudio(value, startFrom: index.row)
        }).disposed(by: disposeBag)
    }
}
