//
//  ReachabilityHandler.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 16..
//

import Foundation

final class ReachabilityHandler {
    
    private var reachability: Reachability? = try? Reachability()
    private var vc: MoviesVC
    
    // MARK: - LifeCycle
    
    init(vc: MoviesVC) {
        self.vc = vc
        configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    // MARK: - Private
    
    private func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ReachabilityHandler.checkForReachability(notification:)),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
        try? reachability?.startNotifier()
        
    }
    
    @objc private func checkForReachability(notification: NSNotification){
        let networkReachability = notification.object as? Reachability
        if let remoteHostStatus = networkReachability?.connection {
            switch remoteHostStatus {
            case .none:
                
                break
            case .wifi,
                 .cellular:
                
                vc.getMovies()
                break
            case .unavailable:
                
                break
            }
        }
    }
}
