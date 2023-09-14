//
//  BackgroundWorker.swift
//  Inventory
//
//  Created by Aaron LaBeau on 9/12/23.
//

import Foundation

class BackgroundWorker {
    
    private var thread: Thread?
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let lock = NSRecursiveLock()
    
    private var queue = [() -> Void]()
    
    public func enqueue(_ block: @escaping () -> Void) {
        // add the block to the queue, in a thread safe manner
        locked { queue.append(block) }
        
        // signal the semaphore, this will wake up the sleeping beauty
        semaphore.signal()
        
        // if this is the first time we enqueue a block, detach the thread
        // this makes the class lazy - it doesn't dispatch a new thread until the first
        // work item arrives
        if thread == nil {
            thread = Thread(block: work)
            thread?.start()
        }
    }
    
    private func work() {
        // just an infinite sequence of sleeps while the queue is empty
        // and block executions if the queue has items
        while true {
            // let's sleep until we get signalled that items are available
            semaphore.wait()
            
            // extract the first block in a thread safe manner, execute it
            // if we get here we know for sure that the queue has at least one element
            // as the semaphore gets signalled only when an item arrives
            let block = locked  {
                queue.isEmpty ? nil :queue.removeFirst()
            }
            block?()
        }
    }
    
    private func locked<T>(do block: () -> T) -> T {
        lock.lock(); defer { lock.unlock() }
        return block()
    }
    
}
