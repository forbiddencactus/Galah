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
// A simple event class.

public class Event
{
    private struct Subscriber
    {
        public let subscriber: AnyObject;
        public let callback: (AnyObject) -> ();
    }

    private var subscribers = Dictionary<HashableRef<AnyObject>, Subscriber>();
    
    public func Subscribe(_ subscriber: AnyObject, _ callback: @escaping (AnyObject) -> ())
    {
        self.subscribers[subscriber] = Subscriber(subscriber: subscriber, callback: callback);
    }
    
    public func Unsubscribe(_ subscriber: AnyObject)
    {
        self.subscribers.removeValue(forKey: HashableRef<AnyObject>(subscriber));
    }
    
    public func Broadcast(_ input: AnyObject)
    {
        for theSubscriber in subscribers.values
        {
            theSubscriber.callback(input);
        }
    }
    
    public func Clear()
    {
        subscribers.removeAll();
    }
    
    public func ReplaceSubscribers(fromEvent: Event)
    {
        subscribers.removeAll();
    }
}
