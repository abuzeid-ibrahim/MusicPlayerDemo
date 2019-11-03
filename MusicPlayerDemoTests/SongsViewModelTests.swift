//
//  SongsViewModelTests.swift
//  MusicPlayerDemoTests
//
//  Created by abuzeid on 11/3/19.
//  Copyright © 2019 abuzeid. All rights reserved.
//

@testable import MusicPlayerDemo
import XCTest
import Nimble
import Quick
import RxNimble
import RxOptional
import RxSwift
import RxTest
import Realm
import RealmSwift
class SongsViewModelTests: QuickSpec {
    override func spec() {
        describe("songs view model") {
            var schedular: TestScheduler!
            var tracksObserver: TestableObserver<[Track]>!
            var disposeBag = DisposeBag()
            beforeEach {
                schedular = TestScheduler(initialClock: 0)
                tracksObserver = schedular.createObserver([Track].self)
                disposeBag = DisposeBag()
            }
            
            context("we have online songs") {
                var viewModel: SongsViewModel!
                beforeEach {
                    viewModel = SongsListViewModel(apiClient: MockedApi(), album: Mocker.album, artist: Mocker.artist, repo: MockedDataRepo(), type: .online)
                }
                it("should display all cached songs of an album") {
                    viewModel.tracksList.bind(to: tracksObserver).disposed(by: disposeBag)
                    viewModel.loadData()
                    schedular.start()
                    expect(tracksObserver.events)
                        .to(equal([Recorded.next(0, []),Recorded.next(0, [Mocker.track])]))
                }
                it("should save album") {
                    viewModel.tracksList.bind(to: tracksObserver).disposed(by: disposeBag)
                    viewModel.loadData()
                    viewModel.changeOfflineMode()
                    schedular.start()
                    expect(tracksObserver.events)
                        .to(equal([Recorded.next(0, []),Recorded.next(0, [Mocker.track])]))
                }
            }
            context("we have cached songs") {
                var viewModel: SongsViewModel!
                beforeEach {
                    viewModel = SongsListViewModel(apiClient: MockedApi(), album: Mocker.album, artist: Mocker.artist, repo: MockedDataRepo(), type: .offline)
                }
                it("should display all cached songs of an album") {
                    
                    viewModel.tracksList.bind(to: tracksObserver).disposed(by: disposeBag)
                    viewModel.loadData()
                    schedular.start()
                    expect(tracksObserver.events)
                        .to(equal([Recorded.next(0, []),Recorded.next(0, [Mocker.track])]))
                }
                it("should delete album") {
                    viewModel.tracksList.bind(to: tracksObserver).disposed(by: disposeBag)
                    viewModel.loadData()
                    viewModel.changeOfflineMode()
                    schedular.start()
                    expect(tracksObserver.events)
                        .to(equal([Recorded.next(0, []),Recorded.next(0, [Mocker.track]),Recorded.completed(0)]))
                    
                }
            }
        }
    }
}
fileprivate struct Mocker {
    
    static let album  =  Album(name: "Believe", playcount: 1, mbid: "63b3a8ca-26f2-4e2b-b867-647a6ec2bebd", url: nil, artist: nil, image: nil)
    static  let artist  =  Artist(name: "Adele", listeners: "12", mbid: "12", url: nil, streamable: nil, image: nil)
    static  let track  =  Track(name: "Believe", url: "https://www.last.fm/music/Cher/_/Believe", duration: "238")
    
}

fileprivate struct MockedApi:ApiClient{
    func getData<T>(of request: RequestBuilder) -> Observable<T?> where T : Decodable {
        return Observable.create{obs in
            
            
            let data  = """
            {
            "album": {
            "name": "Believe",
            "artist": "Cher",
            "mbid": "63b3a8ca-26f2-4e2b-b867-647a6ec2bebd",
            "tracks": {
            "track": [
            {
            "name": "Believe",
            "url": "https://www.last.fm/music/Cher/_/Believe",
            "duration": "238"

            }]}}}
""".data(using: .utf8)
            
            obs.onNext(data?.toModel())
            return Disposables.create()
        }
    }
    
    
}
fileprivate class MockedDataRepo:DataBaseOperations{
    var count  = 0
    func save(obj: Cachable) {
        count += 1
    }
    
    func getAll(of obj: Cachable.Type) -> [Cachable] {
        return [Mocker.track]
    }
    
    func delete(obj: Cachable) {
        count -= 1
    }
    
    func get(obj: Cachable.Type, filter key: String, value: String) -> Cachable? {
        let list = List<Track>()
        list.append(Mocker.track)
        let tracks = Tracks(track: list )
        return AlbumTracks(name: nil, artist: nil, mbid: Mocker.album.mbid, url: nil, listeners: nil, playcount: nil, tracks: tracks)
    }
    
    
}