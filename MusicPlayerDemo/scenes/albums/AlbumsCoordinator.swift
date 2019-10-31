//
//  AlbumsCoordinator.swift
//  MusicPlayerDemo
//
//  Created by abuzeid on 10/30/19.
//  Copyright © 2019 abuzeid. All rights reserved.
//

import Foundation
import UIKit
/// The App Coordinator creates the The Root ViewController of the Window
final class AlbumsCoordinator: Coordinator {
    func start(completion: (() -> Void)?) {
        start(completion: completion, for: .none)
    }
    
    private(set) weak var albumsController: AlbumsViewController?
    var nv: UINavigationController?
    init(_ nv: UINavigationController?) {
        self.nv = nv
    }
    
    func start(completion: (() -> Void)?, for artist: Artist?) {
        let albumsController = AlbumsViewController()
        albumsController.title = artist == nil ? "Your Albums" : artist?.name ?? ""
        albumsController.viewModel = AlbumsListViewModel(artist: artist, co: self)
        self.albumsController = albumsController
        nv?.pushViewController(albumsController, animated: true)
        completion?()
    }
    func showTracks(of artist: Artist?,album:Album) {
        let songsVC = SongsViewController()
        songsVC.title = album.name
        songsVC.viewModel = SongsListViewModel(album: album, artist: artist)
        nv?.pushViewController(songsVC, animated: true)
    }
    func finish(completion: (() -> Void)?) {
        completion?()
    }
}
