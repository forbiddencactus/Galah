//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Internal pointer based event type, for use with struct callbacks and such things. 

// Event that uses pointers, so we can send events to structs. Naturally, the usual traps of unsafe code apply.
internal struct PtrEvent<Sender>
{
    private struct Subscriber
    {
        let subscriber: UnsafeMutableRawPointer;
        let callback: (inout Sender) -> ();
    }
    
    private var subscribers = Dictionary<UnsafeMutableRawPointer, Subscriber>();
    
    mutating func Subscribe(_ subscriber: UnsafeMutableRawPointer, _ callback: @escaping (inout Sender) -> ())
    {
        self.subscribers[subscriber] = Subscriber(subscriber: subscriber, callback: callback);
    }
    
    mutating func Unsubscribe(_ subscriber: UnsafeMutableRawPointer)
    {
        self.subscribers.removeValue(forKey: subscriber);
    }
    
    func Broadcast(_ sender: inout Sender)
    {
        for theSubscriber in subscribers.values
        {
            theSubscriber.callback(&sender);
        }
    }
    
    mutating func Clear()
    {
        self.subscribers.removeAll();
    }
    
    mutating func ReplaceSubscribers(fromEvent: Event)
    {
        //
    }
}

internal struct RawPtrEvent
{
    private struct Subscriber
    {
        let subscriber: UnsafeMutableRawPointer;
        let callback: (UnsafeMutableRawPointer) -> ();
    }
    
    private var subscribers = Dictionary<UnsafeMutableRawPointer, Subscriber>();
    
    mutating func Subscribe(_ subscriber: UnsafeMutableRawPointer, _ callback: @escaping (UnsafeMutableRawPointer) -> ())
    {
        self.subscribers[subscriber] = Subscriber(subscriber: subscriber, callback: callback);
    }
    
    mutating func Unsubscribe(_ subscriber: UnsafeMutableRawPointer)
    {
        self.subscribers.removeValue(forKey: subscriber);
    }
    
    public func Broadcast(_ sender: UnsafeMutableRawPointer)
    {
        for theSubscriber in subscribers.values
        {
            theSubscriber.callback(sender);
        }
    }
    
    mutating func Clear()
    {
        self.subscribers.removeAll();
    }
    
    mutating func ReplaceSubscribers(fromEvent: Event)
    {
        //
    }
}
