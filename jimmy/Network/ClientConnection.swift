//
//  ClientConnection.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//


import Foundation
import Network

@available(macOS 10.14, *)
class ClientConnection {

    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")
    
    var read: String
    
    var data: Data

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.read = ""
        self.data = Data()
    }

    var didStopCallback: ((NWError?, Data?) -> Void)? = nil

    func start() {
        print("connection will start")
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        setupReceive()
        nwConnection.start(queue: queue)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 0, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.data += data
            }
            
            if isComplete {
                print("Done receiving")
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                print("receiving...")
                self.setupReceive()
            }
        }
    }

    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("Sent message: " + String(decoding: data, as: UTF8.self))
        }))
    }

    func stop() {
        print("connection will stop")
        stop(error: nil, message: nil)
    }

    private func connectionDidFail(error: NWError) {
        print("connection did fail, error: \(error)")
        self.stop(error: error, message: nil)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil, message: self.data)
    }

    private func stop(error: NWError?, message: Data?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            didStopCallback(error, message)
            self.didStopCallback = nil
        }
    }
}
